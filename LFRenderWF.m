function LFRenderWF( libDir, povFile, camParam, outFile, extraOpt )
%LFRENDERP Render a image captured by a window-frame LF camera,
% through POV-Ray user-defined camera
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

% Render the full light field image
lfCamParam = camParam;
lfCamParam.noise.enabled = false;
[pathstr, name, ext] = fileparts(outFile);
lfFile = fullfile(pathstr, sprintf('%s-LF%s', name, ext));
if ~exist(lfFile, 'file')
    LFRenderUD(libDir, povFile, lfCamParam, lfFile, extraOpt);
end

% Render the perspective image
perspCamParam = camParam;
perspCamParam.noise.enabled = false;
perspFile = fullfile(pathstr, sprintf('%s-persp%s', name, ext));
if ~exist(perspFile, 'file')
    LFRenderWFP(libDir, povFile, perspCamParam, perspFile, extraOpt);
end

% Blend the two images
fprintf('Combining the images...\n');
im = im2double(imread(lfFile));
imP = im2double(imread(perspFile));
h = camParam.window(1)/2*camParam.resol(1);
w = camParam.window(2)/2*camParam.resol(2);
xc = (1+camParam.resol(2)*camParam.resol(4)) / 2;
yc = (1+camParam.resol(1)*camParam.resol(3)) / 2;
xl = round(xc-w+0.5);
xh = round(xc+w-0.5);
yl = round(yc-h+0.5);
yh = round(yc+h-0.5);
% im(yl:yh,xl:xh,:) = 0;
% im = im + imP;
im(yl:yh,xl:xh,:) = imP(yl:yh,xl:xh,:);
rawFile = fullfile(pathstr, sprintf('%s-no-noise%s', name, ext));
imwrite(im, rawFile);

% Add noise
if camParam.noise.enabled
    genNoise(rawFile, outFile, camParam.noise);
else
    movefile(rawFile, outFile);
end

end

