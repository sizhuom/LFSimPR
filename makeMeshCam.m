function makeMeshCam( H, sz, fname )
%MAKEMESHCAM Generate the mesh file for the mesh camera
%  H : 5x5 intrinsic matrix
%  sz : 1x4 size vector, in the order of Y, X, V, U
%  fname : output filename

fout = fopen(fname, 'w');
fprintf(fout, 'mesh{\n');

% size of each triangle
triSz = max(max(H(1:4,1:4)));

% itereate over all rays
tic;
count = 0;
for v = 1:sz(3)
    for y = 1:sz(1)
        fprintf(repmat('\b',1,count));
        count = fprintf('Computing %d/%d...',v,sz(3));
        for u = 1:sz(4)
            for x = 1:sz(2)
                r = [x;y;u;v;1];
                r = H * r;
                r(2) = -r(2); r(4) = -r(4); % convert to pov-ray's left handed coordinate system
                T = makeTriangle([r(1);r(2);0],[r(3);r(4);1],triSz);
                fprintf(fout,'triangle{<%.16f,%.16f,%.16f>,<%.16f,%.16f,%.16f>,<%.16f,%.16f,%.16f>}\n',T);
            end
        end
    end
end
fprintf(fout, '}\n');
fclose(fout);
fprintf('\nFinished\n');
toc;

end

