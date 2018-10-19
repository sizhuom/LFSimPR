function LFRenderWFP( libDir, povFile, camParam, outFile, extraOpt )
%LFRENDERWFP Render a perspective image through POV-Ray user-defined
%camera, used for WF
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

% Render the image for multiple direction to simulate DOF
[pathstr, name, ext] = fileparts(outFile);
tmppathstr = fullfile(pathstr, name);
mkdir(tmppathstr);
for i = 1:camParam.samples
    rho = rand() * camParam.apert * (i-1) / camParam.samples;
    theta = rand() * 2 * pi;
    sampleCamParam = camParam;
    sampleCamParam.SA = [rho*cos(theta) rho*sin(theta)];
    sampleCamParam.noise.enabled = false;

    % Create the camera .inc file
    makeCamPersp(sampleCamParam.camFile, sampleCamParam);
    
    % Render the light field
    width = camParam.resol(2) * camParam.resol(4);
    height = camParam.resol(1) * camParam.resol(3);
    sampleFile = fullfile(tmppathstr, sprintf('SA%04d%s', i, ext));
    if exist(sampleFile, 'file')
        continue
    end
    if ispc
        command = sprintf('povray /EXIT /RENDER +I"%s" +L"%s" +W%d +H%d +O"%s" +HI"%s" -D -V Declare=EXT_CAMERA=1 %s',...
            povFile, libDir, width, height, sampleFile, camParam.camFile, extraOpt);
    else
        command = sprintf('povray +I"%s" +L"%s" +W%d +H%d +O"%s" +HI"%s" -D -V Declare=EXT_CAMERA=1 %s',...
            povFile, libDir, width, height, sampleFile, camParam.camFile, extraOpt);
    end
    disp(command);
    system(command);
    
%     % Crop the image if used in window-frame mode
%     if isfield(camParam, 'window')
%         sampleIm = im2double(imread(sampleFile));
%         sampleIm = cropWindow(sampleIm, sampleCamParam);
%         imwrite(sampleIm, sampleFile);
%     end
end

% Blend all the samples to get the final image
fprintf('Blending images...\n');
im = zeros(height, width, 3);
for i = 1:camParam.samples
    sampleFile = fullfile(tmppathstr, sprintf('SA%04d%s', i, ext));
    sampleIm = im2double(imread(sampleFile));
    im = im + sampleIm;
%     delete(sampleFile);
end
im = im / camParam.samples;
lfFile = fullfile(pathstr, sprintf('%s-no-noise%s', name, ext));
imwrite(im, lfFile);

% Add noise
if camParam.noise.enabled
    genNoise(lfFile, outFile, camParam.noise);
else
    movefile(lfFile, outFile);
end
fprintf('Done!\n');

end

