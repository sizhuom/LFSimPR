function makeMeshCam2Center( H, sz, fname, mode, meshName, aa_radius )
%MAKEMESHCAM2CENTER Generate the mesh2 file for the mesh camera
%  H : 5x5 intrinsic matrix
%  sz : 1x4 size vector, in the order of Y, X, V, U
%  fname : output filename
%  mode : 1=subaperture(uv first), 2=raw image(xy first)
%  meshName : name of the mesh variable in the generated file
%  aa_radius : radius for the AA random distribution

if (nargin < 4)
    mode = 2;
end
if (nargin < 5)
    meshName = 'camera_mesh';
end
if (nargin < 6)
    aa_radius = 0;
end

% write H and sz as comments
fout = fopen(fname, 'w');
fprintf(fout, '/*\n');
fprintf(fout, ' %d', sz);
fprintf(fout, '\n');
for i = 1:5
    fprintf(fout, ' %f', H(i,:));
    fprintf(fout, '\n');
end
fprintf(fout, '*/\n');

% write the mesh
fprintf(fout, '#declare %s=\n', meshName);
fprintf(fout, 'mesh2 {\n');
N = sz(3) * sz(4);
fprintf(fout, 'vertex_vectors {\n%d,\n', N*3);

% size of each triangle
triSz = max(max(H(1:4,1:4)));

% itereate over all rays
tic;
count = 0;

for v = 1:sz(3)
    for y = round((1+sz(1))/2)
        fprintf(repmat('\b',1,count));
        count = fprintf('Computing %d/%d...',(v-1)*sz(1)+y,sz(1)*sz(3));
        for u = 1:sz(4)
            for x = round((1+sz(2))/2)
                %                     offset = -0.5 + rand(4,1);
                %                     offset = [offset; 0] * aa_radius;
                %                     r = [x;y;u;v;1] + offset;
                %                     r = H * r;
                r = H * [x;y;u;v;1];
                r(2) = -r(2); r(4) = -r(4); % convert to pov-ray's left handed coordinate system
                T = makeTriangle([r(1);r(2);0],[r(3);r(4);1],triSz);
                fprintf(fout,'<%.16f,%.16f,%.16f>,<%.16f,%.16f,%.16f>,<%.16f,%.16f,%.16f>,\n',T);
            end
        end
    end
end
fprintf(fout, '}\n');
toc;

% print face_indices
tic;
fprintf(fout, 'face_indices {\n%d,\n', N);
fprintf('\nPrinting face indices...\n');
for i = 0:N-1
    fprintf(fout, '<%d,%d,%d>,\n', 3*i, 3*i+1, 3*i+2);
end
fprintf(fout, '}\n}\n');
fclose(fout);
fprintf('\nFinished\n');
toc;

end

