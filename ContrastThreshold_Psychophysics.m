%CONTRASTTHRESHOLD_PSYCHOPHYSICS Make psychophysical contrast threshold
%measurements.
%   Make psychophysical measurements of contrast threshold at specified
%   spatial and temporal frequencies. Designed for use with the DATAPixx
%   for increased contrast resolution, but can be tested without one by 
%   setting display.dummyMode parameter to 1. Various other parameters are
%   set in the first sections, including local directory paths, display
%   parameters, stimulus parameters and staircase parameters. The
%   experiment includes practice trials using a 1/f noise stimulus.
%
%   31/08/16 - 06/09/16 PTG wrote it.

close all;

%% Set directories
directory.base = '/Users/experimentalmode/Documents/MATLAB/ContrastThreshold/';
directory.data = [directory.base 'Data_CTP/'];
directory.auxiliary = [directory.base 'Auxiliary/'];    % Contains calibration and instruction files
addpath(genpath(directory.base));                       % Add directories to the MATLAB path

%% Define experiment parameters
experiment.instructionFile = 'Instructions_CTP.txt';
experiment.skipInstructions = 1;

%% Define display parameters
display.gamma = [1.0 1.0 1.0];                                  % Display gamma (RGB)
display.geometryCalibration = 'BVLCalibdata_0_1280_800.mat';    % Filename for geometry calibration fil in directory.calibration
display.refreshRate_Hz = 100;                                   % Display refresh rate (Hz)
display.spatialResolution_ppm = 4400;                           % Display spatial resolution (pixels per m)
display.viewingDistance_m = 0.5;                                % Viewing distance (m)
display.width_m = 0.3;                                          % Width of the display (m)
display.screenNo = 0;                                           % Screen number
display.dummyMode = 1;                                          % Set to 1 to run without DATAPixx and skip sync tests
display.backgroundVal = 0.5;                                    % Background luminance in range [0,1]
display.antialiasingLevel = 8;                                  % Antialiasing (multisampling) level

%% Define other equipment parameters
equipment.dummyMode = 1;                    % Run with keyboard instead of RESPONSEPixx
equipment.rightIndex = 1;                   % Button index for 'right' response
equipment.upIndex = 2;                      % Button index for 'up' response
equipment.leftIndex = 3;                    % Button index for 'left' response
equipment.downIndex = 4;                    % Button index for 'down' response
equipment.centreIndex = 5;                  % Button index for 'centre' response

equipment.waitForWhat = 2;                  % See waitForButtonPressRESPONSEPixx
equipment.continueDelay_s = 5.0;            % Delay on instruction screen before allowed to press a button to continue
equipment.continueButtonIntensity = 0.5;    % Light intensity for 'continue' button during instructions

%% Define font parameters
font.typeFace = 'Helvetica';	% Typeface of instruction text
font.pointSize = 28;            % Size of instruction text in points
font.textStyle = 0;             % Normal

%% Define stimulus parameters
stimulus.spatialFrequencies_cpd = [0.5 2.0 5.0 16.0];   % Spatial frequencies (c/dva)
stimulus.gaussianSD_dva = 1.0;                          % SD of Gaussian window (dva)
stimulus.gaussianTruncate_SD = 4;                       % Hard truncation of Gaussian window (SD)
stimulus.eccentricity_dva = 4.0;                        % Eccentricity of stimulus centre (dva)
stimulus.carrierAngle_rad = 0.0;                        % Angle of grating carrier vector (rad)
stimulus.positions_rad = pi*[0.0 1.5 1.0 0.5];          % Stimulus positions (on imaginary circle). Use this variable to set the number of alternatives.
stimulus.fixationSubtense_dva = 0.4;                    % Subtense of outer segment of the fixation marker (dva)
stimulus.fixationLineWidth_pix = 4;                     % Line width of fixation crosshairs (pixels)

stimulus.temporalFrequencies_Hz = [2.0 8.0 20.0];   % Temporal frequencies (Hz)
stimulus.presentationDuration_s = 0.5;              % Presentation duration (s)
stimulus.rampDuration_s = 0.1;                      % Duration of onset and offset ramps (s)
stimulus.noiseExponent = 0;                         % Noise exponent for practice stimuli
stimulus.xyNoise = 0;                               % Should practice stimulus noise be x-y-t (1) or just y-t (0)?

%% Define staircase parameters
staircase.thresholdGuess = log10(0.2);              % (Log of) Initial threshold guess
staircase.thresholdGuessSD = 1.0;                   % (Log of) Initial threshold guess standard deviation
staircase.nPerFrequency = 2;                        % Number of staircases per spatiotemporal frequency
staircase.trialsPerStaircase = 30;                  % Number of trials per staircase
staircase.delta = 0.1;                              % Staircase lapse rate
staircase.beta = 3.5;                               % Slope of psychometric function
staircase.pThreshold = .72;                         % Percent correct defined as threshold

%% Calculate parameters from defined parameters
experiment.nSpatialFrequencies = numel(stimulus.spatialFrequencies_cpd);                                            % Number of spatial frequencies in the experiment
experiment.nTemporalFrequencies = numel(stimulus.temporalFrequencies_Hz);                                           % Number of temporal frequencies in the experiment
experiment.nFrequencies = experiment.nSpatialFrequencies*experiment.nTemporalFrequencies;                           % Total number of spatio-temporal frequency combinations
experiment.nAFC = numel(stimulus.positions_rad);                                                                    % Number of forced-choice alternative responses
experiment.instructionFile = [directory.auxiliary experiment.instructionFile];                                      % Convert to absolute path
experiment.nExperimentalTrials = staircase.trialsPerStaircase * staircase.nPerFrequency * experiment.nFrequencies;  % Calculate total number of trials in the experiment
experiment.nPracticeTrials = staircase.trialsPerStaircase * staircase.nPerFrequency;                                % Calculate total number of practice trials

staircase.gamma = 1/experiment.nAFC;                                                        % Staircase guess rate
staircase.nStaircases = staircase.nPerFrequency * experiment.nFrequencies;                  % Total number of independent staircases

display.geometryCalibration = [directory.auxiliary display.geometryCalibration];            % Convert to absolute path
display.viewingDistance_dpm = rad2deg(atan((display.width_m/2)/display.viewingDistance_m))/(display.width_m/2);
display.spatialResolution_ppd = display.spatialResolution_ppm/display.viewingDistance_dpm;  % Calculate pixels per degree

stimulus.spatialFrequencies_cpp = stimulus.spatialFrequencies_cpd/display.spatialResolution_ppd;    % Calculate spatial frequencies (cycles per pixel)
stimulus.gaussianSD_pix = stimulus.gaussianSD_dva*display.spatialResolution_ppd;                    % Calculate Gaussian SD (pixels)
stimulus.gaussianTruncate_pix = stimulus.gaussianTruncate_SD*stimulus.gaussianSD_pix;               % Calculate hard truncation of Gaussian window (pixels)
stimulus.eccentricity_pix = stimulus.eccentricity_dva*display.spatialResolution_ppd;                % Calculate eccentricity of stimulus centre (pixels)
stimulus.textureSupport_pix = ceil(stimulus.gaussianTruncate_pix * 2) + 1;                          % Calculate size of required texture support (pixels)
stimulus.presentationDuration_f = stimulus.presentationDuration_s * display.refreshRate_Hz;         % Calculate duration of presentation (frames)
stimulus.fixationSubtense_pix = stimulus.fixationSubtense_dva*display.spatialResolution_ppd;        % Calculate subtense of fixation (pixels)

%% Initialise system
participant.randomSeed = setGlobalStreamFromClock();    % Use the system clock to reset the randomisation algorithm

%% Get participant details
participant.code = getParticipantCode();                % Get participant code from the command window

%% Create or retrieve participant data file
[participant, data, pdata] = getParticipantDataFile_CTP(directory, participant, experiment, staircase);  % Makes a new file or retrieves existing one

%% Initialise imaging and response pipelines
display = initialiseImagingPipelineDATAPixxM16(display);    % Initialise imaging pipeline
initialiseResponsePipelineRESPONSEPixx(equipment);          % Initialise response pipeline

%% Calculate final parameters after pipeline initialisation
[tempx, tempy] = pol2cart(stimulus.positions_rad, stimulus.eccentricity_pix);
stimulus.centres_x = tempx' + display.centre(1);
stimulus.centres_y = tempy' + display.centre(2);

%% Start experiment

    %% Show instructions
    if ~experiment.skipInstructions
    
        instructionArray = readInstructions(experiment.instructionFile);                                        % Read in the instructions

        for thisPage = 1:3
            [nx, ny, textRect, flipTime] = showInstructions(display.ptbWindow, instructionArray, thisPage, [], font, 2);    % Show the page
            appendInstructionsContinue(display.ptbWindow, 'the centre button', font, ny+100, 1);                            % Append the continue message without flipping
            [rB,rT,startT,stopT] = waitForButtonPressRESPONSEPixx(equipment.centreIndex, equipment.waitForWhat, ...
                1, flipTime+equipment.continueDelay_s, equipment.continueButtonIntensity, equipment, display);              % Flip and wait for button press
        end
        
    end
    
    %% Start practice block
    % Practice block uses windowed 1/f noise
    gaussMask = makeGaussianBlob(stimulus.gaussianSD_pix, stimulus.textureSupport_pix);
    fixationElements = prepareFixationElements(stimulus.fixationSubtense_pix, display.centre, round(rand), stimulus.fixationLineWidth_pix);
    
    % Make a dummy texture to get the correct rect dimensions
    dummyFrame = Screen('MakeTexture', display.ptbWindow, gaussMask, [], [], 2);
    stimRect = Screen('Rect', dummyFrame);
    allRects = CenterRectOnPointd(stimRect,stimulus.centres_x,stimulus.centres_y);
    Screen('Close', dummyFrame);
    
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
        
        oldPriority = Priority(MaxPriority(display.ptbWindow));
        for thisFrame = 1:stimulus.presentationDuration_f
            Screen('DrawTexture', display.ptbWindow, noiseFrames(thisFrame), [], allRects(thisPosition,:), [], [], thisContrast);
            drawFixationElements(display.ptbWindow, fixationElements);
            Screen('DrawingFinished', display.ptbWindow);
            Screen('Flip', display.ptbWindow);
        end
        Priority(oldPriority);
        
        Screen('Flip', display.ptbWindow);
        Screen('Close', noiseFrames);
        
        % Get response (may need some work)
        [responseButton, responseTime, startTime] = waitForButtonPressRESPONSEPixx([], [], [], [], [], equipment, display);
        
        % Check response
        thisCorrect = thisPosition==responseButton;
        
        % Update staircase
        pdata(thisStaircase) = QuestUpdate(pdata(thisStaircase), log10(thisContrast), thisCorrect);
        
        % Store responses and other trial data

        % Increment the practice trial counter
        participant.currentPracticeTrial = participant.currentPracticeTrial + 1;
        
    end
    
    
    
    %% Start experimental blocks
    
    % Create procedural Gabors
    
        %% Start trial

        % Get contrast value for this trial
    
        % Present stimulus
        
        % Get response
        
        % Update staircase
    
    %% End block
    
    % Save staircase data
    
%% End experiment

%% Close imaging and response pipelines
closeResponsePipelineRESPONSEPixx(equipment);