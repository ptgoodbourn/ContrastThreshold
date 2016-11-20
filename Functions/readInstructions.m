function [ iArray ] = readInstructions( fileName, pageDelimiter, variablePlaceholder )
%READINSTRUCTIONS Read a plain text file and partition for presentation in
%PsychToolbox.
%   Reads a text file from a specified location and partitions it into a
%   cell array of strings, for presentation using PsychToolbox (with the
%   function showInstructions).
%
%   iArray = READINSTRUCTIONS(fileName) reads the text file at the location
%   given in fileName and returns a cell array of strings in iArray. By
%   default, the character string *** is used to delimit different pages,
%   i.e. a separate cell will be used to store two passages of text
%   separated by three asterisks. The character string *must* be on a line
%   of its own.
%
%   iArray = READINSTRUCTIONS(fileName, pageDelimiter) allows you to
%   specify your own character string for delimiting pages.
%
%   iArray = READINSTRUCTIONS(fileName, pageDelimiter, variablePlaceholder)
%   additionally allows you to specify a character string used as a
%   placeholder for variables inserted at the time of display (using
%   showInstructions). By default, the character string %%% (i.e. three
%   consecutive percentage symbols) is used for this. Specifying a
%   different string here will just convert that string to the default
%   string as it is read in.
%   
%   The newline character \n can be used to indicate a line break or
%   multiple line breaks. Any actual line breaks in the text will be
%   double-spaced (i.e. a blank line will be inserted between the
%   paragraphs).

    if (nargin < 3)||isempty(variablePlaceholder)
        variablePlaceholder = '%%%';
    end

    if (nargin < 2)||isempty(pageDelimiter)
        pageDelimiter = '***';
    end

    if strcmp(variablePlaceholder,pageDelimiter)
        error('readInstructions:sameCharacters', 'Variable placeholder and page delimiter can''t be indicated by the same characters!');
    end

    thisFile = fopen(fileName);                             % Open the file
    readIn = textscan(thisFile, '%s', 'Delimiter', '');     % Read the file using textscan
    fclose(thisFile);                                       % Close the file

    readIn = readIn{1};                                     % Access the cell array we want
    nLines = length(readIn);                                % Check the number of lines in the cell array

    iArray = cell(1);                                       % Build a new cell array
    thisPage = 1;                                           % Start at the first page
    firstLine = 1;                                          % Start at the first line of the page

    for thisLine = 1:nLines                                                 % Cycle through each line of the input cell array
        if strcmp(readIn{thisLine},pageDelimiter)                               % Check whether the line is the page delimiter
            thisPage = thisPage + 1;                                                % If so, move to the next page
            firstLine = 1;                                                          % Start at the first line of the page
        elseif firstLine                                                        % If not the page delimiter, is this the first line?
            iArray{thisPage} = readIn{thisLine};                                    % If so, copy the line into the output array
            firstLine = 0;                                                          % The next line isn't the first one
        else                                                                    % If not the delimiter or the first line
            iArray{thisPage} = strcat(iArray{thisPage},'\n\n',readIn{thisLine});    % Add the line to the output array, with a double linebreak after the previous line
        end
    end
    
    if ~strcmp(variablePlaceholder,'%%%')                       % If we need to replace some other placeholder with the default
        thisExp = regexptranslate('escape', variablePlaceholder);       % Translate placeholder for regexp in case it contains special characters
        for thisLine = 1:length(iArray)                                 % Cycle through each line of the output array
            tempArray = regexp(iArray{thisLine},thisExp,'split');           % Use regexp to split the string wherever the placeholder occurs
            if length(tempArray) > 1                                        % If the placeholder does occur
                iArray{thisLine} = tempArray{1};                                % Copy the first part of the string into the output array
                for thisString = 2:length(tempArray)                            % For the remaining parts
                    iArray{thisLine} = [iArray{thisLine} '%%%' tempArray{thisString}];  % Concatenate with earlier strings, including the default placeholder
                end
            end
        end
    end

end

