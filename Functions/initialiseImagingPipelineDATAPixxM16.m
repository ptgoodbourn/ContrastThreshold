function [ display ] = initialiseImagingPipelineDATAPixxM16( display )
%INITIALISEIMAGINGPIPELINEDATAPIXXM16 Initialise PsychToolbox Imaging
%Pipeline using DATAPixx in mono mode.
%   display = INITIALISEIMAGINGPIPELINEDATAPIXXM16(display) uses
%   information in in the structure 'display' to intialise the PsychToolbox
%   Imaging Pipeline for the DATAPIxx running in 16-bit mono mode. The
%   function adds several extra fields to the structure for use in the 
%   calling routine.
%
%   At a minimum, the input 'display' structure should contain these
%   fields:
%
%   display.dummyMode (0 if DATAPixx is present, 1 if absent)
%   display.screenNo (Number of the screen on which to display stimuli)
%   display.backgroundVal (Background luminance in 0,1 range)
%
%   In addition, the structure should contain the following fields if dummy
%   mode is off:
%
%   display.geometryCalibration (path to geometry calibration file)
%   display.gamma               (three-element vector of RGB gamma)
%
%   In dummy mode, no gamma or geometry correction is applied, and
%   synchronisation tests are skipped. This is useful for developing and
%   debugging, but you'd never run an experiment in dummy mode.
%
%   Optionally, you can pass another field which sets the level of
%   antialiasing to apply to the window (defaults to no antialiasing):
%
%   display.antialiasingLevel   (multisampling level)
%
%   The function returns the 'display' structure with these extra fields:
%
%   display.ptbWindow (Index to the PsychToolbox window)
%   display.screenRect (Rect of PsychToolbox window)
%   display.measuredRefreshRate_Hz (Measured refresh rate of the display)
%   display.centre (Pixel coordinates of the display centre)
%
%   31/08/16 PTG wrote it.

    if ~isfield(display,'antialiasingLevel')
        multisample = [];
    else
        multisample = display.antialiasingLevel;
    end

    PsychDefaultSetup(2);                                                                           % Default settings, with colour range clamped to [0,1]
    PsychImaging('PrepareConfiguration');                                                           % Prepare configuration
    
    % Check if dummy mode is required and set if necessary
    if display.dummyMode
        Screen('Preference', 'SkipSyncTests', 1);
        PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
    else
        PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');                                  % Enable the high-performance driver for M16 (m DataPixx device
        PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');            % Enable gamma correction
        PsychImaging('AddTask', 'FinalFormatting', 'GeometryCorrection', display.geometryCalibration);  % Enable geometry calibration
    end
    
    % Prepare a PsychToolbox window
    [display.ptbWindow, display.screenRect] = PsychImaging('OpenWindow', display.screenNo, display.backgroundVal, [], [], [], [], multisample);  % Open a PsychToolbox window
    
    if ~display.dummyMode
        PsychColorCorrection('SetEncodingGamma', display.ptbWindow, display.gamma);                                     % Set encoding gamma
    end
        
    Screen('BlendFunction', display.ptbWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Flip', display.ptbWindow);                                                                              % Perform initial flip to background colour and synchronise to retrace

    % Get some details of the PsychToolbox window
    display.measuredRefreshRate_Hz = Screen('FrameRate',display.ptbWindow);     % Measure the frame rate
	[display.centre(1), display.centre(2)] = RectCenter(display.screenRect);	% Get coordinates of the screen centre

end

