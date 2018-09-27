function LFRenderP( libDir, povFile, camParam, outFile, extraOpt, skipExist )
%LFRENDERP Render perspective images 
%   libDir: library path for POV-Ray
%   povFile: .pov file that describes the scene (with no camera)
%   camParam: struct for camera parameters. Possible fields:
%     camFile, resol, unitBase, vertFOV, H,
%     t, R, pos, lookAt, up.
%   oufFile: output file name
%   extraOpt: extra commandline options for pov-ray
%   skipExist: skip rendering if output file exists

global DEBUG
if (nargin < 5)
    extraOpt = '';
end

% Generate intrinsics
fprintf('Using the following intrinsic matrix:\n');
disp(camParam.K);

% Render the image
width = camParam.resol(2);
height = camParam.resol(1);
[pathstr, name, ext] = fileparts(outFile);

makeCamP(camParam.camFile, camParam);

imFile = fullfile(pathstr, sprintf('%s-no-noise%s',name,ext));
finalFile = fullfile(pathstr, sprintf('%s%s',name,ext));

if skipExist && exist(finalFile, 'file')
    return
end

if ispc
command = sprintf('pvengine /EXIT /RENDER %s +L"%s" +W%d +H%d +O"%s" +HI"%s" -D -V Declare=EXT_CAMERA=1 %s',...
    povFile, libDir, width, height, imFile, camParam.camFile, extraOpt);
else
command = sprintf('povray %s +L"%s" +W%d +H%d +O"%s" +HI"%s" -D -V Declare=EXT_CAMERA=1 %s',...
    povFile, libDir, width, height, imFile, camParam.camFile, extraOpt);
end

disp(command);
system(command);

if camParam.noise.enabled
    genNoise(imFile, finalFile, camParam.noise);
else
    movefile(imFile, finalFile);
end

end

