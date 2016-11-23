function [ responseButton, responseTime, startTime, stopTime ] = waitForButtonPressRESPONSEPixx( whichButtons, forWhat, flipAtStart, whenToStart, lightIntensity, equipment, display )
%WAITFORBUTTONPRESSRESPONSEPIXX Wait for a button press from the
%RESPONSEPixx then returns.
%   WAITFORBUTTONPRESSRESPONSEPIXX waits for a button press from the
%   RESPONSEPixx then returns. Called without any arguments, the function 
%   assumes a five-button box and registers any depressed key, even if the
%   key was already pressed at the time of the function call.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons) sets the buttons to
%   register. See below for the button configurations on 4- and 5-button
%   RESPONSEPixx. Defaults to accepting any button, but you can specify a
%   vector of buttons to accept (e.g. whichButtons==[1,3] would accept only
%   the right and left button on a 5-button box). In dummy mode (see below)
%   defaults to accepting any key, but you could instead specify here a
%   vector of keyCodes (see KbName).
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat) allows you to
%   specify the event that should trigger the function to return. By
%   default, (forWhat==0), the function returns as soon as an allowed
%   button is depressed. Setting forWhat==1 will wait until an allowed
%   button is depressed and then released. Setting forWhat==2 will first
%   wait until all buttons have been released, then return when an allowed
%   button is depressed. Setting forWhat==3 will first wait until all
%   buttons have been released, then wait until an allowed button is
%   depressed and then released. This behaviour is similar to the forWhat
%   flag in KbWait, except that when forWhat==2 or 3, KbWait not only waits
%   until all keys have been released, but requires that a key is pressed 
%   (and/or released) in isolation. This is also the behaviour of this
%   function in dummy mode (see below), which uses KbWait.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat, flipAtStart)
%   specifies whether to start buffering immediately (default,
%   flipAtStart==0) or whether to flip the screen and start the buffer at
%   the same time (flipAtStart==1). If set to >0, a PsychToolbox window
%   must be open, and its index stored in the field display.ptbWindow (see
%   below). Note that setting to 1 will also cause buffering to continue
%   until the next flip after a valid response is received, which will
%   delay the return of the function by up to one monitor refresh. Setting
%   to flipAtStart==2 will flip the screen without clearing the
%   framebuffer. This is useful if you plan to append something to the
%   frame displayed on this flip.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat, flipAtStart, 
%   whenToStart) specifies a time (in GetSecs time) to start buffering. If
%   flipAtStart==0, it will start buffering at time whenToStart. If
%   flipAtStart==1, it will start buffering at the first flip after
%   whenToStart.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat, flipAtStart, 
%   whenToStart, lightIntensity) sets the intensity of the lights on the
%   allowed buttons. Defaults to lightIntensity==0, which preserves the
%   current state of the RESPONSEPixx. Otherwise, all allowed buttons are
%   illuminated at level lightIntensity until a valid response is received;
%   after buffering stops, all lights are turned off.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat, flipAtStart, 
%   whenToStart, lightIntensity, equipment) allows you to pass information
%   about the response equipment, in the following fields [with defaults in
%   parentheses]:
%   
%       equipment.nButtons [5] defines the number of buttons to query, up
%       to 16 (or up to 5 in dummy mode, although calling more in dummy
%       mode shouldn't cause issues).
%
%       equipment.dummyMode [0] indicates whether the function should run 
%       in the absence of a RESPONSEPixx box. Defaults to 0, indicating 
%       that a RESPONSEPixx is present. Set to 1 to initialise dummy mode, 
%       using the keyboard as a response device.
%
%   WAITFORBUTTONPRESSRESPONSEPIXX(whichButtons, forWhat, flipAtStart, 
%   whenToStart, lightIntensity, equipment, display) allows you to pass
%   information about the display equipment, in the following fields:
%   
%       display.ptbWindow gives the index to the PsychToolbox window. This
%       is required if flipAtStart is set to 1.
%
%   responseButton = WAITFORBUTTONPRESSRESPONSEPIXX returns the button
%   index (see tables below) of the button that caused the function to
%   return. In the case of a dead heat between buttons, it returns the one
%   with the lowest index. In dummy mode, this returns the index of the
%   button that corresponds to the key (and not the keyCode itself).
%
%   [responseButton, responseTime] = WAITFORBUTTONPRESSRESPONSEPIXX also
%   returns the time at which the event was registered. The field 'box'
%   gives the time in DATAPixx time; the field 'getSecs' gives the time in
%   GetSecs time. In dummy mode, both of these are in GetSecs time, but
%   both are returned in case the value is expected by the calling
%   function.
%
%   [responseButton, responseTime, startTime] =
%   WAITFORBUTTONPRESSRESPONSEPIXX also returns the time at which buffering
%   started. As for responseTime, DATAPixx time and GetSecs time are
%   returned in the fields 'box' and 'getSecs', respectively. Both are
%   GetSecs time in dummy mode.
%
%   [responseButton, responseTime, startTime, stopTime] =
%   WAITFORBUTTONPRESSRESPONSEPIXX also returns the time at which buffering
%   stopped. As for responseTime and starttime, DATAPixx time and GetSecs
%   time are returned in the fields 'box' and 'getSecs', respectively. Both
%   are GetSecs time in dummy mode.
%
%
%   Buttons for 5-button RESPONSEPixx are as follows:
%
%   BUTTON | LOCATION | RPIXX  | KEYBOARD/PAD (Dummy Mode)
%   1        Right      Red      Right Arrow
%   2        Top        Yellow   Up Arrow
%   3        Left       Green    Left Arrow
%   4        Bottom     Blue     Down Arrow
%   5        Centre     White    Spacebar/Enter

%   Buttons for 4-button RESPONSEPixx are as follows:
%
%   BUTTON | LOCATION    | RPIXX  | KEYBOARD/PAD (Dummy Mode)
%   1        Top-right     Red      J
%   2        Top-left      Yellow   F
%   3        Bottom-left   Green    V
%   4        Bottom-right  Blue     N
%
%   07/09/16 PTG wrote it.

    if nargin < 7 || isempty(display)
        display = struct;
    end
    
    if nargin < 6 || isempty(equipment)
        equipment = struct;
    end

    if nargin < 5 || isempty(lightIntensity)
        lightIntensity = 0;
    end
    
    if nargin < 4 || isempty(whenToStart)
        whenToStart = 0;
    end
    
    if nargin < 3 || isempty(flipAtStart)
        flipAtStart = 0;
    end

    if nargin < 2 || isempty(forWhat)
        forWhat = 0;
    end
    
    if nargin < 1 || isempty(whichButtons)
        whichButtons = 0;
    end
    
    if ~isfield(equipment,'dummyMode')
        equipment.dummyMode = 0;
    end
    
    if ~isfield(equipment,'nButtons')               % Check whether number of buttons is specified
        equipment.nButtons = 5;                     % Set default number of buttons
    end

    if flipAtStart && ~isfield(display, 'ptbWindow')
        error('waitForButtonPressRESPONSEPixx:NoFlipWindow', 'Start at flip requested, but no window index provided!');
    end
    
    if any(whichButtons > equipment.nButtons)
        error('waitForButtonPressRESPONSEPixx:ButtonOutOfRange', 'Requested button out of range!');
    end
    
    if ~equipment.dummyMode     % Verify that dummy mode is not requested (use RESPONSEPixx)
        
        if ~lightIntensity                                  % If light intensity set to zero
            buttonLightState = [];                              % Don't change the button light state
            buttonLightIntensity = [];                          % Don't change the button light intensity
        elseif ~ whichButtons                               % All buttons are valid
            buttonLightState = ones(1, equipment.nButtons);     % Define button light states (all on)
            buttonLightIntensity = lightIntensity;              % Define button light intensity
        else                                                % Some subset of buttons is valid
            buttonLightState = zeros(1, equipment.nButtons);    % Create a vector defining button light states (all of)
            buttonLightState(whichButtons) = 1;                 % Define requested buttons as on
            buttonLightIntensity = lightIntensity;              % Define button light intensity
        end
        
        if ~flipAtStart                                                                                                 % Don't flip the window at the start
            WaitSecs('UntilTime',whenToStart);                                                                          % Wait until requested start time
            [startTime.box, startTime.getSecs] = ResponsePixx('StartNow', 1, buttonLightState, buttonLightIntensity);   % Start buffering responses; turn on lights if requested
        else                                                                                                            % Flip the window at the start
            PsychDataPixx('LogOnsetTimeStamps', 1);                                                                     % Log the next flip in box time
            ResponsePixx('StartAtFlip', [], 1, buttonLightState, buttonLightIntensity);                                 % At next flip, start buffering responses; turn on lights if requested
            startTime.getSecs = Screen('Flip', display.ptbWindow, whenToStart, flipAtStart-1);                          % Flip after the requested start time
            startTime.box = PsychDataPixx('GetLastOnsetTimestamp');                                                     % Store the start time in box time
        end

        if ~whichButtons
            whichButtons = 1:equipment.nButtons;    % Make a vector of all buttons
        end
        
        % Get an initial readout of button states. This does two things.
        % First, it lets us return immediately if an appropriate button is
        % already being pressed (i.e. there is no change of state). Second,
        % it lets us decide whether all buttons are initially released
        % (which doesn't register as a change of state). Because we wait
        % for a timestamp above, we know that recording has started
        % already.
        
        goodResponse = 0;                                                       % Flag to break out of response loop
        allReleased = 0;                                                        % Flag to indicate all buttons have been released
        
        [buttonStates, boxTime, getSecsTime] = ResponsePixx('GetButtons');
        
        waitForRelease = buttonStates(whichButtons);                            % Record states of relevant buttons
        
        if ~any(buttonStates)
            allReleased = 1;                                                    % All buttons are released
        elseif any(buttonStates(whichButtons)) && forWhat==0
            goodResponse = 1;                                                   % Button is down, and that's all we're waiting for
            responseTime.getSecs = getSecsTime;                                 % Record system time
            responseTime.box = boxTime;                                         % Record box time
            responseButton = min(intersect(whichButtons,find(buttonStates)));   % Record pressed button (or if multiple, button with lowest index)
        end

        % Enter a loop to get a valid response, if we don't have one already.
        
        while ~goodResponse
           
            [buttonStates, transitionTimesSecs] = ResponsePixx('GetLoggedResponses', 1);                    % Wait for transition and get one response
            
            if any(buttonStates(whichButtons))                                                              % Requested button is down
                
                if forWhat==0                                                                               % If we're just waiting for the button press
                    goodResponse = 1;
                    responseButton = min(intersect(whichButtons,find(buttonStates)));                       % Record pressed button (or if multiple, button with lowest index)
                elseif forWhat==2 && allReleased                                                            % We want the button down AND all buttons to have been released previously
                    goodResponse = 1;
                    responseButton = min(intersect(whichButtons,find(buttonStates)));                       % Record pressed button (or if multiple, button with lowest index)
                end
                
            elseif any(~buttonStates(whichButtons) & waitForRelease)                                       % If any previously-pressed buttons are released
                
                if forWhat==1                                                                               % Previously-pressed button is released
                    goodResponse = 1;
                    responseButton = whichButtons(find(~buttonStates(whichButtons) && waitForRelease, 1));  % Record released button
                elseif forWhat==3 && allReleased                                                            % Previously-pressed button is released AND all buttons were released previously
                    goodResponse = 1;
                    responseButton = whichButtons(find(~buttonStates(whichButtons) && waitForRelease, 1));  % Record released button
                end
                
            end
            
            if ~goodResponse                                                                                % Skip this if we've already got what we want
                if ~any(buttonStates)
                    allReleased = 1;                                                                        % All buttons are released
                else
                    waitForRelease = buttonStates(whichButtons);                                            % Record states of relevant buttons
                end
                
            else                                                                                            % We found a good response inside this loop, so store response times
                responseTime.box = max(transitionTimesSecs);
                responseTime.getSecs = PsychDataPixx('BoxsecsToGetSecs', transitionTimesSecs);
            end
        end
        
        % Stop recording. Don't mix StartNow/StopNow with
        % StartAtFlip/StopAtFlip.
        
        if ~flipAtStart                                                                                                 % Use 'StopNow'
            if ~lightIntensity                                                                                          % Lights were unaltered
                [stopTime.box, stopTime.getSecs] = ResponsePixx('StopNow', 1);                                          % Stop buffering responses, leave lights alone
            else                                                                                                        % Lights were altered
                [stopTime.box, stopTime.getSecs] = ResponsePixx('StopNow', 1, zeros(1,equipment.nButtons), 1);          % Stop buffering responses, turn off lights
            end
        else                                                                                                            % Use 'StopAtFlip'
            PsychDataPixx('LogOnsetTimeStamps', 1);                                                                     % Log the next flip in box time
            
            if ~lightIntensity                                                                                          % Lights were unaltered
                ResponsePixx('StopAtFlip', [], 1);                                                                      % At next flip, stop buffering responses, leave lights alone
            else                                                                                                        % Lights were altered
                ResponsePixx('StopAtFlip', [], 1, zeros(1,equipment.nButtons), 1);                                      % At next flip, stop buffering responses, turn off lights
            end
                
            stopTime.getSecs = Screen('Flip', display.ptbWindow, [], 1);                                                % Flip after the requested start time, without clearing the framebuffer
            stopTime.box = PsychDataPixx('GetLastOnsetTimestamp');                                                      % Store the start time in box time
        end
        
    else	% Dummy mode is requested (use keyboard)
        
        ListenChar(2);                                                                      % Suppress keyboard output in command window
        
        if ~whichButtons
            whichButtons = 1:equipment.nButtons;                                            % Make a vector of all buttons
        end
            
        % Map requested buttons to keyboard
        if equipment.nButtons == 5
            kbMap = [1 79; 1 94; 2 82; 2 96; 3 80; 3 92; 4 81; 4 90; 5 40; 5 88; 5 44];     % Define key-button correspondences
            whichKeys = kbMap(ismember(kbMap(:,1),whichButtons),2);                         % Get list of keys for corresponding buttons
        elseif equipment.nButtons == 4
            kbMap = [1 13; 2 9; 3 25; 4 17];                                                % Define key-button correspondences
            whichKeys = kbMap(ismember(kbMap(:,1),whichButtons),2);                         % Get list of keys for corresponding buttons
        else
            kbMap = repmat((1:256)',1,2);                                                   % No idea what we're trying to emulate, so just allow any key
            whichKeys = 1:256;
        end
        
        if ~flipAtStart                                                                         % Don't flip the window at the start
            startTime.getSecs = WaitSecs('UntilTime',whenToStart);                              % Wait until requested start time
        else                                                                                    % Flip the window at the start
            startTime.getSecs = Screen('Flip', display.ptbWindow, whenToStart, flipAtStart-1);  % Flip after the requested start time
        end
        
        startTime.box = startTime.getSecs;                                                  % In dummy mode there is no box time, but the calling function might be expecting the output
        
        % Enter a loop to get a valid response, if we don't have one already.
        goodResponse = 0;                                                                   % Flag to break out of response loop
        
        while ~goodResponse
            [getSecsTime, keyCode] = KbWait(-1, forWhat);                                   % Use KbWait to wait for the requested action on any keyboard
            if any(keyCode(whichKeys))                                                      % Check whether key is valid
                goodResponse = 1;                                                           % Set to break out of response loop
            end
        end
        
        responseTime.getSecs = getSecsTime;                                                 % Store the response time
        responseTime.box = responseTime.getSecs;                                            % In dummy mode there is no box time, but the calling function might be expecting the output
        responseButton = kbMap(kbMap(:,2)==find(keyCode,1),1);                              % Map response key back to corresponding response button
        
        if ~flipAtStart                                                                     % Don't flip the window at the start
            stopTime.getSecs = GetSecs;                                                     % Get some (fairly meaningless) stop time value
        else                                                                                % Flip the window at the start
            stopTime.getSecs = Screen('Flip', display.ptbWindow, [], 1);                    % Stop at the next flip, without clearing the framebuffer
        end
        
        stopTime.box = stopTime.getSecs;                                                    % In dummy mode there is no box time, but the calling function might be expecting the output
        
        ListenChar(1);                                                                      % Re-enable keyboard output to command window
        
    end

end

