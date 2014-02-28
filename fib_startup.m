function fib_startup
%
% Initialize and launch Fibonacci application
%

warning off %#ok<WNOFF>

% Define application root directory
root_dir = fileparts(mfilename('fullpath'));

% Add in path all source directories of application
addpath(fullfile(root_dir, 'data'))
addpath(fullfile(root_dir, 'src', 'gui'))
addpath(fullfile(root_dir, 'src', 'matlab'))

% Change current directory to work (create if not already exist)
if ~exist(fullfile(root_dir, 'work'), 'file')
    mkdir(fullfile(root_dir, 'work'));
end
%cd(fullfile(root_dir, 'work'))

warning on %#ok<WNON>

% Launch Fibonacci application
fibonacci
