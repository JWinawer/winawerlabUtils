function updateRepos(homedir, doSVN, doGIT)
% Updates Psychtoolbox and all github and svn repositories found in
%   homedir/git
%   homedir/svn
%
% updateRepos(homedir [fullfile('~', 'matlab')], doSVN [true], ...
%   doGIT [true], waitForUser [false])
%
% Jon Winawer, July, 2013

%% Check inputs
if ~exist('homedir', 'var'), homedir = fullfile('~', 'matlab'); end
if ~exist('doSVN', 'var'), doSVN = true; end
if ~exist('doGIT', 'var'), doGIT = true; end

fname = fullfile(tempdir, sprintf('updateReposLog %s', datestr(now, 'yyyy_mm_dd_HH_MM_SS')));
diary(fname);

%% Paths
if ismac
    % For mysterious reasons, on some Macs Matlab tinkers with the path to the
    % DYLD Library, and this interferes with calling git commands from
    % Matlab. So we get the current path, store it, change it while running
    % this function, and then restore it at the end of the function
    dyld = getenv('DYLD_LIBRARY_PATH');
    setenv('DYLD_LIBRARY_PATH', '/usr/local/bin')
end

% note the current directory so that we can return to it
curdir = pwd;

%% Subversion

if doSVN
    % We assume SVN directories are in home/matlab/svn
    pth = fullfile(homedir, 'svn');
    
    % get the potential svn directories
    d = dir(pth);
    
    % loop over directories and update each one
    for ii = 1:length(d)
        if d(ii).isdir && ~ismember(d(ii).name, {'.', '..'})
            fprintf('\n\n\n***********************************************\n');
            fprintf('********* Updating %s... ****\n', upper(d(ii).name)); drawnow
            disp('***********************************************');

            cd(fullfile(pth, d(ii).name))
            
            % update and display status
            system('svn update');
            system('svn status');
        end
    end
    
end

%% GIT
if doGIT
    % We assume GIT directories are in homedir/git/
    
    pth = fullfile(homedir, 'git');
    
    % get the potential git directories
    d = dir(pth);
    
    % loop over directories and update each one
    for ii = 1:length(d)
        if d(ii).isdir && ~ismember(d(ii).name, {'.', '..'})
            fprintf('\n\n\n***********************************************\n');
            fprintf('********* Updating %s... ****\n', upper(d(ii).name)); drawnow
            disp('***********************************************');
            
            cd(fullfile(pth, d(ii).name))
            
            % update and display status
            system('git pull');
            system('git status');
        end
    end
    
end

%% Clean up
cd(curdir)

% if we have a mac, we may need to restore the dyld path that we temporarily changed
if ismac
    setenv('DYLD_LIBRARY_PATH', dyld)    
end

diary off
edit(fname)