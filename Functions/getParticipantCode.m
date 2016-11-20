function [ participantCode ] = getParticipantCode( nChars )
%GETPARTICIPANTCODE Gets a participant code from the command window.
%   Displays a prompt in the command window for entering a participant
%   identifier. Returns the code with letters capitalised. By default, it 
%   expects a five-character alphanumeric code and will continue to prompt
%   for a code until that is received. Checks that all characters are
%   letters or numbers (or underscore).
%
%   participantCode = GETPARTICIPANTCODE gives the default behaviour.
%
%   participantCode = GETPARTICIPANTCODE(nChars) specifies the number of
%   characters to expect. Rounds to the nearest integer. Defaults to 5; set
%   to 0 if you want to turn off length-checking.
%
%   31/08/16 PTG wrote it.

if nargin < 1
    nChars = 5;
end

nChars = round(nChars);

tryAgain = 1;

while tryAgain==1
    
    fprintf('\n\nEnter participant code');

    if nChars >=1
        fprintf(' (%d characters)', nChars);
    end

    participantCode = upper(input(': ','s'));
    
    % Check length
    tryAgain = 0;
    codeLength = length(participantCode);
    
    if nChars >=1

        if codeLength ~= nChars
            fprintf('\nWrong number of characters!')
            tryAgain = 1;
        end
        
    end
    
    % Check for alphanumeric characters
    for thisChar = 1:codeLength
        if ~isalpha_num(participantCode(thisChar))
            fprintf('\n%s is not an alphanumeric character!', participantCode(thisChar));
            tryAgain = 1;
        end
    end

end

