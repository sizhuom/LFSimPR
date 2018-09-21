function LFRenderJson( jsonFile, skipExist )
%LFRENDERJSON Render a light field according to a .json configuration
%NOTE: coordinates used in the .json files are specified using right-handed
%coordinate system now (y-axis pointing downward)

[path, fname, ~] = fileparts(jsonFile);
setting = LFReadMetadata(jsonFile);
if ~isfield(setting, 'outFile')
    setting.outFile = fullfile(path, [fname '.png']);
end
if nargin < 2
    skipExist = false;
end

setting.camParam.camFile = fullfile(path, [fname '_cam.inc']);
    
if strcmp(setting.type, 'user-defined')
    LFRenderUD(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, skipExist);
    getCentral(setting.outFile);
elseif strcmp(setting.type, 'array')
    LFRenderAP(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, false, skipExist);
    getCentral(setting.outFile);
elseif strcmp(setting.type, 'array-sa')
    LFRenderAP(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, true, skipExist);
elseif strcmp(setting.type, 'stereo')
    LFRenderS(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, skipExist);
elseif strcmp(setting.type, 'stereo2')
    Knew = LFRenderS2(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, skipExist);
    settingNew = LFReadMetadata(jsonFile);
    settingNew.camParam.K0 = Knew{1};
    settingNew.camParam.K1 = Knew{2};
    LFWriteMetadata(jsonFile, settingNew);
elseif strcmp(setting.type, 'perspective')
    LFRenderP(setting.libDir, setting.povFile, setting.camParam, setting.outFile, setting.extraOpt, skipExist);
else
    fprintf('Undefined camera type. Terminated.\n');
end

delete(setting.camParam.camFile);

end

