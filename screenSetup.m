function screen = screenSetup(setup)
%SCREENSETUP Creates an on-screen window for presenting stimuli using
%Psychtoolbox-3 functions, and if necessary prepares image files to be
%drawn to the screen.
%
%   Optional input:
%       setup.bgcolour        - 3 element vector corresponding to red,
%                               green, and blue components. Default is
%                               white ([1 1 1]).
%       setup.screenID        - number of screen to which this setup should
%                               be applied. Can be obtained with
%                               Screen('Screens'). Default is 0, the full
%                               windows desktop.
%       setup.images{N}       - N by 2 cell array containing filenames of N
%                               images to be drawn to the screen. First
%                               column is filename, second column is file
%                               extension. For example, if we want to load
%                               one image called happy.jpg:
%                               setup.images = {'happy','jpg'};
%       setup.skipcheck       - should internal calibrations and display
%                               tests be performed? Default is 0 (yes). If
%                               1, tests will be limited to about 5 seconds
%                               in total; if 2, tests will be completely
%                               skipped (not recommended).
%       setup.nowarnings      - should the results of calibrations and
%                               display tests be printed to the command
%                               window? Default is 0 (yes). If 1, printout
%                               will be suppressed.
%   Output:
%       screen.w              - number that identifies the on-screen
%                               window, to be used for future Screen()
%                               commands.
%       screen.X              - width of screen in pixels
%       screen.Y              - height of screen in pixels
%       screen.ifi            - inter-frame-interval, the minimum possible
%                               time between drawing to the screen. Inverse
%                               of framerate.
%       screen.imgdata{N}     - cell array containing N arrays of image
%                               data [output of imread()] for N images.
%       screen.imgtexture(N)  - N indices for N images which may be passed
%                               to Screen('DrawTexture') to draw to the
%                               screen.
%
%   Author: Frank H. Hezemans, August 2017
%   Disclaimer: The basic setup section of this function is basically the
%   same as calling PsychDefaultSetup(2);
%
%   See also PSYCHDEFAULTSETUP

%% Basic setup
% Set global environment variable, colormode, such that the color range of
% all drawing commands is normalised (0-1, e.g. [1 0 0] is red)
global psych_default_colormode;
psych_default_colormode = 1;
% Assert that the correct version of Psychtoolbox is installed
AssertOpenGL;
% Unify keycode to keyname mapping across operating systems
clear KbName;
KbName('UnifyKeyNames');
% Perform various checks or not
if(isfield(setup,'skipcheck'))
    Screen('Preference','SkipSyncTests',setup.skipcheck);
end
% Suppress warnings or not
if(isfield(setup,'nowarnings'))
    Screen('Preference','SuppressAllWarnings',setup.nowarnings);
end
% Set screen number if necessary
if(~isfield(setup,'screenID'))
    setup.screenID = 0; % 0 is the main screen
end
% Set screen background colour if necessary
if(~isfield(setup,'bgcolour'))
    setup.bgcolour = [1 1 1];
end
%% Open window
screen.w = PsychImaging('OpenWindow',setup.screenID,setup.bgcolour); % returns ID code for future Screen() commands
% Query the window's properties
[screen.X,screen.Y] = Screen('WindowSize',screen.w); % screen dimensions in pixels
screen.ifi = Screen('GetFlipInterval',screen.w); % inter-frame-interval: ifi = 1/framerate
% Enable alpha blending for smooth (anti-aliased) objects
Screen('BlendFunction',screen.w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
% Set text font options
Screen(screen.w,'TextSize',32);
Screen(screen.w,'TextFont','Arial');
% Hide the cursor
HideCursor;
%% Prepare images
% Load images
if(isfield(setup,'images'))
    for i = 1:size(setup.images,1)
        screen.imgdata{i} = imread(setup.images{i,1},setup.images{i,2}); % first argument is filename, second argument is file extension
        % Prepare as texture to be drawn upon command
        screen.imgtexture(i) = Screen('MakeTexture',screen.w,screen.imgdata{i});
    end
end