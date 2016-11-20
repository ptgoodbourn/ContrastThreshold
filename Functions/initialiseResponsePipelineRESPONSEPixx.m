function initialiseResponsePipelineRESPONSEPixx( equipment )
%INITIALISERESPONSEPIPELINERESPONSEPIXX Initialise a response pipeline for
%the RESPONSEPixx.
%   INITIALISERESPONSEPIPELINERESPONSEPIXX opens the RESPONSEPixx for
%   button response collection.
%
%   INITIALISERESPONSEPIPELINERESPONSEPIXX(equipment) allows you to set
%   additional parameters, including a dummy mode (RESONSEPixx absent) that
%   is useful for development and debugging. 'equipment' is a structure,
%   and a sensible default [indicated in parentheses below] is used if a 
%   field is missing or empty. The following fields can be set:
%
%   equipment.dummyMode [0] indicates whether the function should run in
%   the absence of a RESPONSEPixx box. Defaults to 0, indicating that a
%   RESPONSEPixx is present. Set to 1 to initialise dummy mode, using the
%   keyboard as a response device.
%
%   equipment.nResponseSamples [1000] sets the maximum number of button
%   transitions to log. This is ignored in dummy mode.
%
%   equipment.responseBufferAddress [12e6] sets the memory start address of
%   the logging buffer in the DATAPixx. Ignored in dummy mode.
%
%   equipment.nButtons [5] defines the number of buttons to query, up to
%   16 (or up to 5 in dummy mode).
%
%   Buttons up to 5 are as follows:
%
%   BUTTON | LOCATION | RPIXX  | KEYBOARD/PAD (Dummy Mode)
%   1        Right      Red      Right Arrow
%   2        Top        Yellow   Up Arrow
%   3        Left       Green    Left Arrow
%   4        Bottom     Blue     Down Arrow
%   5        Centre     White    Enter
%
%   06/09/16 PTG wrote it.

    if nargin < 1
        equipment = struct;
    end

    if ~isfield(equipment,'dummyMode')              % Check whether dummy mode is required
        equipment.dummyMode = 0;                    % Default to off (RESPONSEPixx is present)
    end

    if ~isfield(equipment,'nResponseSamples')       % Check whether number of response samples is specified
        equipment.nResponseSamples = 1000;          % Set default number of response samples
    end

    if ~isfield(equipment,'responseBufferAddress')  % Check whether response buffer address is specified
        equipment.responseBufferAddress = 12e6;     % Set default response buffer address
    end

    if ~isfield(equipment,'nButtons')               % Check whether number of buttons is specified
        equipment.nButtons = 5;                     % Set default number of buttons
    end

    if ~equipment.dummyMode
        ResponsePixx('Open', equipment.nResponseSamples, equipment.responseBufferAddress, equipment.nButtons);
    end

end

