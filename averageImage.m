function averageImage( finNames, foutName )
%AVERAGEIMAGE Compute the average of a list of images

imout = im2double(imread(finNames{1}));

for i = 2:numel(finNames)
    im = im2double(imread(finNames{i}));
    imout = imout + im;
end

imout = imout / numel(finNames);
imwrite(imout, foutName);

end

