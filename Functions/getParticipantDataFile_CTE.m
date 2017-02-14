function [ participant, data, pdata ] = getParticipantDataFile_CTE( directory, participant, experiment)
%GETPARTICIPANTDATAFILE_CTE Makes or retrieves a data file for contrast
%threshold (psychophysics) experiment.
%
%   Looks in the current directory for a participant data file for the
%   current participant. If it exists, it loads the file. If it doesn't, it
%   creates a new one using the parameters passed to the function.
%   
%   Usage:
%   [participant, data, pdata] =
%        getParticipantDataFile_CTE(directory, participant, experiment)
%
%   All of the input and output arguments are structures with one or more 
%   fields. 'participant' contains participant infomation. 'data'
%   contains the structures for storing experiment data. 'pdata' contains a 
%   structure for storing data for practice trials.
%   
%   Inputs must contain (at a minimum):
%
%   directory.data (Full path to data directory)
%
%   participant.code (Partipant identifier; see getParticipantCode)
%
%   experiment.nSpatialFrequencies (Number of spatial frequencies)
%   experiment.nTemporalFrequencies (Number of temporal frequencies)
%   experiment.nTrialsPerFrequency (Number of trials per staircase)
%
%   15/02/17 PTG adapted it from getParticipantDataFile_CTP.

    % Check current directory for user data file
    participant.dataFile = [directory.data participant.code '_Data_CTE.mat'];
    newUser = ~exist(participant.dataFile,'file');

    if ~ newUser
        % If file exists, load it.
        load(participant.dataFile);
    else
        % If file doesn't exist, create it.

        for thisSpatialFrequency = 1:experiment.nSpatialFrequencies
            for thisTemporalFrequency = 1:experiment.nTemporalFrequencies
                for thisStaircase = 1:staircase.nPerFrequency
                    tempData = QuestCreate(staircase.thresholdGuess, staircase.thresholdGuessSD, staircase.pThreshold, staircase.beta, staircase.delta, staircase.gamma); %#ok<*AGROW>
                    tempData.stimulusLocation = NaN(1,10000);
                    tempData.responseLocation = NaN(1,10000);
                    tempData.responseTime_s = NaN(1,10000);
                    data(thisSpatialFrequency,thisTemporalFrequency,thisStaircase) = tempData;
                end
            end
        end

        % Create data for practice trials
        for thisStaircase = 1:staircase.nPerFrequency
            tempData = QuestCreate(staircase.thresholdGuess, staircase.thresholdGuessSD, staircase.pThreshold, staircase.beta, staircase.delta, staircase.gamma); %#ok<*AGROW>
            tempData.stimulusLocation = NaN(1,10000);
            tempData.responseLocation = NaN(1,10000);
            tempData.responseTime_s = NaN(1,10000);
            pdata(thisStaircase) = tempData;
        end
        
        % Determine trial order
        participant.currentPracticeTrial = 1;
        participant.currentTrial = 1;
        participant.pTrialOrder = randomiseTrialOrder(staircase.trialsPerStaircase, staircase.nPerFrequency);
        participant.trialOrder = randomiseTrialOrder(staircase.trialsPerStaircase, [experiment.nSpatialFrequencies experiment.nTemporalFrequencies staircase.nPerFrequency], 1);
        participant.startTime = now;
        
        % Save data file
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'staircase', 'data', 'pdata');

    end

end