%% Paths
addpath('../..'); % be careful with this; should replace with the actual path

%% Generate images
filePath = mfilename('fullpath');
[parentFolder, ~, ~] = fileparts(filePath);
[~, projName, ~] = fileparts(parentFolder);
workDir = parentFolder;
baseFile = fullfile(workDir, 'template.json');
lfFilePrefix = 'frame';
skipExist = false;

% read parameters from .json
param = LFReadMetadata(baseFile);
param.libDir = workDir;
param.povFile = 'scene.pov';
param.extraOpt = '+MI5120 File_Gamma=2.2 Bits_Per_Color=16';
param.type = 'perspective';

% compute camera extrinsics from pos/lookAt/up if needed
if isfield(param.camParam, 'R')
    R = param.camParam.R;
    t = param.camParam.t;
else
    if isfield(param.camParam, 'up')
        [R, t] = buildLookAt(param.camParam.pos, param.camParam.lookAt, param.camParam.up, true);
    else
        [R, t] = buildLookAt(param.camParam.pos, param.camParam.lookAt, [0;1;0], true);
    end
end
C = [R t; zeros(1,3) 1];

% camera motion
N = 1;
T0 = t;
dT = zeros(3, N);
for i = 1:N
    dT(:,i) = [0 0 1] / 1000 * i;
end

% generate every frame
for i = 0:N
    if i > 0
        T = T0 + dT(:,:,i);
    else
        T = T0;
    end
    newParam = param;
    newParam.camParam.t = T;
    jsonFilePath = fullfile(workDir, sprintf('%s_%04d.json', lfFilePrefix, i));
    LFWriteMetadata(jsonFilePath, newParam);
    LFRenderJson(jsonFilePath, skipExist);
end
