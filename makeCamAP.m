function makeCamAP( camFile, camParam, i, j )
%MAKECAMAP Make the .inc file for rendering a subaperture image

fout = fopen(camFile, 'w');

H = camParam.H;
if any(H([2 3 4 5 6 8 9 10 11 12 14 15 16 17 18 20])) == 1
    error('Error: illegal H for array of pinhole camera model.');
end

if isfield(camParam, 'R')
    R = camParam.R;
    t = camParam.t;
else
    if isfield(camParam, 'up')
        [R, t] = buildLookAt(camParam.pos, camParam.lookAt, camParam.up, true);
    else
        [R, t] = buildLookAt(camParam.pos, camParam.lookAt, [0;1;0], true);
    end
end
[R, t] = convertRHS(R, t);

loc = H([1 2 5],[1 2 5]) * [i;j;1];
aspr = (camParam.resol(4)*H(3,3)) / (camParam.resol(3)*H(4,4));
centerRay = [(1+camParam.resol(4))/2;(1+camParam.resol(3))/2;1];
principal = H(3:5,3:5) * centerRay;
dirLen = 1/(camParam.resol(4)*H(3,3));
dir = principal * dirLen;

fprintf(fout, '#version 3.7;\n');
fprintf(fout, [
    'camera {\n'...
    'perspective\n']);
fprintf(fout,'location <%.16g,%.16g,0>\n',loc(1),-loc(2));
fprintf(fout,'up <0,%.16g,0>\n',1/aspr);
fprintf(fout,'right <1,0,0>\n');
fprintf(fout,'direction <%.16g,%.16g,%.16g>\n',dir(1),-dir(2),dir(3));
fprintf(fout,'matrix <');
fprintf(fout,'%.16g,',R);
fprintf(fout,'%.16g,%.16g,%.16g>\n',t(1),t(2),t(3));
fprintf(fout, '}\n');

fclose(fout);


end

