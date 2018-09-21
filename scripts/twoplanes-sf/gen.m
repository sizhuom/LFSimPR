%% Paths
addpath('../..'); % be careful with this; should replace with the actual path

%% Generate images
filePath = mfilename('fullpath');
[parentFolder, ~, ~] = fileparts(filePath);
[~, projName, ~] = fileparts(parentFolder);
workDir = parentFolder;
baseFile = fullfile(workDir, 'frame_tmp.json');
lfFilePrefix = 'frame';
motionFile = 'motion.mat';
motionTxt = 'motion.txt';
skipExist = false;

% read parameters from .json
param = LFReadMetadata(baseFile);
% param.libDir = fullfile(remoteSimDir, projName);
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

% object params

% random motion
% T0 = [
%     0 0 1
%     ];
% N = 1;
% dT = [(rand(size(T0,1),size(T0,2), N)-0.5) * 0.004];
% disp(dT);
% save(fullfile(workDir,motionFile), 'dT', 'T0');
% fm = fopen(fullfile(workDir,motionTxt), 'w');
% for j = 1:size(dT,3)
%     fprintf(fm, 'Frame %d:\n', j);
%     for i = 1:size(dT,1)
%         fprintf(fm, '%.16g ', dT(i, :)*1000);
%         fprintf(fm, '\n');
%     end
% end
% fclose(fm);

% fixed motion
T0 = [
    1 0 0.6;
    0 0 0.8];
N = 1;
dT = zeros(2,3,N);
for i = 1:N
    dT(:,:,i) = [1.2, 1.0, 1.6; -1.2, -1.0, -1.6] / 1000 * i * 2;
end
save(fullfile(workDir,motionFile), 'dT', 'T0');
fm = fopen(fullfile(workDir,motionTxt), 'w');
for j = 1:size(dT,3)
    fprintf(fm, 'Frame %d:\n', j);
    for i = 1:size(dT,1)
        fprintf(fm, '%.16g ', dT(i, :, j)*1000);
        fprintf(fm, '\n');
    end
end
fclose(fm);

% load from previously generated
% load(fullfile(workDir,motionFile), 'dT','T0');
% fm = fopen(fullfile(workDir,motionTxt), 'w');
% fprintf(fm, 'T0:\n');
% for i = 1:size(T0,1)
%     fprintf(fm, '%.16g ', T0(i,:)*1000);
%     fprintf(fm, '\n');
% end
% for j = 1:size(dT,3)
%     fprintf(fm, 'Frame %d:\n', j);
%     for i = 1:size(dT,1)
%         fprintf(fm, '%.16g ', dT(i, :)*1000);
%         fprintf(fm, '\n');
%     end
% end
% fclose(fm);
% N = size(dT, 3);

% generate every frame
for i = 0:N
    if i > 0
        T = T0 + dT(:,:,i);
    else
        T = T0;
    end
    sdFile = fopen(fullfile(workDir,'sceneData.txt'), 'w');
    T(:,2) = -T(:,2); % transform to POV-Ray's coordinate system
    for j = 1:size(T,1)
        fprintf(sdFile, '%.16g,', T(j,:));
        fprintf(sdFile, '\n');
    end
    fclose(sdFile);
    jsonFilePath = fullfile(workDir, sprintf('%s_%04d.json', lfFilePrefix, i));
    LFWriteMetadata(jsonFilePath, param);
    LFRenderJson(jsonFilePath, skipExist);
    
    % render a color coded image
    % used to compute ground truth flow
    param0 = param;
    param0.extraOpt = [param.extraOpt ' Declare=COLOR_CODED=1'];
    param0.camParam.lfSamples = [1 1 1 1];
    param0.camParam.noise.enabled = 0;
    jsonFilePath = fullfile(workDir, sprintf('cc-%s_%04d.json', lfFilePrefix, i));
    LFWriteMetadata(jsonFilePath, param0);
    LFRenderJson(jsonFilePath, skipExist);
end

%% calc gt flow and gt alpha
cdFile = fopen(fullfile(workDir,'colorData.txt'),'r');
colors = fscanf(cdFile,'%f,',[3,Inf]);

imcc = imread(fullfile(workDir, sprintf('cc-%s_%04d.png', lfFilePrefix, 0)));
sz = param.camParam.resol;

if isa(imcc, 'uint8')
    colors = colors * 255;
elseif isa(imcc, 'uint16')
    colors = colors * 65535;
end

for j = 1:N
    gtFlowx = zeros(sz);
    gtFlowy = zeros(sz);
    gtFlowz = zeros(sz);
    for i = 1:size(dT,1)
        mask = imcc(:,:,1)==colors(1,i)&imcc(:,:,2)==colors(2,i)...
            &imcc(:,:,3)==colors(3,i);
        gtFlowx(mask) = dT(i,1,j);
        gtFlowy(mask) = dT(i,2,j);
        gtFlowz(mask) = dT(i,3,j);
    end
    save(fullfile(workDir,sprintf('gtflow_%04d.mat',j)),'gtFlowx','gtFlowy','gtFlowz');
end

% delete cc images
for j = 0:N
    for k = 0:1
        delete(fullfile(workDir, sprintf('cc-%s_%04d-f%d.png', lfFilePrefix, j, k)));
    end
    delete(fullfile(workDir, sprintf('cc-%s_%04d.json', lfFilePrefix, j)));
end
