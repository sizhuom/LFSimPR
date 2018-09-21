function Knew = LFRenderS2( libDir, povFile, camParam, outFile, extraOpt, skipExist )
%LFRENDERS2 Render stereo images (simulating rectified images)
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

% Render the light field
width = camParam.resol(2);
height = camParam.resol(1);
[pathstr, name, ext] = fileparts(outFile);

% Render each subaperture image
for i = 0:1
    Knew{i+1} = makeCamS2(camParam.camFile, camParam, i);
    
    imFile = fullfile(pathstr, sprintf('%s-f%d-no-noise%s',name,i,ext));
    finalFile = fullfile(pathstr, sprintf('%s-f%d%s',name,i,ext));
    
    if skipExist && exist(finalFile, 'file')
        continue
    end
    
    command = sprintf('povray "+I%s" "+L%s" +W%d +H%d "+O%s" "+HI%s" -D -V Declare=EXT_CAMERA=1 %s',...
        povFile, libDir, width, height, imFile, camParam.camFile, extraOpt);
    disp(command);
    system(command);
    
    if camParam.noise.enabled
        genNoise(imFile, finalFile, camParam.noise);
    else
        movefile(imFile, finalFile);
    end
end

end

