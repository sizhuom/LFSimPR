function Knew = makeCamS2( camFile, camParam, isRight )
%MAKECAMS2 Make the .inc file for LFRenderS

fout = fopen(camFile, 'w');

K = camParam.K;
if any(K([2 3 4 6])) == 1
    error('Error: illegal K for stereo camera model.');
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

if ~isRight
    loc = 0;
    principal = [camParam.baseline/2/camParam.vf; 0; 1];
else
    loc = camParam.baseline;
    principal = [-camParam.baseline/2/camParam.vf; 0; 1];
end
aspr = (camParam.resol(2)*K(1,1)) / (camParam.resol(1)*K(2,2));
centerRay = [(1+camParam.resol(2))/2;(1+camParam.resol(1))/2;1];
principal0 = K * centerRay;
Knew = [K(:,1:2) K(:,3)+principal-principal0];
dirLen = 1/(camParam.resol(2)*K(1,1));
dir = principal * dirLen;

fprintf(fout, '#version 3.7;\n');
fprintf(fout, [
    'camera {\n'...
    'perspective\n']);
fprintf(fout,'location <%.16g,0,0>\n',loc);
fprintf(fout,'up <0,%.16g,0>\n',1/aspr);
fprintf(fout,'right <1,0,0>\n');
fprintf(fout,'direction <%.16g,%.16g,%.16g>\n',dir(1),-dir(2),dir(3));
fprintf(fout,'matrix <');
fprintf(fout,'%.16g,',R);
fprintf(fout,'%.16g,%.16g,%.16g>\n',t(1),t(2),t(3));
fprintf(fout, '}\n');

fclose(fout);


end

