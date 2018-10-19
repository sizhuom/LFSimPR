function LFRenderM( libDir, povFile, camParam, outFile, extraOpt )
%LFRENDERM Render a light field through a POV-Ray mesh camera
%   libDir: library path for POV-Ray
%   povFile: .pov file that describes the scene (with no camera)
%   camParam: struct for camera parameters. Should have following fields:
%   meshFile, camFile, resol, apert, fNum, fLen, aaSamples, t, R, 
%   pos, lookAt, up.
%   oufFile: output file name
%   extraOpt: extra commandline options for pov-ray

if (nargin < 5)
    extraOpt = '';
end

% Generate intrinsics
if ~isfield(camParam, 'H')
    camParam.H = genIntrinsics2(camParam.resol, camParam.apert, camParam.fov, camParam.fLen);
end
fprintf('Using the following intrinsic matrix:\n');
disp(camParam.H);

% Generate the mesh file if it doesn't exist
if (~exist(camParam.meshFile, 'file'))
    % create the mesh file
    makeMeshCam2(camParam.H,camParam.resol,camParam.meshFile,2);
end

% Create the camera .inc file
makeCamInc(camParam.camFile, camParam.meshFile, camParam);

% Render the light field
width = camParam.resol(2) * camParam.resol(4);
height = camParam.resol(1) * camParam.resol(3);
[pathstr, name, ext] = fileparts(outFile);
lfFile = fullfile(pathstr, [name '-no-noise' ext]);
logFile = [name '.log'];
if ispc
    command = sprintf('povray /EXIT /RENDER +I"%s" +L"%s" +W%d +H%d +O"%s" +HI"%s" +GA"%s" -D Declare=EXT_CAMERA=1 %s',...
        povFile, libDir, width, height, lfFile, camParam.camFile, logFile, extraOpt);
else
    command = sprintf('povray +I"%s" +L"%s" +W%d +H%d +O"%s" +HI"%s" +GA"%s" -D Declare=EXT_CAMERA=1 %s',...
        povFile, libDir, width, height, lfFile, camParam.camFile, logFile, extraOpt);
end
disp(command);
startTime = clock();
system(command);
endTime = clock();
logId = fopen(fullfile(pathstr, logFile), 'a');
fprintf(logId, 'Start time: %d-%02d-%02d %02d:%02d:%02.f\n', startTime);
fprintf(logId, 'End time: %d-%02d-%02d %02d:%02d:%02.f\n', endTime);
fclose(logId);

% Add noise
if camParam.noise.enabled
    genNoise(lfFile, outFile, camParam.noise);
else
    movefile(lfFile, outFile);
end

end

