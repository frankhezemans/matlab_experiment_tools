function [position,RT,answered] = slideScale(screenPointer,question,windowrect,labels,varargin)
%SLIDESCALE draws a continuous scale and statement to the screen, and
%returns the level of (dis)agreement, reaction time, and a logical element
%indicating whether or not a response was made. The scale itself has a
%'banded' design (alternating filled segments of black and grey) to
%minimise response bias.
%
%   Mandatory input:
%       screenPointer       number that identifies the on-screen window, to
%                           be used for all Screen() commands.
%       question            text string containing the question / statement
%       windowrect          vector containing the dimensions of the
%                           on-screen window. Can be obtained with
%                           Screen('Rect'), should be [0 0 width height].
%       labels              2 element cell of strings representing the
%                           labels of the extremes of the scale. E.g.
%                           {'disagree' 'agree'}.
%   Optional input:
%       bgColour            RGB vector specifying the background colour of
%                           the screen. Default is white ([1 1 1]).
%       sliderHeight        integer specifying the height of the slider in
%                           pixels. Default is 15.
%       sliderStartPos      string label indicating the starting position
%                           of the slider on the scale. Default is 'random'
%                           to avoid response bias; other options are
%                           'left', 'center', and 'right'.
%       sliderCol           RGB vector specifying the colour of the slider.
%                           Default is red ([1 0 0]).
%       width               Integer specifying the thickness of the scale
%                           in pixels. Default is 5.
%       scaleLength         Fraction specifying the length of the scale.
%                           Default is 0.9 (i.e. 90% of screen width).
%       scalePos            Fraction specifying the vertical position of
%                           the scale. Default is 0.5; 0 is top, 1 is
%                           bottom.
%       readTime            integer specifying the minimum time in seconds
%                           before a response is registered. Default is 1.
%                           Useful to catch premature or accidental mouse
%                           clicks.
%       warningTime         integer specifying the time in seconds from
%                           initial presentation after which a warning to
%                           answer as soon as possible will be presented.
%                           Default is 30 seconds.
%       abortTime           integer specifying time in seconds from initial
%                           presentation after which the function will be
%                           aborted. Default is 60 seconds.
%       numBands            integer specifying the number of black/gray
%                           bands that make up the scale. Default is 10.
%                           Warning: must be even number.
%   Output:
%       position            integer indicating the position of the slider
%                           at the time of response. Value is relative to
%                           centre: Slider at left extreme yields -100,
%                           slider at right extreme yields 100.
%       RT                  response time in seconds.
%       answered            logical element indicating whether a response
%                           was given or not. If no response has been given
%                           within abortTime, this argument will be 0.
%
%   Author: Frank H. Hezemans, August 2017
%   Acknowledgement 1: This function is essentially an edited version of
%   the slideScale function written by Joern Alexander Quent, available
%   here: https://github.com/JAQuent/functions-for-matlab/blob/master/slideScale.m
%   Acknowledgement 2: The banded scale design was taken from the following
%   publication: https://www.autodeskresearch.com/publications/effect-visual-appearance-performance-continuous-sliders-and-visual-analogue-scales

%% Input arguments
% Deal with mandatory input
screenX = windowrect(3);
screenY = windowrect(4);
centerX = round(screenX/2);
% Deal with optional input
numvarargs = length(varargin);
if numvarargs > 11, error('requires at most 11 optional inputs'); end
% Default values for optional arguments
optargs = {[1 1 1] 15 'random' [1 0 0] 5 0.9 0.5 1 30 60 10};
% Skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin); % credit to Loren Shure: https://blogs.mathworks.com/loren/2009/05/12/optional-arguments-using-empty-as-placeholder/
% Overwrite with those specified by user
optargs(newVals) = varargin(newVals);
% Place optional arguments in memorable variable names
[bgColour,sliderHeight,sliderStartPos,sliderCol,width,scaleLength,...
    scalePos,readTime,warningTime,abortTime,numBands] = optargs{:};
%% Prepare for drawing scale and labels
left = screenX*(1-scaleLength);
right = screenX*scaleLength;
% Define size of each band of the scale in pixels
lineIncrement = (right-left)/numBands;
% Set colour for each band of the scale:
% Create a 3x(2*numBands) RGB-matrix, where each pair of columns correspond
% to the colour of one band of the scale.
scaleColor = repmat([0 0 (2/3) (2/3); 0 0 (2/3) (2/3); 0 0 (2/3) (2/3)],[1,(numBands/2)]);
% Set coordinates for scale segments:
lineX = NaN(1,(numBands*2));
lineX(1) = left;
for i = 2:length(lineX)
    if mod(i,2)==0 %Even number
        lineX(i) = lineX(i-1)+lineIncrement;
    elseif mod(i,2)==1 %Uneven number
        lineX(i) = lineX(i-1);
    end
end
lineY = repmat(screenY*scalePos,[1,(numBands*2)]);
lineCoord = [lineX;lineY];
%% Initialise slider position
if strcmp(sliderStartPos,'right'), x = right;
elseif strcmp(sliderStartPos,'center'), x = centerX;
elseif strcmp(sliderStartPos,'left'), x = left;
elseif strcmp(sliderStartPos,'random'), x = randsample(linspace(left,right),1);
else error('Only right, center, left and random are possible start positions');
end
SetMouse(round(x),round(screenY*scalePos)); % y position is locked to scalePos
%% Scale loop
t0 = GetSecs; % get time index prior to start of loop, to compute RT
answered = false;
while ~answered
    [x,~,buttons] = GetMouse(screenPointer, 1); % get current mouse status
    secs = GetSecs; % time index to link to output arguments of GetMouse()
    % Make sure slider doesn't go out of bounds
    if x > right, x = right;
    elseif x < left, x = left;
    end
    % Draw the question / statement
    DrawFormattedText(screenPointer,question,'center','center',[0 0 0],...
        [],[],[],[],[],[left (scalePos*screenY-0.15*screenY) right (scalePos*screenY-0.05*screenY)]); 
    % Drawing the scale's extreme labels
    DrawFormattedText(screenPointer,labels{1},'center','center',[0 0 0],... % left label
        [],[],[],[],[],[(left-(0.075*screenX)) (screenY*scalePos+screenY*0.05) (left+(0.075*screenX)) (screenY*scalePos+screenY*0.15)]);
    DrawFormattedText(screenPointer,labels{2},'center','center',[0 0 0],... % right label
        [],[],[],[],[],[(right-(0.075*screenX)) (screenY*scalePos+screenY*0.05) (right+(0.075*screenX)) (screenY*scalePos+screenY*0.15)]);    
    % Draw the scale
    Screen('DrawLines',screenPointer,lineCoord,width,scaleColor);
    % Draw the slider
    Screen('DrawLine',screenPointer,sliderCol,...
        x,screenY*scalePos-sliderHeight,x,screenY*scalePos+sliderHeight,width);
    % Flip everything to the screen
    Screen('Flip',screenPointer);
    % Check if answer has been given
    if buttons(1) == 1, answered = true; end % left mouse button
    % Check timing:
    % Disregard premature responses
    if secs - t0 <= readTime, answered = false; end
    % Give warning if answer takes too long
    if secs - t0 > warningTime
        DrawFormattedText(screenPointer,'Please indicate how true this is of you right now','center','center',...
            [1 0 0],[],[],[],[],[],[left (scalePos*screenY+0.1*screenY) right (scalePos*screenY+0.2*screenY)]);
    end
    % Abort if answer takes way too long
    if secs - t0 > abortTime, break; end
end
% If answered, briefly keep displaying the slider in its position at the
% time of answer, so that participant can properly process the outcome of
% their mouse click
if answered
    WaitSecs('UntilTime',secs+0.2);
end
%% Write output
t1 = GetSecs; % get final timestamp
% Briefly present a blank screen, so that the (potential) transition to the
% next question in the loop is less abrupt
Screen('FillRect',screenPointer,bgColour);
Screen('Flip',screenPointer);
% Initialise output arguments
[RT,position] = deal(NaN);
if answered
    RT = secs - t0; % RT in seconds
    position = round(x) - centerX;  % absolute position of slider relative to center of screen (i.e. center of scale)
    position = (position/(centerX-left))*100; % calculate position as percentage distance from center to either extremes
end
% Wait until blank screen has been shown for 2 tenths
WaitSecs('UntilTime',t1+0.2);
end