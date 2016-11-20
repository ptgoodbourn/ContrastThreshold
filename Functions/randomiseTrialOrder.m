function [ trialOrderByFactor, randomOrder ] = randomiseTrialOrder( trialsPerCell, levelsPerFactor, blocked )
%RANDOMISETRIALORDER Creates a pseudo-random trial order across one or more
%factors.
%   RANDOMISETRIALORDER(trialsPerCell) simply returns a vector of ones, of
%   length trialsPerCell. Equivalent to ones(1,trialsPerCell). This is
%   because without additional arguments, the function assumes there is one
%   factor with one level.
%
%   RANDOMISETRIALORDER(trialsPerCell, levelsPerFactor) lets you specify
%   the number of levels in each factor. The argument levelsPerFactor
%   should be a vector, with the first element specifying the number of
%   levels in the first factor, the second element specifying the number of
%   levels in the second factor, and so on. The number of factors is
%   inferred from the number of elements in the vector. Defaults to 1.
%
%   RANDOMISETRIALORDER(trialsPerCell, levelsPerFactor, blocked) lets you
%   specify, by setting 'blocked' to 1, that all levels of all factors
%   should be presented once (in a random permutation) before revisiting
%   any combination again. By setting 'blocked' to 2, the matrix of factor
%   levels will be returned in a set order, without scrambling the trials
%   at all. That is, trials will proceed predictably from the first trial
%   using the first level of every factor, then the second trial using the
%   next level of the first factor and the first level of other factors,
%   and so on. Defaults to 0.
%
%   trialOrderByFactor = RANDOMISETRIALORDER(...) returns an r x c matrix
%   where r is the number of factors and c is the total number of trials
%   [ trialsPerCell * prod(levelsPerFactor) ]. Each column represents a
%   trial; within a column, each row specifies which level of a given
%   factor to present on that trial.
%
%   [ trialOrderByFactor, randomOrder ] = RANDOMISETRIALORDER(...)
%   additionally returns the vector used to scramble the trial order from
%   its 'dontScramble' state. This will be a random permutation of the
%   integers 1 to the total number of trials. If blocked is set to 1, the
%   permutation will only be random within consecutive groups of 
%   prod(levelsPerFactor).

    if nargin < 3 || isempty(blocked)
        blocked = 0;                            % Default to no blocking
    end

    if nargin < 2 || isempty(levelsPerFactor)
        levelsPerFactor = 1;                    % Default to one factor with one level
    end

    if nargin < 1 || isempty(trialsPerCell)
        trialsPerCell = 1;                      % Default to one trial per cell
    end

    nFactors = numel(levelsPerFactor);          % Calculate the number of factors
    nCells = prod(levelsPerFactor);             % Calculate the number of combinations of levels (cells)
    baseOrderByFactor = NaN(nFactors, nCells);  % Define a matrix for storing the base trial order
    totalTrials = nCells * trialsPerCell;       % Calculate total number of trials
    thisRealFactor = 0;                         % Keep track of how many 'real' factors we have dealt with

    for thisFactor = 1:nFactors                                     % Cycle through each factor

        factorLevels = levelsPerFactor(thisFactor);                     % Get the number of levels for this factor
        if factorLevels > 1                                             % Check whether this is a 'real' factor
            thisRealFactor = thisRealFactor + 1;                            % If so, increment the number of real factors by 1
            baseOrder = [];                                                 % Create an empty vector for storing the base order

            for thisLevel = 1:factorLevels                                  % Cycle through each level of the factor
                baseOrder = [baseOrder thisLevel*ones(1,2^(thisRealFactor-1))];  %#ok<AGROW> Add one or more instances of this level to the base order
            end

            nReps = nCells/(factorLevels*(2^(thisRealFactor-1)));           % Calculate how many repetitions of this are required

            baseOrderByFactor(thisFactor,:) = repmat(baseOrder, [1 nReps]); % Store in the base order matrix

        else                                                            % If this isn't a 'real' factor

            baseOrderByFactor(thisFactor,:) = ones(1,nCells);               % Add all ones to the row for this factor

        end


    end

    if blocked==2                       % No randomisation

        randomOrder = 1:totalTrials;        % Set random order to a linearly increasing vector

    elseif blocked==1                   % Randomisation only within blocks
        
        randomOrder = [];                   % Create a vector for storing the random order
        
        for thisBlock = 1:trialsPerCell     % For each block
            randomOrder = [randomOrder (((thisBlock-1) * nCells) + randperm(nCells))]; %#ok<AGROW> Add a random permutation of the relevant trial numbers
        end

    else                                % Full randomisation

        randomOrder = randperm(totalTrials);    % Set random order to a random permutation of the number of trials

    end
    
    trialOrderByFactor = repmat(baseOrderByFactor, [1 trialsPerCell]);  % Repeat the base order matrix for each trial per cell
    trialOrderByFactor = trialOrderByFactor(:, randomOrder);            % Shuffle the matrix according to random order

end

