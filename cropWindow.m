function [ imc ] = cropWindow( im, camParam )
%CROPWINDOW Crop the window off the simulated perspective image

[~, param] = genIntrinsicsP2(camParam.resol, camParam.apert, camParam.fov,...
    camParam.fLen, camParam.SA);

% find the x,y coordinates of one of the corner of the projected window on
% the image plane
h = camParam.window(1) * param.sm;
w = camParam.window(2) * param.sm;
dM = param.dM;
dm = param.dm;
ax = param.SA(1);
ay = param.SA(2);

x = ax-(ax-w/2)*(dm+dM)/dM;
y = ay-(ay-h/2)*(dm+dM)/dM;

% conver the x,y coordinates into pixel indices
sp = param.sp;
np = param.np;
nu = param.nu;
nv = param.nv;
H1 = [sp 0 0;
      0 sp 0;
      0 0 1;];
% center H1
p_cen = [(1+np*nu)/2,(1+np*nv)/2,1]';
offset = [0;0;1] - H1 * p_cen;
H1(1:2,3) = offset(1:2);
indh = ceil(H1 \ [x;y;1]);
indl = floor(H1 \ [-x;-y;1]);

% crop
imc = zeros(size(im));
imc(indl(2):indh(2),indl(1):indh(1),:) = im(indl(2):indh(2),indl(1):indh(1),:);

end

