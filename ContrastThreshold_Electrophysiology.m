%CONTRASTTHRESHOLD_ELECTROPHYSIOLOGY Make electrophysiological contrast
%threshold measurements.
%   Make electrophysiological measurements of contrast threshold at 
%   specified spatial and temporal frequencies. Presents an annular target
%   that ramps upwards in contrast. Infrequently changes the fixation
%   marker, requiring a button press from the observer. Designed for use 
%   with the DATAPixx for increased contrast resolution, but can be tested 
%   without one by setting display.dummyMode parameter to 1. Various other 
%   parameters are set in the first sections, including local directory 
%   paths, display parameters, stimulus parameters and staircase 
%   parameters. The experiment includes practice trials using a 1/(f^n)
%   noise stimulus.
%
%   15/02/17 PTG adapted it from ContrastThreshold_Psychophysics.

close all;

%% Commonly switched parameters
display.dummyMode = 1;                      % Set to 1 to run without DATAPixx and skip sync tests
equipment.dummyMode = 1;                    % Run with keyboard instead of RESPONSEPixx

experiment.skipInstructions = 0;
experiment.skipPractice = 0;

%% Set directories
directory.base = '/Users/experimentalmode/Documents/MATLAB/ContrastThreshold/';
directory.data = [directory.base 'Data_CTE/'];
directory.auxiliary = [directory.base 'Auxiliary/'];    % Contains calibration and instruction files
addpath(genpath(directory.base));                       % Add directories to the MATLAB path

%% Define experiment parameters
experiment.instructionFile = 'Instructions_CTE.txt';
experiment.nBlocks = 8;
experiment.nTrialsPerFrequency = 5;

%% Define display parameters
display.gamma = 0.423877;                                       % Gamma correction: Gamma (encoding)
display.minL = 0.003617;                                        % Gamma correction: Minimum intensity
display.maxL = 1.104823;                                        % Gamma correction: Maximum intensity
display.gain = 0.898791;                                        % Gamma correction: Gain
display.bias = 0.138418;                                        % Gamma correction: Bias
display.geometryCalibration = 'BVLCalibdata_1_1280_1024.mat';   % Filename for geometry calibration file in directory.calibration
display.refreshRate_Hz = 100;                                   % Display refresh rate (Hz)
display.spatialResolution_ppm = 4400;                           % Display spatial resolution (pixels per m)
display.viewingDistance_m = 1.0;                                % Viewing distance (m)
display.width_m = 0.3;                                          % Width of the display (m)
display.screenNo = min(Screen('Screens'));                      % Screen number
display.backgroundVal = 0.5;                                    % Background luminance in range [0,1]

%% Define other equipment parameters
equipment.rightIndex = 1;                   % Button index for 'right' response
equipment.upIndex = 2;                      % Button index for 'up' response
equipment.leftIndex = 3;                    % Button index for 'left' response
equipment.downIndex = 4;                    % Button index for 'down' response
equipment.centreIndex = 5;                  % Button index for 'centre' response

equipment.waitForWhat = 2;                  % See waitForButtonPressRESPONSEPixx
equipment.continueDelay_s = 5.0;            % Delay on instruction screen before allowed to press a button to continue
equipment.continueButtonIntensity = 0.5;    % Light intensity for 'continue' button during instructions

equipment.audioFreq = 48000;                    % Default audio sample rate
equipment.audioChannels = 2;                    % Stereo
equipment.feedbackIntensity = [1.0 0.5 1.0];    % Intensity of feedback tones (see giveAudioFeedback)

%% Define font parameters
font.typeFace = 'Helvetica';	% Typeface of instruction text
font.pointSize = 28;            % Size of instruction text in points
font.textStyle = 0;             % Normal
font.vSpacing = 1.3;            % Line spacing

%% Define stimulus parameters
stimulus.spatialFrequencies_cpd = [0.5 2.0 5.0 16.0];   % Spatial frequencies (c/dva)
stimulus.gaussianSD_dva = 1.0;                          % SD of Gaussian window (dva)
stimulus.gaussianTruncate_SD = 4;                       % Hard truncation of Gaussian window (SD)
stimulus.eccentricity_dva = 4.0;                        % Eccentricity of stimulus centre (dva)
stimulus.carrierAngle_rad = pi*0.5;                     % Angle of grating carrier vector (rad)
stimulus.fixationSubtense_dva = 0.4;                    % Subtense of outer segment of the fixation marker (dva)
stimulus.fixationLineWidth_pix = 4;                     % Line width of fixation crosshairs (pixels)

stimulus.temporalFrequencies_Hz = [2.0 8.0 20.0];   % Temporal frequencies (Hz)
stimulus.temporalWaveforms = [1 1 1];               % Temporal waveforms at each frequency: 0 = sinewave, 1 = squarewave
stimulus.fixationDuration_s = 0.5;                  % Duration of fixation before stimulus onset
stimulus.presentationDuration_s = 20.0;             % Presentation duration (s)
stimulus.rampDuration_s = 1.0;                      % Duration of offset ramp (s)
stimulus.noiseExponent = 0;                         % Noise exponent for practice stimuli
stimulus.xyNoise = 0;                               % Should practice stimulus noise be x-y-t (1) or just y-t (0)?

%% Calculate parameters from defined parameters
experiment.nSpatialFrequencies = numel(stimulus.spatialFrequencies_cpd);                                            % Number of spatial frequencies in the experiment
experiment.nTemporalFrequencies = numel(stimulus.temporalFrequencies_Hz);                                           % Number of temporal frequencies in the experiment
experiment.nFrequencies = experiment.nSpatialFrequencies*experiment.nTemporalFrequencies;                           % Total number of spatio-temporal frequency combinationssas                                                                   % Number of forced-choice alternative responses
experiment.instructionFile = [directory.auxiliary experiment.instructionFile];                                      % Convert to absolute path
experiment.nExperimentalTrials = experiment.nTrialsPerFrequency * experiment.nFrequencies;                          % Calculate total number of trials in the experiment
experiment.nPracticeTrials = experiment.nTrialsPerFrequency;                                                        % Calculate total number of practice trials
experiment.nTrialsPerBlock = experiment.nExperimentalTrials/experiment.nBlocks;

if round(experiment.nTrialsPerBlock)==experiment.nTrialsPerBlock
    experiment.nTrialsPerBlock = experiment.nTrialsPerBlock * ones(1,experiment.nBlocks);
else
    experiment.nTrialsPerBlock = round(experiment.nTrialsPerBlock) * ones(1,experiment.nBlocks-1);
    experiment.nTrialsPerBlock = [(experiment.nExperimentalTrials-sum(experiment.nTrialsPerBlock)) experiment.nTrialsPerBlock];
end

staircase.gamma = 1/experiment.nAFC;                                                        % Staircase guess rate
staircase.nStaircases = staircase.nPerFrequency * experiment.nFrequencies;                  % Total number of independent staircases

display.geometryCalibration = [directory.auxiliary display.geometryCalibration];            % Convert to absolute path
display.viewingDistance_dpm = rad2deg(atan((display.width_m/2)/display.viewingDistance_m))/(display.width_m/2);
display.spatialResolution_ppd = display.spatialResolution_ppm/display.viewingDistance_dpm;  % Calculate pixels per degree

stimulus.spatialFrequencies_cpp = stimulus.spatialFrequencies_cpd/display.spatialResolution_ppd;    % Calculate spatial frequencies (cycles per pixel)
stimulus.gaussianSD_pix = stimulus.gaussianSD_dva*display.spatialResolution_ppd;                    % Calculate Gaussian SD (pixels)
stimulus.gaussianTruncate_pix = stimulus.gaussianTruncate_SD*stimulus.gaussianSD_pix;               % Calculate hard truncation of Gaussian window (pixels)
stimulus.eccentricity_pix = stimulus.eccentricity_dva*display.spatialResolution_ppd;                % Calculate eccentricity of stimulus centre (pixels)
stimulus.textureSupport_pix = ceil(stimulus.eccentricity_pix + stimulus.gaussianTruncate_pix) + 1;  % Calculate size of required texture support (pixels)
stimulus.presentationDuration_f = stimulus.presentationDuration_s * display.refreshRate_Hz;         % Calculate duration of presentation (frames)
stimulus.fixationSubtense_pix = stimulus.fixationSubtense_dva*display.spatialResolution_ppd;        % Calculate subtense of fixation (pixels)

equipment.responseIndex = [equipment.rightIndex equipment.upIndex equipment.leftIndex equipment.downIndex];

%% Initialise system
participant.randomSeed = setGlobalStreamFromClock();    % Use the system clock to reset the randomisation algorithm

%% Get participant details
participant.code = getParticipantCode();                % Get participant code from the command window

%% Create or retrieve participant data file
[participant, data, pdata] = getParticipantDataFile_CTE(directory, participant, experiment);            % Makes a new file or retrieves existing one

%% Read in instruction file
instructionArray = readInstructions(experiment.instructionFile);                                        % Read in the instructions

%% Initialise imaging, response and audio pipelines
display = initialiseImagingPipelineDATAPixxM16(display);    % Initialise imaging pipeline
initialiseResponsePipelineRESPONSEPixx(equipment);          % Initialise response pipeline
equipment = initialiseAudioPipeline(equipment);             % Initialise audio pipeline

%% Calculate final parameters after pipeline initialisation
[tempx, tempy] = pol2cart(stimulus.positions_rad, stimulus.eccentricity_pix);
stimulus.centres_x = tempx' + display.centre(1);
stimulus.centres_y = tempy' + display.centre(2);

%% Start experiment

    %% Show instructions
    if ~experiment.skipInstructions
        for thisPage = 1:4
            [~, ny, ~, flipTime] = showInstructions(display.ptbWindow, instructionArray, thisPage, [], font, 2);            % Show the page
            appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
            waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
                1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press
        end
        
        % Show screens explaining feedback
        font.sy = display.centre(2) - 200;
        [~, ny] = showInstructions(display.ptbWindow, instructionArray, 5, [], font, 2);
        WaitSecs(2);
        font.sy = ny + 100;
        [~, ny] = showInstructions(display.ptbWindow, instructionArray, 6, [], font, 2);
        WaitSecs(2);
        giveAudioFeedback(equipment, 1);
        WaitSecs(2);
        font.sy = ny + 100;
        [~, ny] = showInstructions(display.ptbWindow, instructionArray, 7, [], font, 2);
        WaitSecs(2);
        flipTime = giveAudioFeedback(equipment, 0);
        WaitSecs(2);
        appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
        waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
            1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);
    
        font = rmfield(font,'sy');
        
        % Show final screen
        [~, ny, ~, flipTime] = showInstructions(display.ptbWindow, instructionArray, 8, [], font, 2);                   % Show the page
        appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
        waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
            1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press
        
    end
    
    
    
    %% Start practice block
    fixationElements = prepareFixationElements(stimulus.fixationSubtense_pix, display.centre, round(rand), stimulus.fixationLineWidth_pix);

    if (~experiment.skipPractice) && (participant.currentPracticeTrial<=experiment.nPracticeTrials)
        % Practice block uses windowed 1/f noise
        gaussMask = makeGaussianBlob(stimulus.gaussianSD_pix, stimulus.textureSupport_pix);

        % Make a dummy texture to get the correct rect dimensions
        dummyFrame = Screen('MakeTexture', display.ptbWindow, gaussMask, [], [], 2);
        stimRect = Screen('Rect', dummyFrame);
        allRects = CenterRectOnPointd(stimRect,stimulus.centres_x,stimulus.centres_y);
        Screen('Close', dummyFrame);

        % Make onset and offset ramps
        rampEnvelope = makeTemporalEnvelope(0, stimulus, display);

        for thisTrial = 1:experiment.nPracticeTrials

            if stimulus.xyNoise
                % The following lines make 3D noise.
                invNoise = makeNoiseInvF([stimulus.textureSupport_pix stimulus.textureSupport_pix stimulus.presentationDuration_f], stimulus.noiseExponent );
            else
                % The following lines make 2D (y-t) noise, which might be
                % better if the subsequent experiment uses horizontal gratings.
                invNoise = makeNoiseInvF([stimulus.textureSupport_pix stimulus.presentationDuration_f], stimulus.noiseExponent);
                invNoise = permute(repmat(invNoise, [1 1 stimulus.textureSupport_pix]), [1 3 2]);
            end

            noiseFrames = NaN(1,stimulus.presentationDuration_f);

            for thisFrame = 1:stimulus.presentationDuration_f
                noiseFrames(thisFrame) = Screen('MakeTexture', display.ptbWindow, (0.5*(1-gaussMask)) + gaussMask.*squeeze(invNoise(:,:,thisFrame)), [], [], 2);
            end

            stimRect = Screen('Rect', noiseFrames(thisFrame));
            allRects = CenterRectOnPointd(stimRect,stimulus.centres_x,stimulus.centres_y);

            thisPosition = randi(experiment.nAFC);

            % Get contrast value for this trial
            thisStaircase = participant.pTrialOrder(participant.currentPracticeTrial);
            thisContrast = min([1.0 10^QuestQuantile(pdata(thisStaircase))]);
            thisEnvelope = rampEnvelope * thisContrast;

            % Display fixation
            drawFixationElements(display.ptbWindow, fixationElements);
            Screen('DrawingFinished', display.ptbWindow);
            fixTime = Screen('Flip', display.ptbWindow);
            
            % Display stimulus
            oldPriority = Priority(MaxPriority(display.ptbWindow));
            WaitSecs('UntilTime', fixTime + stimulus.fixationDuration_s);
            for thisFrame = 1:stimulus.presentationDuration_f
                Screen('DrawTexture', display.ptbWindow, noiseFrames(thisFrame), [], allRects(thisPosition,:), [], [], thisEnvelope(thisFrame));
                drawFixationElements(display.ptbWindow, fixationElements);
                Screen('DrawingFinished', display.ptbWindow);
                Screen('Flip', display.ptbWindow);
            end
            Priority(oldPriority);

            Screen('Flip', display.ptbWindow);
            Screen('Close', noiseFrames);

            % Get response
            [responseButton, responseTime, startTime] = waitForButtonPressRESPONSEPixx(equipment.responseIndex, 2, [], [], 1, equipment, display);

            % Check response
            thisCorrect = thisPosition==responseButton;

            % Give feedback
            giveAudioFeedback(equipment, thisCorrect);
            
            % Update staircase
            pdata(thisStaircase) = QuestUpdate(pdata(thisStaircase), log10(thisContrast), thisCorrect);

            % Store responses and other trial data
            trialCount = pdata(thisStaircase).trialCount;
            pdata(thisStaircase).stimulusLocation(trialCount) = thisPosition;
            pdata(thisStaircase).responseLocation(trialCount) = responseButton;
            
            % Increment the practice trial counter
            participant.currentPracticeTrial = participant.currentPracticeTrial + 1;

        end
        
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'staircase', 'pdata', 'data');
        
    end
 
    %% Show intermediate instructions
    if experiment.skipInstructions
        [~, ny, ~, flipTime] = showInstructions(display.ptbWindow, instructionArray, 9, num2str(experiment.nBlocks), font, 2);    % Show the page
        appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
        [rB,rT,startT,stopT] = waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
            1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press
    else
        [~, ny, ~, flipTime] = showInstructions(display.ptbWindow, instructionArray, 10, num2str(experiment.nBlocks), font, 2);    % Show the page
        appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
        [rB,rT,startT,stopT] = waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
            1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press

    end
    
    %% Start experimental blocks
    for thisBlock = 1:experiment.nBlocks
        
        % Create procedural Gabors
        [gaborId, gaborRect] = CreateProceduralGabor(display.ptbWindow, stimulus.textureSupport_pix, stimulus.textureSupport_pix, [], [], 1, 0.5);
        allRects = CenterRectOnPointd(gaborRect,stimulus.centres_x,stimulus.centres_y);
    
        %% Start trial
        for thisTrial = 1:experiment.nTrialsPerBlock(thisBlock)

            % Get frequency and contrast values for this trial
            thisSpatialFrequencyNo = participant.trialOrder(1,participant.currentTrial);
            thisTemporalFrequencyNo = participant.trialOrder(2,participant.currentTrial);
            thisSpatialFrequency = stimulus.spatialFrequencies_cpp(thisSpatialFrequencyNo);
            thisTemporalFrequency = stimulus.temporalFrequencies_Hz(thisTemporalFrequencyNo);
            thisStaircase = participant.trialOrder(3,participant.currentTrial);
            thisContrast = min([1.0 10^QuestQuantile(data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase))]);
            
            % Randomise spatial phase and position of target
            thisSpatialPhase = 360*rand;
            thisPosition = randi(experiment.nAFC);
            
            % Create temporal envelope
            [thisEnvelope, thisTemporalPhase] = makeTemporalEnvelope(thisTemporalFrequency, stimulus, display);
            thisEnvelope = thisEnvelope * thisContrast;
            
            % Display fixation
            drawFixationElements(display.ptbWindow, fixationElements);
            Screen('DrawingFinished', display.ptbWindow);
            fixTime = Screen('Flip', display.ptbWindow);
            
            % Display stimulus
            oldPriority = Priority(MaxPriority(display.ptbWindow));
            WaitSecs('UntilTime', fixTime + stimulus.fixationDuration_s);
            for thisFrame = 1:stimulus.presentationDuration_f
                
                Screen('DrawTexture', display.ptbWindow, gaborId, [], ...
                    allRects(thisPosition,:), rad2deg(stimulus.carrierAngle_rad), ...
                    [], [], [], [], kPsychDontDoRotation, ...
                    [thisSpatialPhase, thisSpatialFrequency, ...
                    stimulus.gaussianSD_pix, thisEnvelope(thisFrame), 1, 0, 0, 0]);
                drawFixationElements(display.ptbWindow, fixationElements);
                Screen('DrawingFinished', display.ptbWindow);
                Screen('Flip', display.ptbWindow);
            end
            
            Priority(oldPriority);
            Screen('Flip', display.ptbWindow);
            
            % Get response
            [responseButton, responseTime, startTime] = waitForButtonPressRESPONSEPixx(equipment.responseIndex, 2, [], [], 1, equipment, display);
            
            % Check response
            thisCorrect = thisPosition==responseButton;
            
            % Give feedback
            giveAudioFeedback(equipment, thisCorrect);
        
            % Update staircase
            data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase)...
                = QuestUpdate(data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase), log10(thisContrast), thisCorrect);
            
            % Store responses and other trial data
            trialCount = data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase).trialCount;
            data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase).stimulusLocation(trialCount) = thisPosition;
            data(thisSpatialFrequencyNo,thisTemporalFrequencyNo,thisStaircase).responseLocation(trialCount) = responseButton;
            
            % Increment the trial counter
            participant.currentTrial = participant.currentTrial + 1;
            
        end
    
        %% End block

        % Save staircase data
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'staircase', 'pdata', 'data');

        % Show instructions
        if thisBlock < experiment.nBlocks
            [~, ny, ~, flipTime] = showInstructions(display.ptbWindow, instructionArray, 11, {num2str(thisBlock), num2str(experiment.nBlocks)}, font, 2);    % Show the page
            appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
            [rB,rT,startT,stopT] = waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
                1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press
        end
    
    end
    
%% End experiment
[nx, ny, textRect, flipTime] = showInstructions(display.ptbWindow, instructionArray, 12, [], font, 2);    % Show the page
fprintf('\n\nExperiment complete. Hit any key to exit.\n\n');
KbWait(-1,2);

%% Close imaging and response pipelines
Screen('CloseAll');
closeResponsePipelineRESPONSEPixx(equipment);
PsychPortAudio('Close', equipment.ptbAudioPort);