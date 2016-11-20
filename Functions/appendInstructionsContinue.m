function [ nx, ny, textBounds, flipTime ] = appendInstructionsContinue( ptbWindow, buttonText, fontProperties, sy, dontFlip )
%APPENDINSTRUCTIONSCONTINUE Appends instructions to 'press a button to
%continue' to an existing page of instructions.
%   APPENDINSTRUCTIONSCONTINUE(ptbWindow) displays the text 'Press any
%   button to continue.' The function is intended (although need not) be
%   called after readInstructions and a call to showInstructions to display
%   a single page of instructions. The input argument ptbWindow should
%   contain the index to the relevant PsychToolbox window.
%
%   APPENDINSTRUCTIONSCONTINUE(ptbWindow, buttonText) allows you to pass a
%   string specifying the button to press. The string is inserted, with
%   flanking spaces, between the strings 'Press ' and ' to continue.'. For
%   example, buttonText='the left button' would yield 'Press the left
%   button to continue.'.
%
%   APPENDINSTRUCTIONSCONTINUE(ptbWindow, buttonText, fontProperties)
%   also allows you to specify font properties. If the fontProperties 
%   argument is omitted, default settings will be used. The typeface, size
%   and style are inherited from the current settings for the window
%   (perhaps set with the previous call to showInstructions).
%   fontProperties should be a structure with any or all of the following 
%   fields:
%
%   fontProperties.colour
%   fontProperties.sx
%   fontProperties.sy
%   fontProperties.wrapAt
%   fontProperties.flipHorizontal
%   fontProperties.flipVertical
%   fontProperties.vSpacing
%   fontProperties.rightToLeft
%   fontProperties.winRect
%
%   For behaviour of these fields, type help DrawFormattedText
%   
%   APPENDINSTRUCTIONSCONTINUE(ptbWindow, buttonText, fontProperties, sy)
%   allows you to override the starting y-coordinate specified in the
%   fontProperties structure (fontProperties.sy). This means you can retain
%   the same default/global setting in your fontProperties structure (e.g.
%   for future calls to showInstructions) but specify where you want the
%   continue text to be appended. A useful starting point for this value 
%   is the ny (next-y) argument output by showInstructions. Note that this
%   value specifies the *baseline* of the (first line of) text.
%
%   APPENDINSTRUCTIONSCONTINUE(ptbWindow, buttonText, fontProperties, sy,
%   dontFlip) allows you to prevent the screen from flipping. Instead, the
%   instruction text is just drawn into the window, to be displayed at some
%   later point. This is useful if you want to synchronise the appearance
%   of the new text with the start of your response box recording. If using
%   waitForButtonPressRESPONSEPixx, set the flipAtStart argument for that
%   function to 2; that way, the screen will be flipped without clearing
%   the framebuffer, and your text will be appended to (rather than
%   replace) what is already on the screen.
%
%   [nx, ny] = APPENDINSTRUCTIONSCONTINUE(ptbWindow) returns the 
%   new (x,y) position of the text drawing cursor, which can be used as a 
%   new start position for appending additional strings.
%
%   [nx, ny, textBounds] = APPENDINSTRUCTIONSCONTINUE(ptbWindow) 
%   also returns the approximate bounding rectangle of the drawn string.
%
%   [nx, ny, textBounds, flipTime] = APPENDINSTRUCTIONSCONTINUE(ptbWindow)
%   additionally returns the VBL timestamp of the flip as reported by the
%   Screen('Flip') command.

    if (nargin < 2) || isempty(buttonText)
        buttonText = 'any button';
    end

    if (nargin < 3) || isempty(fontProperties)
        fontProperties = struct;
    end
    
    if (nargin < 4) || isempty(sy)
        sy = NaN;
    end

    if (nargin < 5) || isempty(dontFlip)
        dontFlip = 0;
    end

    if ~isfield(fontProperties,'colour')        % Check whether colour is specified
        if isfield(fontProperties,'color')          % Check and correct U.S. spelling
            fontProperties.colour = fontProperties.color;       % Copy the contents of the field
            fontProperties = rmfield(fontProperties,'color');	% Remove the original field
        else                                    % Otherwise
            fontProperties.colour = [];             % Use default (last used) value
        end
    end

    % Check other fields of fontProperties and assign default if they are
    % not specified.
    
    if ~isfield(fontProperties,'sx')
        fontProperties.sx = 'center';
    end

    if ~isfield(fontProperties,'sy')
        fontProperties.sy = 'center';
    end
    
    if ~isfield(fontProperties,'wrapAt')
        fontProperties.wrapAt = [];
    end

    if ~isfield(fontProperties,'flipHorizontal')
        fontProperties.flipHorizontal = [];
    end

    if ~isfield(fontProperties,'flipVertical')
        fontProperties.flipVertical = [];
    end

    if ~isfield(fontProperties,'vSpacing')
        fontProperties.vSpacing = [];
    end

    if ~isfield(fontProperties,'rightToLeft')
        fontProperties.rightToLeft = [];
    end
    
    if ~isfield(fontProperties,'winRect')
        fontProperties.winRect = [];
    end
    
    if ~isnan(sy)
        fontProperties.sy = sy;
    end
    
    % Compile display text.
    displayText = ['Press ' buttonText ' to continue.'];
    
    % Now display the text.
    [nx, ny, textBounds] = DrawFormattedText(ptbWindow, displayText, ...
        fontProperties.sx, fontProperties.sy, fontProperties.colour, ...
        fontProperties.flipHorizontal, fontProperties.flipVertical, ...
        fontProperties.vSpacing, fontProperties.rightToLeft, ...
        fontProperties.winRect);
    
    if ~dontFlip
        flipTime = Screen('Flip', ptbWindow, [], 1);
    else
        flipTime = NaN;
    end

end

