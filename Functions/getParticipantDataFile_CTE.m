function [ participant, data, pdata ] = getParticipantDataFile_CTE( directory, participant, experiment)
%GETPARTICIPANTDATAFILE_CTE Makes or retrieves a data file for contrast
%threshold (electrophysiology) experiment.
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
%   experiment.nTrialsPerFrequency (Total number of trials per frequency)
%   experiment.fullTrialsPerFrequency (Number of non-catch trials per freq)
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
        totalTrials = experiment.nSpatialFrequencies*experiment.nTemporalFrequencies*experiment.nTrialsPerFrequency;
        data.response = NaN(1, totalTrials);
        data.responseTime_s = NaN(1, totalTrials);
        data.nResponseEvents = NaN(1, totalTrials);
        data.responseEvents_s = cell(1, totalTrials);
        pdata.response = NaN(1,experiment.nTrialsPerFrequency);
        pdata.responseTime_s = NaN(1,experiment.nTrialsPerFrequency);
        pdata.nResponseEvents = NaN(1,experiment.nTrialsPerFrequency);
        pdata.responseEvents_s = cell(1,experiment.nTrialsPerFrequency);
        
        % Determine trial order
        participant.currentPracticeTrial = 1;
        participant.currentTrial = 1;
        participant.trialOrder = randomiseTrialOrder(experiment.nTrialsPerFrequency, [experiment.nSpatialFrequencies experiment.nTemporalFrequencies], 1);
        participant.startTime = now;
        
        % Save data file
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'data', 'pdata');

    end

end