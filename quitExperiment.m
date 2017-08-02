function [skip,quit] = quitExperiment(screenPointer,quitKey)
%QUITEXPERIMENT Draws text to the screen in case the escape key has been
%pressed, and returns a logical index in case the escape key is
%subsequently pressed once more.
%
%   Mandatory input:
%       screenPointer - number that identifies the on-screen window.
%   Optional input:
%       quitKey         key code for quitting. Default is 27 (escape key).
%   Output:
%       skip          - logical element that can be used in the trials loop
%                       of the experiment script to skip to the next trial.
%       quit          - logical element that can be used in the trials loop
%                       of the experiment script to quit the experiment.
%
%   Author: Frank H. Hezemans, August 2017
%   See also KBCHECK, KBWAIT

if nargin == 1, quitKey = 27;
end
[skip,quit] = deal(false);                      % initialise logical output arguments
[~,~,key] = KbCheck;                            % get logical array representing keyboard status
if key(quitKey)                                 % if the escape key is pressed...
    skip = true;                                % the remainder of this trial should be skipped
    Screen('FillRect',screenPointer,[1 1 1]);   % flush the screen (white)
    DrawFormattedText(screenPointer,'You pressed the escape key.\n\n\nAre you sure you want to quit the experiment?\n\n\nPress escape if yes, press any other key if no.',...
        'center','center',[0 0 0]);             % present instructions
    Screen('Flip',screenPointer);               % flip everything to the screen
    [~,key] = KbWait([],3);                     % wait for subsequent key press
    if key(quitKey), quit = true; end           % if escape key is pressed once more, we quit the entire experiment
end
end