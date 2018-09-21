function makeCamWFP( camFile, camParam )
%MAKECAMWFP Make the user-defined perspective camera as .inc file, used for
%WF

fout = fopen(camFile, 'w');

if (isfield(camParam, 'H'))
    H = camParam.H;
else
    H = genIntrinsicsP2(camParam.resol, camParam.apert, camParam.fov, camParam.fLen, camParam.SA);
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

Hx = R(:,1:2) * H(1:2,:);
Hy = R(:,1:2) * H(3:4,:);

fprintf(fout, '#version 3.71;\n');
fprintf(fout, '#include "math.inc"\n');
fprintf(fout, '#declare sx = %d;\n', camParam.resol(2));
fprintf(fout, '#declare sy = %d;\n', camParam.resol(1));
fprintf(fout, '#declare su = %d;\n', camParam.resol(4));
fprintf(fout, '#declare sv = %d;\n', camParam.resol(3));
fprintf(fout, [
    'camera {\n'...
    'user_defined\n'...
    'location {\n']);
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hx(1,1),Hx(1,2),Hx(1,3)+t(1));
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hx(2,1),Hx(2,2),Hx(2,3)+t(2));
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hx(3,1),Hx(3,2),Hx(3,3)+t(3));
fprintf(fout, '}\n');
fprintf(fout, 'direction {\n');
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hy(1,1),Hy(1,2),Hy(1,3)+R(1,3));
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hy(2,1),Hy(2,2),Hy(2,3)+R(2,3));
fprintf(fout, ['function { ((x+0.5)*image_width+0.5)*(%.16g)'...
    '+((y+0.5)*image_height+0.5)*(%.16g)'...
    '+(%.16g) }\n'],Hy(3,1),Hy(3,2),Hy(3,3)+R(3,3));
fprintf(fout, '}\n');
fprintf(fout, '}\n');

fclose(fout);

end

