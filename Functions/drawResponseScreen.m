function drawResponseScreen( display, buttonSize, buttonLabels, buttonList, buttonColour, outlineWidth, outlineColour )
%DRAWRESPONSESCREEN Draws a response screen showing labelled buttons in a
% RESPONSEPixx configuration.
%   
%   DRAWRESPONSESCREEN(display) will draw a five-button configuration
%   labelled with arrows (up, down, left, right) and a cross (centre). Each
%   button has a diameter of 100 pixels, with 50 pixel spacing. 'display'
%   is a structure, and the field display.ptbWindow is required; otherwise,
%   nothing will draw. The field display.centre is also required if you
%   want the elements centred; the two elements of the vector should give
%   the x-centre and the y-centre pixels, in that order. This defaults to
%   [640, 512] (i.e., centred on a 1280 x 1024 screen).
%   
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize) also sets the diamter of the
%   button in pixels. Spacing is (buttonSize/2) pixels. Defaults to 100.
%
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize, buttonLabels) lets you pass a
%   list of labels as a cell array of strings. If this argument is passed
%   but the following buttonList argument is not, the number of buttons
%   shown is determined by the number of elements in this list. A single
%   button is always the centre button; two buttons is (1) left and (2) 
%   right; three is (1) left, (2) centre and (3) right; four is (1) top,
%   (2) left, (3) right and (4) bottom; and five is (1) top, (2) left, (3)
%   centre, (4) right and (5) bottom.
%
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize, buttonLabels, buttonList)
%   lets you pass a list of buttons to display. If both buttonLabels and
%   buttonList are passed, they must have the same number of elements;
%   otherwise this argument is silently ignored. References are (1) right,
%   (2) top, (3) left, (4) bottom, (5) centre. You can pass them out of
%   order; if you do, the labels will be shuffled accordingly (i.e., if you
%   put '3' as the first element, the left button will take the first label
%   in the buttonLabels argument).
%
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize, buttonLabels, buttonList,
%   buttonColour) lets you specify the colour of the button background. 
%   This is actually just a luminance value from 0 (black) to 1 (white), 
%   not a colour. Defaults to white. Note that the text colour (and other
%   properties) should be set prior to calling this function.
%
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize, buttonLabels, buttonList,
%   buttonColour, outlineWidth) lets you add an outline to the button. This
%   argument should give the desired outline width in pixels. Defaults to
%   zero (no outline). If you only want an outline, set the buttonColour
%   argument to match your background colour.
%
%   DRAWRESPONSESCREEN(ptbWindow, buttonSize, buttonLabels, buttonList,
%   buttonColour, outlineWidth, outlineColour) also lets you specify the
%   colour (luminance, from 0 to 1) of the outline. Defaults to 0 (black),
%   if the outlineWidth argument is non-zero.
%
%   Note again that if you need to set font properties, you can do so prior 
%   to calling the function.

    if (nargin < 1) || isempty(display) || ~isfield(display,'ptbWindow')
        warning('drawResponseScreen:noWindowSupplied','No PsychToolbox window was supplied! Nothing drawn.');
    else    

        if (nargin < 7) || isempty(outlineColour)
            outlineColour = 0;
        end
        
        if (nargin < 6) || isempty(outlineWidth)
            outlineWidth = 0;
        end
        
        if (nargin < 5) || isempty(buttonColour)
            buttonColour = 1;
        end
            
        if (nargin < 4) || isempty(buttonList)
            if (nargin < 3) || (isempty(buttonLabels))
                buttonList = 1:5;
            elseif numel(buttonLabels)==1
                buttonList = 5;
            elseif numel(buttonLabels)==2
                buttonList = [1 3];
            elseif numel(buttonLabels)==3
                buttonList = [1 3 5];
            elseif numel(buttonLabels)==4
                buttonList = 1:4;
            else
                buttonList = 1:5;
            end
        end

        if (nargin < 3) || isempty(buttonLabels)
            buttonLabels = {'>','^','<','v','x'};
            buttonLabels = buttonLabels(buttonList);
        end

        if (nargin < 2) || isempty(buttonSize)
            buttonSize = 100;
        end
        
        if ~isfield(display,'centre') || isempty(display.centre)
            display.centre = [640 512];
        elseif numel(display.centre)==1
            display.centre = display.centre*ones(1,2);
        end
        
        % Get rect info
        buttonRect = [0 0 buttonSize-1 buttonSize-1];
        buttonCentres = [ 1.5*[buttonSize 0 -buttonSize 0 0]+display.centre(1); 1.5*[0 -buttonSize 0 buttonSize 0]+display.centre(2)];
        buttonCentres = buttonCentres(:,buttonList);
        nButtons = min([numel(buttonList) 5]);
        
        % Draw buttons
        for thisButton = 1:nButtons
            Screen('FillOval', display.ptbWindow, buttonColour, ...
                CenterRectOnPoint(buttonRect, buttonCentres(1, thisButton), ...
                buttonCentres(2, thisButton)));
        end
        
        % Draw button outlines
        if outlineWidth > 0
            for thisButton = 1:nButtons
                Screen('FrameOval', display.ptbWindow, outlineColour, ...
                    CenterRectOnPoint(buttonRect, buttonCentres(1, thisButton), ...
                    buttonCentres(2, thisButton)), outlineWidth);
            end
        end
        
        % Draw labels
        for thisButton = 1:nButtons
            textRect = Screen('TextBounds', display.ptbWindow, buttonLabels{thisButton});
            textRect = CenterRectOnPoint(textRect, buttonCentres(1, thisButton), ...
                    buttonCentres(2, thisButton));
            Screen('DrawText', display.ptbWindow, buttonLabels{thisButton}, ...
                textRect(1), textRect(2));
        end
        
    end
    
end
