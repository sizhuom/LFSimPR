function genNoise( inFile, outFile, noiseParam )
%GENNOISE Add noise to a synthesized light field

I = im2double(imread(inFile)) * noiseParam.intensity * noiseParam.time;
sigma = sqrt(I) + noiseParam.readout;
I = I + normrnd(0, sigma);
I = min(I, noiseParam.capacity);
I = max(I, 0);
I = I * noiseParam.gain;
imwrite(I, outFile);

end

