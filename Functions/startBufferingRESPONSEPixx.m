function startTime = startBufferingRESPONSEPixx( flipAtStart, whenToStart, equipment, display )
%STARTBUFFERINGRESPONSEPIXX Start the RESPONSEPixx buffer.
%
%   Note that this function will not return until buffering has started.
%
%   STARTBUFFERINGRESPONSEPIXX called without any arguments simply resets
%   the RESPONSEPixx buffer and starts buffering immediately.
%
%   STARTBUFFERINGRESPONSEPIXX(flipAtStart) specifies whether to start 
%   buffering immediately (default, flipAtStart==0) or whether to flip the 
%   screen and start the buffer at the same time (flipAtStart==1). If set
%   to >0, a PsychToolbox window must be open, and its index stored in the
%   field display.ptbWindow (see below). Setting to flipAtStart==2 will
%   flip the screen without clearing the framebuffer. This is useful if you
%   plan to append something to the frame displayed on this flip.
%
%   STARTBUFFERINGRESPONSEPIXX(flipAtStart, whenToStart) specifies a
%   time (in GetSecs time) to start buffering. If flipAtStart==0, it will
%   start buffering at time whenToStart. If flipAtStart==1, it will start
%   buffering at the first flip after whenToStart.
%
%   STARTBUFFERINGRESPONSEPIXX(flipAtStart, whenToStart, equipment) allows 
%   you to pass information about the response equipment, in the following
%   fields [with defaults in parentheses]:
%
%       equipment.dummyMode [0] indicates whether the function should run 
%       in the absence of a RESPONSEPixx box. Defaults to 0, indicating 
%       that a RESPONSEPixx is present. Set to 1 to initialise dummy mode, 
%       using the keyboard as a response device.
%
%   STARTBUFFERINGRESPONSEPIXX(flipAtStart, whenToStart, equipment,
%   display) allows you to pass information about the display equipment, in
%   the following fields:
%   
%       display.ptbWindow gives the index to the PsychToolbox window. This
%       is required if flipAtStart is set to 1.
%
%   startTime = STARTBUFFERINGRESPONSEPIXX optionally returns the time at
%   which buffering started. The field 'box' gives the time in DATAPixx
%   time; the field 'getSecs' gives the time in GetSecs time. In dummy
%   mode, both of these are in GetSecs time, but both are returned in case
%   the value is expected by the calling function.


end

