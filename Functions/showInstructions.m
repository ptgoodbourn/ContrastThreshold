function [ nx, ny, textBounds, flipTime, oldProperties ] = showInstructions( ptbWindow, iArray, thisPage, theseVariables, fontProperties, flipType )
%SHOWINSTRUCTIONS Displays instructions read in with readInstructions.
%   Uses PsychToolbox to display a page of instruction text from an array
%   read in using the readInstructions function.
%
%   SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage) shows the page specified 
%   in thisPage from the array iArray, in the PsychToolbox window
%   ptbWindow.
%
%   SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage, theseVariables) 
%   additionally allows you to specify text to be inserted to replace the 
%   placeholder character sequence of three percentage symbols (%%%). This 
%   means you can use the same instuction page and, for example, increment 
%   the trial or block number (e.g. 'You have completed %%% trials' can 
%   become 'You have completed 10 trials'). If there are multiple 
%   placeholders, pass them in order of appearance in a single cell array 
%   or vector. The function will try to handle numerical arguments and 
%   convert them into strings, but the safest way is probably to pass
%   strings if possible.
%
%   SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage, theseVariables, fontProperties)
%   also allows you to specify font properties. If the fontProperties 
%   argument is omitted, the current settings for size, typeface, style and
%   colour, and  default settings for other properties, will be used. 
%   fontProperties  should be a structure with any or all of the following 
%   fields:
%
%   fontProperties.typeFace
%   fontProperties.faceStyle
%   fontProperties.pointSize
%   fontProperties.textStyle
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
%   For the behaviour of typeFace and faceStyle, type Screen TextFont?
%   For the behaviour of pointSize type Screen TextSize?
%   For the behaviour of textStyle type Screen TextStyle?
%   For behaviour of all other fields, type help DrawFormattedText
%
%   SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage, theseVariables, fontProperties, flipType)
%   allows you to prevent the screen from flipping (flipType==0). Instead,
%   instruction text is just drawn into the window, to be displayed at some
%   later point. By setting flipType==2, the screen will flip but the
%   framebuffer will not be cleared. This is useful for incremental
%   presentation of text (e.g. a 'press a button to continue' message). See
%   appendInstructionsContinue for more about that.
%
%   [nx, ny] = SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage) returns the 
%   new (x,y) position of the text drawing cursor, which can be used as a 
%   new start position for appending additional strings.
%
%   [nx, ny, textBounds] = SHOWINSTRUCTIONS(ptbWindow, iArray, thisPage) 
%   also returns the approximate bounding rectangle of the drawn string.
%
%   [nx, ny, textBounds, flipTime] = SHOWINSTRUCTIONS(ptbWindow...)
%   additionally returns the VBL timestamp of the flip as reported by the
%   Screen('Flip') command.
%
%   [nx, ny, textBounds, flipTime, oldProperties] = SHOWINSTRUCTIONS(ptbWindow...) 
%   returns a structure containing the old values of any fields changed
%   using the fontProperties argument.
%
%   31/08/16 PTG wrote it.
%
%   14/02/17 PTG fixed a bug caused by a missing argument in the call to
%   DrawFormattedText.

    oldProperties = struct;     % Make a structure to store changed properties

    if nargin < 4 || isempty(theseVariables)    % Check whether variables have been passed to the function
        theseVariables = [];                        % If not, create an empty vector of variables
    end

    if nargin < 5 || isempty(fontProperties)    % Check whether font properties have been passed to the function
        fontProperties = struct;                    % If not, create an empty structure for font properties
    end
    
    if nargin < 6 || isempty(flipType)          % Check whether the flipType argument is present
        flipType = 1;                               % If not, set it to 1 (flip as usual)
    end

    if isfield(fontProperties,'typeFace')   % Check whether typeface is specified
        if ~isfield(fontProperties,'faceStyle') % Check whether a specific style is also specified
            fontProperties.faceStyle = [];
        end
        oldProperties.typeFace = Screen('TextFont', ptbWindow, fontProperties.typeFace, fontProperties.faceStyle);    % Set the typeface
    end

    if isfield(fontProperties,'pointSize')  % Check whether point size is specified
        oldProperties.pointSize = Screen('TextSize', ptbWindow, fontProperties.pointSize);  % Set the point size
    end

    if isfield(fontProperties,'textStyle')  % Check whether text style is specified
        oldProperties.textStyle = Screen('TextStyle', ptbWindow, fontProperties.textStyle); % Set the text style
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

    variablePlaceholder = '%%%';                                        % Specify the variable placeholder sequence
    pageText = regexp(iArray{thisPage},variablePlaceholder,'split');    % Split relevant page at any instance of a variable
    nTextVars = length(pageText)-1;                                     % Get the number of variables to insert
    nVars = length(theseVariables);                                     % Get the number of variables passed to the function
    
    if nVars~=nTextVars                                                 % Check that the same number has been passed in theseVariables
        error('ShowInstructions:VariableNumberMatch','Number of variable placeholders does not matched the number passed!');
    end
    
    if nVars == 0                           % If there are no variables
        displayText = pageText{1};                 % Use the string as it is
    else                                    % Otherwise
        displayText = pageText{1};              % Copy the first part of the string into the output array
        for thisVarNo = 1:nVars                % For the remaining parts
            thisVar = theseVariables(thisVarNo);      % Get the variable in question
            if iscellstr(thisVar)                   % If the variable is a cell string
                thisVar = char(thisVar);                % Convert to a character string
            elseif iscell(thisVar)                  % If the variable is a cell (but not a string)
                thisVar = num2str(thisVar{1});          % Convert to a string
            elseif isnumeric(thisVar)               % If the variable is a number
                thisVar = num2str(thisVar);             % Convert to a string
            end
            displayText = [displayText thisVar pageText{thisVarNo+1}];  %#ok<AGROW> % Add the variable and the next part of the string
        end
    end
    
    % Now display the text
    [nx, ny, textBounds] = DrawFormattedText(ptbWindow, displayText, ...
        fontProperties.sx, fontProperties.sy, fontProperties.colour, ...
        fontProperties.wrapAt, ...
        fontProperties.flipHorizontal, fontProperties.flipVertical, ...
        fontProperties.vSpacing, fontProperties.rightToLeft, ...
        fontProperties.winRect);
    
    if flipType==1
        flipTime = Screen('Flip', ptbWindow);
    elseif flipType==2
        flipTime = Screen('Flip', ptbWindow, [], 1);
    else
        flipTime = NaN;
    end
    
end

