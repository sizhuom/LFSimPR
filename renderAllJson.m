function renderAllJson(path, skipExist)
if nargin == 0
    path = '';
end
if nargin < 2
    skipExist = false;
end
listing = dir(fullfile(path, '*.json'));
for i=1:length(listing)
    try
        [~,fname,~] = fileparts(listing(i).name);
        if ~exist(fullfile(path,[fname '.png']),'file') || ~skipExist
            LFRenderJson(fullfile(path,listing(i).name));
        end
    catch ME
        fprintf('%s\n', getReport(ME));
        fprintf('Error occurred. Go to next job.\n');
    end
end

end