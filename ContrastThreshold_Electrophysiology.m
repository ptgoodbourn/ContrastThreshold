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
experiment.skipPractice = 1;

%% Set directories
directory.base = '/Users/experimentalmode/Documents/MATLAB/ContrastThreshold/';
directory.data = [directory.base 'Data_CTE/'];
directory.auxiliary = [directory.base 'Auxiliary/'];    % Contains calibration and instruction files
addpath(genpath(directory.base));                       % Add directories to the MATLAB path

%% Define experiment parameters
experiment.instructionFile = 'Instructions_CTE.txt';
experiment.nBlocks = 8;
experiment.nTrialsPerFrequency = 5;                              % Number of trials per frequency

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
stimulus.onRampDuration_s = 20.0;                   % Presentation duration (s)
stimulus.offRampDuration_s = 1.0;                   % Duration of offset ramp (s)
stimulus.rampDuration_s = 0.0;                      % Duration of onset/offset ramp (s) [This is here so that no ramps are applied to the sinusoidal component]
stimulus.noiseExponent = 0;                         % Noise exponent for practice stimuli
stimulus.noiseSegment_s = 2.0;                      % Takes too long to compute e.g. 20s of noise, so we compute a shorter amount and loop it with alternating segments reversed
stimulus.xyNoise = 0;                               % Should practice stimulus noise be x-y-t (1) or just y-t (0)?

stimulus.responseButtonSize_dva = 1.5;              % Subtense of response screen buttons (dva)
stimulus.responseButtonLabels = {'0', '1', '2', '3', '4'};        % Labels on response buttons
stimulus.responseButtonColour = 0.75;
stimulus.responseOutlineWidth_dva = 0.1;
stimulus.responseOutlineColour = 0.25;
stimulus.maxResponseEvents = 4;                     % Maximum number of response events (fixation increments)
stimulus.responseEventSD_s = 1.0;                   % Standard deviation of response event in seconds
stimulus.responseEventTruncate_SD = 4;              % Hard truncation of response event window in SD
stimulus.responseEventAmplitude = 0.8;              % Amplitude of increment in proportion of background (e.g. 0.1 = from 0.50 to 0.55; -0.2 = from 0.50 to 0.40)

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

display.geometryCalibration = [directory.auxiliary display.geometryCalibration];            % Convert to absolute path
display.viewingDistance_dpm = rad2deg(atan((display.width_m/2)/display.viewingDistance_m))/(display.width_m/2);
display.spatialResolution_ppd = display.spatialResolution_ppm/display.viewingDistance_dpm;  % Calculate pixels per degree

stimulus.presentationDuration_s = stimulus.onRampDuration_s + stimulus.offRampDuration_s;
stimulus.spatialFrequencies_cpp = stimulus.spatialFrequencies_cpd/display.spatialResolution_ppd;    % Calculate spatial frequencies (cycles per pixel)
stimulus.gaussianSD_pix = stimulus.gaussianSD_dva*display.spatialResolution_ppd;                    % Calculate Gaussian SD (pixels)
stimulus.gaussianTruncate_pix = stimulus.gaussianTruncate_SD*stimulus.gaussianSD_pix;               % Calculate hard truncation of Gaussian window (pixels)
stimulus.eccentricity_pix = stimulus.eccentricity_dva*display.spatialResolution_ppd;                % Calculate eccentricity of stimulus centre (pixels)
stimulus.textureSupport_pix = 2 * ceil(stimulus.eccentricity_pix + stimulus.gaussianTruncate_pix) + 1;  % Calculate size of required texture support (pixels)
stimulus.noiseSegment_f = stimulus.noiseSegment_s * display.refreshRate_Hz;
stimulus.onRampDuration_f = round(stimulus.onRampDuration_s * display.refreshRate_Hz);         % Calculate duration of presentation (frames)
stimulus.offRampDuration_f = round(stimulus.offRampDuration_s * display.refreshRate_Hz);
stimulus.presentationDuration_f = round(stimulus.presentationDuration_s * display.refreshRate_Hz);
stimulus.carrierAngle_deg = rad2deg(stimulus.carrierAngle_rad);

stimulus.responseEventSD_f = stimulus.responseEventSD_s * display.refreshRate_Hz;  
stimulus.responseEventTruncate_s = stimulus.responseEventTruncate_SD * stimulus.responseEventSD_s;
stimulus.responseEventTruncate_f = round(stimulus.responseEventTruncate_s * display.refreshRate_Hz);

stimulus.responseButtonSize_pix = stimulus.responseButtonSize_dva*display.spatialResolution_ppd;
stimulus.responseOutlineWidth_pix = stimulus.responseOutlineWidth_dva*display.spatialResolution_ppd;

stimulus.fixationSubtense_pix = stimulus.fixationSubtense_dva*display.spatialResolution_ppd;        % Calculate subtense of fixation (pixels)

equipment.responseIndex = [equipment.upIndex equipment.leftIndex equipment.centreIndex equipment.rightIndex equipment.downIndex];

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
% None as yet.

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
    
    %% Make fixation and masks
    fixationElements = prepareFixationElements(stimulus.fixationSubtense_pix, display.centre, 0, stimulus.fixationLineWidth_pix);
    
    % Adjust the colours so that the central oval is mid-grey
    fixationElements.lineColour = fixationElements.ovalColour(1,2);
    fixationElements.ovalColour(:,2) = display.backgroundVal*ones(3,1);
    
    fixationIncrement = normpdf(1:stimulus.responseEventTruncate_f, (stimulus.responseEventTruncate_f/2) + 0.5, stimulus.responseEventSD_f);
    fixationIncrement = (fixationIncrement-min(fixationIncrement)) / (max(fixationIncrement)-min(fixationIncrement));                           % Normalise
    
    % Make a Gaussian mask
    gaussMaskAlpha = makeGaussianRing(stimulus.gaussianSD_pix, stimulus.eccentricity_pix, stimulus.textureSupport_pix);

    % Make onset and offset ramps
    baseEnvelope = [linspace(0,1,stimulus.onRampDuration_f)...
        (cos(linspace(0,pi,stimulus.offRampDuration_f))+1)/2];

    % Make the Gaussian ring mask texture
    gaussMask = display.backgroundVal*ones(stimulus.textureSupport_pix, stimulus.textureSupport_pix, 4);
    gaussMask(:,:,4) = gaussMaskAlpha;
    gaussMaskTex = Screen('MakeTexture', display.ptbWindow, 1-gaussMask, [], [], 2);
    
    %% Start practice block
        
    if (~experiment.skipPractice) && (participant.currentPracticeTrial<=experiment.nPracticeTrials)

        for thisTrial = 1:experiment.nPracticeTrials

            if stimulus.xyNoise
                % The following lines make 3D noise.
                invNoise = makeNoiseInvF([stimulus.textureSupport_pix stimulus.textureSupport_pix stimulus.noiseSegment_f], stimulus.noiseExponent );
            else
                % The following lines make 2D (y-t) noise, which might be
                % better if the subsequent experiment uses horizontal gratings.
                invNoise = makeNoiseInvF([stimulus.textureSupport_pix stimulus.noiseSegment_f], stimulus.noiseExponent);
                invNoise = permute(repmat(invNoise, [1 1 stimulus.textureSupport_pix]), [1 3 2]);
            end

            noiseFrames = NaN(1,stimulus.noiseSegment_f);

            for thisFrame = 1:stimulus.noiseSegment_f
                noiseFrames(thisFrame) = Screen('MakeTexture', display.ptbWindow, squeeze(invNoise(:,:,thisFrame)), [], [], 2);
            end
            
            % Determine response events
            nResponseEvents = randi(stimulus.maxResponseEvents+1) - 1;
            pdata.nResponseEvents(thisTrial) = nResponseEvents;
            
            while true
                responseEventFrames = sort(round(rand(1,nResponseEvents)*(stimulus.onRampDuration_f-stimulus.responseEventTruncate_f)));
                if all(diff(responseEventFrames) > stimulus.responseEventTruncate_f)
                    break;
                end          
            end
            
            pdata.responseEvents_s{thisTrial} = responseEventFrames / display.refreshRate_Hz;
            responseEvents = zeros(1, stimulus.presentationDuration_f);
            
            for thisEvent = 1:nResponseEvents
                responseEvents(responseEventFrames(thisEvent):(responseEventFrames(thisEvent)+stimulus.responseEventTruncate_f-1)) ...
                    = fixationIncrement;
            end
            
            fixationVal = display.backgroundVal*ones(1, stimulus.presentationDuration_f) + (display.backgroundVal*stimulus.responseEventAmplitude*responseEvents);
            
            % Display fixation
            drawFixationElements(display.ptbWindow, fixationElements);
            Screen('DrawingFinished', display.ptbWindow);
            fixTime = Screen('Flip', display.ptbWindow);
            
            % Display stimulus
            oldPriority = Priority(MaxPriority(display.ptbWindow));
            WaitSecs('UntilTime', fixTime + stimulus.fixationDuration_s);
            for thisFrame = 1:stimulus.presentationDuration_f
                Screen('DrawTexture', display.ptbWindow, noiseFrames(thisSegmentFrame), [], [], [], [], baseEnvelope(thisFrame));
                Screen('DrawTexture', display.ptbWindow, gaussMaskTex);
                
                % Update fixation luminance
                fixationElements.ovalColour(:,2) = fixationVal(thisFrame);
                drawFixationElements(display.ptbWindow, fixationElements);
                
                Screen('DrawingFinished', display.ptbWindow);
                Screen('Flip', display.ptbWindow);
                
                if (thisSegmentFrame == 1) && (thisSegmentDirection == -1)
                    thisSegmentFrame = 2;
                    thisSegmentDirection = 1;
                elseif (thisSegmentFrame == stimulus.noiseSegment_f) && (thisSegmentDirection == 1)
                    thisSegmentFrame = stimulus.noiseSegment_f;
                    thisSegmentDirection = -1;
                else
                    thisSegmentFrame = thisSegmentFrame + thisSegmentDirection;
                end
                
            end
            Priority(oldPriority);

            Screen('Flip', display.ptbWindow);
            Screen('Close', noiseFrames);

            % Reset fixation colour
            fixationElements.ovalColour(:,2) = display.backgroundVal*ones(3,1);
            
            % Draw response screen
            drawResponseScreen(display, stimulus.responseButtonSize_pix, ...
                stimulus.responseButtonLabels, equipment.responseIndex, ...
                stimulus.responseButtonColour, stimulus.responseOutlineWidth_pix, ...
                stimulus.responseOutlineColour);
            
            Screen('Flip', display.ptbWindow);
            
            % Get response
            [responseButton, responseTime, startTime] = waitForButtonPressRESPONSEPixx(equipment.responseIndex, 2, [], [], 1, equipment, display);

            Screen('Flip', display.ptbWindow);
            
            % Check response
            thisResponse = str2double(stimulus.responseButtonLabels{equipment.responseIndex==responseButton});
            thisCorrect = nResponseEvents==thisResponse;

            % Give feedback
            giveAudioFeedback(equipment, thisCorrect);
            
            % Store responses and other trial data
            pdata.response(thisTrial) = thisResponse;
            pdata.responseTime_s(thisTrial) = responseTime.getSecs;
            
            % Increment the practice trial counter
            participant.currentPracticeTrial = participant.currentPracticeTrial + 1;

        end
        
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'pdata', 'data');
        
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
    
    % Create procedural Gabors
    [gratingId, gratingRect] = CreateProceduralSineGrating(display.ptbWindow, stimulus.textureSupport_pix, stimulus.textureSupport_pix, [], floor(stimulus.textureSupport_pix/2), 1.0);
    
    %% Start experimental blocks
    for thisBlock = 1:experiment.nBlocks
            
        %% Start trial
        for thisTrial = 1:experiment.nTrialsPerBlock(thisBlock)

            % Get frequency and contrast values for this trial
            thisSpatialFrequencyNo = participant.trialOrder(1,participant.currentTrial);
            thisTemporalFrequencyNo = participant.trialOrder(2,participant.currentTrial);
            thisSpatialFrequency = stimulus.spatialFrequencies_cpp(thisSpatialFrequencyNo);
            thisTemporalFrequency = stimulus.temporalFrequencies_Hz(thisTemporalFrequencyNo);
            thisWaveType = stimulus.temporalWaveforms(thisTemporalFrequencyNo);
                                    
            % Randomise spatial phase of target
            thisSpatialPhase = 360*rand;
            
            % Create temporal envelope
            [modEnvelope, thisTemporalPhase] = makeTemporalEnvelope(thisTemporalFrequency, stimulus, display);
            if thisWaveType
                modEnvelope = sign(modEnvelope); % Make a square wave
            end
            thisEnvelope = modEnvelope .* baseEnvelope;
            
            % Determine response events
            nResponseEvents = randi(stimulus.maxResponseEvents+1) - 1;
            pdata.nResponseEvents(thisTrial) = nResponseEvents;
            
            while true
                responseEventFrames = sort(round(rand(1,nResponseEvents)*(stimulus.onRampDuration_f-stimulus.responseEventTruncate_f)));
                if all(diff(responseEventFrames) > stimulus.responseEventTruncate_f)
                    break;
                end          
            end
            
            pdata.responseEvents_s{thisTrial} = responseEventFrames / display.refreshRate_Hz;
            responseEvents = zeros(1, stimulus.presentationDuration_f);
            
            for thisEvent = 1:nResponseEvents
                responseEvents(responseEventFrames(thisEvent):(responseEventFrames(thisEvent)+stimulus.responseEventTruncate_f-1)) ...
                    = fixationIncrement;
            end
            
            fixationVal = display.backgroundVal*ones(1, stimulus.presentationDuration_f) + (display.backgroundVal*stimulus.responseEventAmplitude*responseEvents);
                
            % Display fixation
            drawFixationElements(display.ptbWindow, fixationElements);
            Screen('DrawingFinished', display.ptbWindow);
            fixTime = Screen('Flip', display.ptbWindow);
            
            % Display stimulus
            oldPriority = Priority(MaxPriority(display.ptbWindow));
            WaitSecs('UntilTime', fixTime + stimulus.fixationDuration_s);
            for thisFrame = 1:stimulus.presentationDuration_f
                
                Screen('DrawTexture', display.ptbWindow, gratingId, [], ...
                    [], stimulus.carrierAngle_deg, ...
                    [], [], [0 0 0 1], [], [], ...
                    [thisSpatialPhase, thisSpatialFrequency, ...
                    thisEnvelope(thisFrame), 0]);
                
                Screen('DrawTexture', display.ptbWindow, gaussMaskTex);
                
                % Update fixation luminance
                fixationElements.ovalColour(:,2) = fixationVal(thisFrame);
                drawFixationElements(display.ptbWindow, fixationElements);
                Screen('DrawingFinished', display.ptbWindow);
                Screen('Flip', display.ptbWindow);
            end
            
            Priority(oldPriority);

            Screen('Flip', display.ptbWindow);

            % Reset fixation colour
            fixationElements.ovalColour(:,2) = display.backgroundVal*ones(3,1);
            
            % Draw response screen
            drawResponseScreen(display, stimulus.responseButtonSize_pix, ...
                stimulus.responseButtonLabels, equipment.responseIndex, ...
                stimulus.responseButtonColour, stimulus.responseOutlineWidth_pix, ...
                stimulus.responseOutlineColour);
            
            Screen('Flip', display.ptbWindow);
            
            % Get response
            [responseButton, responseTime, startTime] = waitForButtonPressRESPONSEPixx(equipment.responseIndex, 2, [], [], 1, equipment, display);

            Screen('Flip', display.ptbWindow);
            
            % Check response
            thisResponse = str2double(stimulus.responseButtonLabels{equipment.responseIndex==responseButton});
            thisCorrect = nResponseEvents==thisResponse;

            % Give feedback
            giveAudioFeedback(equipment, thisCorrect);
            
            % Store responses and other trial data
            data.response(thisTrial) = thisResponse;
            data.responseTime_s(thisTrial) = responseTime.getSecs;
            
            % Increment the practice trial counter
            participant.currentTrial = participant.currentTrial + 1;
            
        end
    
        %% End block

        % Save data
        save(participant.dataFile, 'directory', 'participant', 'experiment', 'pdata', 'data');

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