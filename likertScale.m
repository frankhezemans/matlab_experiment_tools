function [answer,RT,answered] = likertScale(screenPointer,question,screenX,screenY,labels,varargin)
%LIKERTSCALE This function draws a Likert scale (Likert, 1932, Archives of
% Psychology) on the screen, and returns the selected level of
% (dis)agreement to the statement, the reaction time, and a logical value
% indicating whether the question was actually answered or not.
%
% Mandatory input:
%   screenPointer   -> pointer to the window
%   question        -> text string containing the question / statement
%   screenX         -> width of screen in pixels
%   screenY         -> height of screen in pixels
%   labels          -> cell containing the text strings of the levels of
%                      agreement
%
% varargin:
%   'bgColour'      -> RGB vector specifying the background colour of
%                      the screen. Default is white ([1 1 1]).
%   'labelRect'     -> vector of doubles containing the dimensions of the
%                      option squares. Default is 5% of the screen width by
%                      5% of the screen height.
%   'startposition' -> start position of the mouse cursor. Choose 'left',
%                      'right', 'center', or 'random'. Default is random.
%   'readtime'      -> double specifying the time in seconds after
%                      presentation of the question, for which one cannot
%                      have reasonably read the question. Answers given
%                      within readtime will be disregarded. Default is 1
%                      second.
%   'warningtime'   -> double specifying the time in seconds after which a
%                      warning prompt should be presented. Default is 20
%                      seconds.
%   'aborttime'     -> double specifying the time in seconds after which
%                      the function should be aborted. In this case no
%                      answer is saved. That is, output argument 'answered'
%                      will be false.
%   'highlightColor'-> RGB vector specifying the color of a label square
%                      when the cursor is in it. Default is grey
%                      [0.5 0.5 0.5].
%   'cursorColour'  -> RGB vector specifying the colour of the cursor.
%                      Default is red [1 0 0].
%   'cursorSize'    -> Diameter in pixels of the cursor. Default is 15.
%
% Output:
%   'answer'        -> double specifying the level of agreement selected.
%                      Ranges from 1 (leftmost option, e.g. 'completely
%                      untrue') to the total number of labels, e.g. 5
%                      (rightmost option, e.g. 'completely true').
%   'RT'            -> reaction time in seconds
%   'answered'      -> logical: If 0, no answer has been given, if 1,
%                      answer has been given. Only relevant when
%                      'aborttime' is specified.
%
%   Author: Frank Hubert Hezemans
%   e-mail: Frank.Hezemans@mrc-cbu.cam.ac.uk

%% Input arguments
% Deal with mandatory input
centerX         = round(screenX/2);
centerY         = round(screenY/2);
nOptions        = length(labels);
optionColors    = ones(3,nOptions);
% Deal with optional input
numvarargs = length(varargin);
if numvarargs > 6, error('requires at most 6 optional inputs'); end
% Default values for optional arguments
optargs = {[1 1 1] [0 0 (0.05*screenX) (0.05*screenY)] 'random' 1 20 [] [0.5 0.5 0.5]' [1 0 0] 15};
% Skip any new inputs if they are empty
newVals = cellfun(@(x) ~isempty(x), varargin); % credit to Loren Shure: https://blogs.mathworks.com/loren/2009/05/12/optional-arguments-using-empty-as-placeholder/
% Overwrite with those specified by user
optargs(newVals) = varargin(newVals);
% Place optional arguments in memorable variable names
[bgColour,labelRect,startPosition,readtime,warningtime,aborttime,highlightColor,cursorColour,cursorSize] = optargs{:};
%% Prepare for drawing
left = 0.1*screenX;
right = 0.9*screenX;
% Get coordinates for square lables
optionCoord = NaN(4,nOptions);
for i = 1:nOptions
    optionCoord(:,i) = (CenterRectOnPointd(labelRect,((i/(nOptions+1))*screenX), centerY))';
end
% Set initial cursor position
if strcmp(startPosition, 'right'), x = right;
elseif strcmp(startPosition, 'center'), x = centerX;
elseif strcmp(startPosition, 'left'), x = left;
elseif strcmp(startPosition, 'random'), x = randsample(linspace(left,right),1);
else error('Only right, center, left and random are possible start positions');
end
SetMouse(round(x), centerY);
%% Scale loop
% Initialise arguments
t0          = GetSecs;
answered    = false;
% Loop the animation until an answer is given
while ~answered
    [x,~,buttons] = GetMouse(screenPointer,1);
    % Make sure cursor doesn't go out of bounds
    if x > right, x = right;
    elseif x < left, x = left;
    end
    % Draw the question as text
    DrawFormattedText(screenPointer, question, 'center','center', [0 0 0],[],[],[],[],[],...
        [left (optionCoord(2,1)-0.2*screenY) right (optionCoord(4,i)-0.05*screenY)]); 
    % Draw the option labels as text
    for i = 1:nOptions
        DrawFormattedText(screenPointer,labels{i},'center','center',[0 0 0],[],[],[],[],[],...
            [(optionCoord(1,i)-0.1*screenX) (optionCoord(4,i)+0.025*screenY) (optionCoord(3,i)+0.1*screenX) (optionCoord(4,i)+0.1*screenY)]);
    end
    % See if the mouse cursor is inside one of the square labels, and set
    % the color of the square accordingly
    for i = 1:nOptions
        if x >= optionCoord(1,i) && x <= optionCoord(3,i)
            optionColors(:,i) = highlightColor;
        else optionColors(:,i) = [1 1 1];
        end
    end
    % Draw the option squares to the screen
    Screen('FillRect', screenPointer, optionColors, optionCoord);
    Screen('FrameRect', screenPointer, [0 0 0], optionCoord);
    % Draw a dot where the mouse cursor is
    Screen('DrawDots', screenPointer, [x centerY],cursorSize,cursorColour, [], 2);
    % Flip everything to the screen
    Screen('Flip', screenPointer);    
    % Check if answer has been given:
    % Has the mouse button been clicked?
    % Was the cursor actually inside one of the squares (i.e. were any of
    % the squares highlighted - were any RGB values not 1) at the time of
    % the click?
    secs = GetSecs;
    if buttons(1) == 1 && any(any(optionColors~=1)), answered = true;
    end
    % Disregard early responses
    if secs - t0 <= readtime, answered = false;
    end
    % Warning if answer takes too long
    if secs - t0 > warningtime
        DrawFormattedText(screenPointer, 'Please indicate how true this is of you right now.', 'center', (0.75*screenY), [1 0 0]);
    end
    % Abort if answer takes too long
    if ~isempty(aborttime) && secs - t0 > aborttime, break
    end
end
%% Deal with response
if answered
    % Check which answer was selected
    for i = 1:nOptions
        if x >= optionCoord(1,i) && x <= optionCoord(3,i), answer = i;
        end
    end
    % Save RT
    RT = secs - t0;
else [answer,RT] = deal(NaN);
end
% If the participant answered, briefly make the border of the selected
% option thicker
if isfinite(answer)
    t0 = GetSecs;
    DrawFormattedText(screenPointer, question, 'center','center', [0 0 0],[],[],[],[],[],...
        [left (optionCoord(2,1)-0.2*screenY) right (optionCoord(4,i)-0.05*screenY)]);
    for i = 1:nOptions
        DrawFormattedText(screenPointer,labels{i},'center','center',[0 0 0],[],[],[],[],[],...
            [(optionCoord(1,i)-0.1*screenX) (optionCoord(4,i)+0.025*screenY) (optionCoord(3,i)+0.1*screenX) (optionCoord(4,i)+0.1*screenY)]);
    end
    Screen('FillRect', screenPointer, optionColors, optionCoord);
    Screen('FrameRect', screenPointer, [0 0 0], optionCoord);
    Screen('FrameRect', screenPointer, [0 0 0], optionCoord(:,answer),3);
    Screen('Flip',screenPointer);
    WaitSecs('UntilTime',t0+0.2);
end
t1 = GetSecs;
% Briefly present a blank screen, so that the (potential) transition to the
% next question in the loop is less abrupt
Screen('FillRect',screenPointer,bgColour);
Screen('Flip',screenPointer);
% Wait until blank screen has been shown for 2 tenths
WaitSecs('UntilTime',t1+0.2);
end