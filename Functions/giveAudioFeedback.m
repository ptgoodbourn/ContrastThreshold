function startTime = giveAudioFeedback( equipment, isCorrect, dontWait)
%GIVEAUDIOFEEDBACK Plays auditory tones for feedback.
%   
%   GIVEAUDIOFEEDBACK by itself will use MATLAB's sound command to play a
%   single, 250 ms, 500 Hz tone at a sample rate of 8192 Hz.
%
%   GIVEAUDIOFEEDBACK(equipment) lets you specify some additional
%   parameters in the structure equipment.
%   
%   equipment.ptbAudioPort: Handle to the PsychToolbox audio port.
%
%   equipment.audioFreq: Sample rate in Hz (defaults to 48000 for
%   PsychToolbox audio, or 8192 Hz for MATLAB sound).
%
%   equipment.audioChannels: Number of channels; default to 2 for stereo.
%
%   equipment.feedbackIntensity: Intensity (amplitude) of the feedback
%   tone. Defaults to 1.0 (full intensity). If this is a three-element
%   vector, this specifies the amplitude to be applied to the default,
%   incorrect and correct tones, in that order. If any other length, the
%   first element is applied regardless of the requested tone.
%
%   GIVEAUDIOFEEDBACK(equipment, isCorrect) also lets you specify what sort
%   of feedback to give. A correct (isCorrect==1) response will play a
%   two, 100 ms, 800 Hz sine-wave tones separated by 50 ms silence. An 
%   incorrect (isCorrect==0) response will play a single, 250 ms, 300 Hz
%   square-wave tone. Any other value, or a null value, will play a single,
%   250 ms, 500 Hz sine-wave tone.
%
%   GIVEAUDIOFEEDBACK(equipment, isCorrect, dontWait) lets you tell the
%   function not to wait for playback to start before returning (i.e.
%   return immediately). If you use PsychToolbox audio, default behaviour
%   is to wait; set dontWait to 1 to return immediately. If using MATLAB
%   sound, this won't have any effect.
%
%   startTime = GIVEAUDIOFEEDBACK returns an estimate of when the first
%   sample hit the speakers. This is *only* an accurate estimate if using
%   PsychToolbox audio; otherwise, it just returns the time at the end of
%   executing the function.
%
%   See also initialiseAudioPipeline for a simple way to initialise the
%   PsychToolbox audio pipeline.
%
%   14/02/17 PTG wrote it.

    if (nargin < 3) || isempty(dontWait)
        dontWait = 0;
    end

    if (nargin < 2) || isempty(isCorrect)
        isCorrect = -1;
    end

    if (nargin < 1)
        equipment = [];
    end

    if isfield(equipment,'ptbAudioPort')
        ptb = 1;
    else
        ptb = 0;
    end

    if isfield(equipment,'audioFreq')
        freq = equipment.audioFreq;
    elseif ptb
        freq = 48000;
    else
        freq = 8192;
    end

    if isfield(equipment,'audioChannels')
        chans = equipment.audioChannels;
    else
        chans = 2;
    end

    if isfield(equipment,'feedbackIntensity')
        if numel(equipment.feedbackIntensity)==3
            scaleFactor = equipment.feedbackIntensity;
        else
            scaleFactor = equipment.feedbackIntensity(1) * ones(1,3);
        end
    else
        scaleFactor = 1.0 * ones(1,3);
    end

    % Make tone
    if isCorrect==1
        % 2 x 100 ms, 800 Hz sine-wave tones separated by 50 ms silence
        twoTone = 1;
        toneLength = 0.075;
        toneGap = 0.05;
        toneFreq = 800;
        toneType = 1;
        toneScale = scaleFactor(3);
    elseif isCorrect==0
        % 250 ms, 300 Hz square-wave tone
        twoTone = 0;
        toneLength = 0.2;
        toneFreq = 75;
        toneType = 2;
        toneScale = scaleFactor(2);
    else
        % 250 ms, 500 Hz sine-wave tone
        twoTone = 0;
        toneLength = 0.2;
        toneFreq = 500;
        toneType = 1;
        toneScale = scaleFactor(1);
    end

    nCycles = toneLength*toneFreq;
    nSamples = round(toneLength*freq);
    thisTone = sin(linspace(0,2*pi*nCycles,nSamples+1));
    thisTone = thisTone(1:end-1);

    if toneType==2
        % Square wave;
        thisTone = sign(thisTone);
    end

    if twoTone
        % Two tones separated by a gap
        thisGap = zeros(1,round(toneGap*freq));
        thisTone = [thisTone thisGap thisTone];
    end

    % Adjust amplitude
    thisTone = toneScale*thisTone;

    % Expand to required number of channels
    thisTone = repmat(thisTone,chans,1);

    % Play tone
    if ptb
        % Play through PsychToolbox audio port
        PsychPortAudio('FillBuffer', equipment.ptbAudioPort, thisTone);
        startTime = PsychPortAudio('Start', equipment.ptbAudioPort, 1, 0, double(~dontWait));
    else
        % Play using MATLAB sound command
        sound(thisTone, freq);
        startTime = GetSecs;
    end

end

