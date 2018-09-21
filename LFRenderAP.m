function LFRenderAP( libDir, povFile, camParam, outFile, extraOpt, outputSA, skipExist )
%LFRENDERAP Render a light field by an array of pinhole cameras
%   libDir: library path for POV-Ray
%   povFile: .pov file that describes the scene (with no camera)
%   camParam: struct for camera parameters. Possible fields:
%     camFile, resol, unitBase, vertFOV, H,
%     t, R, pos, lookAt, up.
%   oufFile: output file name
%   extraOpt: extra commandline options for pov-ray
%   outputSA: output subaperture images instead of single "raw" image
%   skipExist: skip rendering if output file exists

global DEBUG
if nargin < 5
    extraOpt = '';
end

if nargin < 6
    outputSA = false;
end

if nargin >=7 && skipExist && exist(outFile, 'file')
    return
end

% Generate intrinsics
if ~isfield(camParam, 'H')
    % assuming same unit baseling for x,y directions, square pixels,
    % centered
    xStep = unitBase;
    yStep = unitBase;
    vStep = tan(vertFOV/2/180*pi) * 2 / camParam.resol(3);
    uStep = vStep;
    camParam.H = [
        xStep, 0, 0, 0, -xStep*((1+camParam.resol(2))/2);
        0, yStep, 0, 0, -yStep*((1+camParam.resol(1))/2);
        0, 0, uStep, 0, -uStep*((1+camParam.resol(4))/2);
        0, 0, 0, vStep, -vStep*((1+camParam.resol(3))/2);
        ];
end
fprintf('Using the following intrinsic matrix:\n');
disp(camParam.H);

% Render the light field
width = camParam.resol(4);
height = camParam.resol(3);
[pathstr, name, ext] = fileparts(outFile);

% Render each subaperture image
tmppathstr = fullfile(pathstr, name);
mkdir(tmppathstr);
for i = 1:camParam.resol(1)
    for j = 1:camParam.resol(2)
        makeCamAP(camParam.camFile, camParam, j, i);
        
        sampleFile = fullfile(tmppathstr, sprintf('Sub_%02d_%02d%s', i, j, ext));
        if skipExist && exist(sampleFile, 'file')
            continue
        end
        
        command = sprintf('povray "+I%s" "+L%s" +W%d +H%d "+O%s" "+HI%s" -D -V Declare=EXT_CAMERA=1 %s',...
            povFile, libDir, width, height, sampleFile, camParam.camFile, extraOpt);
        disp(command);
        system(command);
        
        if camParam.noise.enabled
            genNoise(sampleFile, sampleFile, camParam.noise);
        end
    end
end

if ~outputSA
    % Stacking all subaperture images to get the final image
    fprintf('Combining images...\n');
    lf = zeros([camParam.resol 3]);
    for i = 1:camParam.resol(1)
        for j = 1:camParam.resol(2)
            sampleFile = fullfile(tmppathstr, sprintf('Sub_%d_%d%s', i, j, ext));
            sampleIm = im2double(imread(sampleFile));
            lf(i,j,:,:,:) = sampleIm;
        end
    end
    im = LF2Raw(lf);
    imwrite(im, outFile);
    
    % Delete the sample images
    if ~DEBUG
        rmdir(tmppathstr, 's');
    end
end


end

