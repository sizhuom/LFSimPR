function initPath
%INITPATH Initialize the path settings for the library
fprintf('Setting up the paths and global variables for LFSimPR...');
p = mfilename('fullpath');
[dir, ~, ~] = fileparts(p);
addpath(dir);

fprintf('Done.\n');

end

