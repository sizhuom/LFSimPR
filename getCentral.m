function getCentral( lfFile )
%GETCENTRAL Get the central subaperture view of the light field

[path, fname, ~] = fileparts(lfFile);
params = LFReadMetadata(fullfile(path, [fname '.json']));
sz = params.camParam.resol;
lf = imread(fullfile(path, [fname '.png']));
lf = raw2LF(lf, sz);
im = squeeze(lf(round((1+sz(1))/2),round((1+sz(2))/2),:,:,:));
imwrite(im, fullfile(path, [fname '-central.png']));

end

