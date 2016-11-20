function drawFixationElements( ptbWindow, elements, pushBehind )
%DRAWFIXATIONELEMENTS Draws a fixation marker using PsychToolbox.
%
%   DRAWFIXATIONELEMENTS(ptbWindow, elements) draws the bullseye fixation 
%   marker whose elements have been specified using the 
%   prepareFixationElements function.
%
%   DRAWFIXATIONELEMENTS(ptbWindow, elements, pushBehind) optionally lets
%   you move the central circle of the bullseye behind the crosshairs.
%   Maybe you'd like to do that. I don't know. Defaults to 0 (off).

    if (nargin < 3) || isempty(pushBehind)
        pushBehind = 0;
    end

    if ~pushBehind
        Screen('FillOval', ptbWindow, elements.ovalColour(:,1), elements.ovalRect(:,1));
        Screen('DrawLines', ptbWindow, elements.lineXY, elements.lineWidth, elements.lineColour);
        Screen('FillOval', ptbWindow, elements.ovalColour(:,2), elements.ovalRect(:,2));
    else
        Screen('FillOval', ptbWindow, elements.ovalColour, elements.ovalRect);
        Screen('DrawLines', ptbWindow, elements.lineXY, elements.lineWidth, elements.lineColour);
    end

end

