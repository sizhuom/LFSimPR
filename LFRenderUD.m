function LFRenderUD( libDir, povFile, camParam, outFile, extraOpt, skipExist )
%LFRENDERUD Render a light field through POV-Ray user-defined camera
%   libDir: library path for POV-Ray
%   povFile: .pov file that describes the scene (with no camera)
%   camParam: struct for camera parameters. Should have following fields:
%   meshFile, camFile, resol, apert, fNum, fLen, aaSamples, t, R, 
%   pos, lookAt, up.
%   oufFile: output file name
%   extraOpt: extra commandline options for pov-ray
%   skipExist: skip rendering if output file exists

global DEBUG
if (nargin < 5)
    extraOpt = '';
end

if skipExist && exist(outFile, 'file')
    return
end

% Generate intrinsics
if ~isfield(camParam, 'H')
    camParam.H = genIntrinsics2(camParam.resol, camParam.apert, camParam.fov, camParam.fLen);
end
fprintf('Using the following intrinsic matrix:\n');
disp(camParam.H);

% Render the light field
width = camParam.resol(2) * camParam.resol(4);
height = camParam.resol(1) * camParam.resol(3);
[pathstr, name, ext] = fileparts(outFile);
lfFile = fullfile(pathstr, [name '-no-noise' ext]);

if ~isfield(camParam, 'lfSamples')
    camParam.lfSamples = [1 1 1 1];
end
rng(41);
if prod(camParam.lfSamples) == 1
    makeCamUserDefined(camParam.camFile, camParam);
    command = sprintf('povray "+I%s" "+L%s" +W%d +H%d "+O%s" "+HI%s" -D -V Declare=EXT_CAMERA=1 %s',...
        povFile, libDir, width, height, lfFile, camParam.camFile, extraOpt);
    disp(command);
    system(command);
else % Render multiple images for antialiasing
    tmppathstr = fullfile(pathstr, name);
    mkdir(tmppathstr);
    stepSize = 1./(camParam.lfSamples);
    xv = ((1:camParam.lfSamples(1))-0.5) * stepSize(1) + 0.5;
    yv = ((1:camParam.lfSamples(2))-0.5) * stepSize(2) + 0.5;
    uv = ((1:camParam.lfSamples(3))-0.5) * stepSize(3) + 0.5;
    vv = ((1:camParam.lfSamples(4))-0.5) * stepSize(4) + 0.5;
    [xo, yo, uo, vo] = ndgrid(xv,yv,uv,vv);
    offsets = [xo(:) yo(:) uo(:) vo(:)];
    randFactor = bsxfun(@times,rand(size(offsets))-0.5,stepSize);
    offsets = offsets + randFactor;
    for i = 1:size(offsets, 1)
        makeCamUserDefined(camParam.camFile, camParam, offsets(i,:));
        
        sampleFile = fullfile(tmppathstr, sprintf('SA%04d%s', i, ext));
        if exist(sampleFile, 'file')
            continue
        end
        
        command = sprintf('povray "+I%s" "+L%s" +W%d +H%d "+O%s" "+HI%s" -D -V Declare=EXT_CAMERA=1 %s',...
            povFile, libDir, width, height, sampleFile, camParam.camFile, extraOpt);
        disp(command);
        system(command);
    end
    
    % Blend all the samples to get the final image
    fprintf('Blending images...\n');
    im = zeros(height, width, 3);
    for i = 1:prod(camParam.lfSamples)
        sampleFile = fullfile(tmppathstr, sprintf('SA%04d%s', i, ext));
        sampleIm = im2double(imread(sampleFile));
        im = im + sampleIm;
        %     delete(sampleFile);
    end
    im = im / prod(camParam.lfSamples);
    imwrite(im, lfFile);
    
    % Delete the sample images
    if ~DEBUG
        rmdir(tmppathstr, 's');
    end
end

% Add noise
if camParam.noise.enabled
    genNoise(lfFile, outFile, camParam.noise);
else
    movefile(lfFile, outFile);
end

end

