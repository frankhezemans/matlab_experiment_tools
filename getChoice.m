function [choice,ACC,tPress] = getChoice(firstLevel,secondLevel,varargin)
%GETCHOICE Records which of two keys was pressed, and determines whether
%this was the appropriate response. Useful in the context of
%two-alternative forced choices.
%
%   Mandatory input:
%       firstLevel      intensity value of the first option, e.g.
%                       orientation of Gabor patch, loudness of beep tone,
%                       etc.
%       secondLevel     intensity value of the second option.
%   Optional input:
%       firstKey        key code for choosing the first option. Default is
%                       37 (left arrow key).
%       secondKey       key code for choosing second option. Default is 39
%                       (right arrow key).
%   Output:
%       choice          logical element representing the response. 0 is
%                       first option, 1 is second option.
%       ACC             logical element representing the accuracy of the
%                       response. 0 is incorrect, 1 is correct.
%       tPress          time (in seconds) of response.
%
%   Author: Frank H. Hezemans, August 2017
%
%   See also KBWAIT, GETSECS        

numvarargs = length(varargin);
if numvarargs > 2, error('requires at most 2 optional inputs'); end
% Default values for optional arguments
optargs = {37 39};
% Overwrite with those specified by user
optargs(1:numvarargs) = varargin;
% Place optional arguments in memorable variable names
[firstKey,secondKey] = optargs{:};
% Start checking response
choice = NaN;                               
while isnan(choice)                         % keep loop going until one of the two relevant keys has been pressed
    [~,key] = KbWait([],3);                 % wait for a response and get keycode
    if any(key([firstKey secondKey]))       % check if the pressed key is one of the two relevant keys
        tPress = GetSecs;                   % get time index
        if key(firstKey), choice = 0;       % first alternative chosen
        elseif key(secondKey), choice = 1;  % second alternative chosen
        end
    end
    WaitSecs(0.01);                         % wait a little bit to avoid killing the CPU
end
% Determine accuracy
if choice==0 && firstLevel>secondLevel...   % correct answer
        || choice==1 && secondLevel>firstLevel
    ACC = 1;
elseif choice==0 && secondLevel>firstLevel...% incorrect answer
        || choice==1 && firstLevel>secondLevel
    ACC = 0;
end
end