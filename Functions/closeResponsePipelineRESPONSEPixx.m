function closeResponsePipelineRESPONSEPixx( equipment )
%CLOSERESPONSEPIPELINERESPONSEPIXX Close the response pipeline for the
%RESPONSEPixx.
%   CLOSERESPONSEPIPELINERESPONSEPIXX closes the RESPONSEPixx for
%   button response collection.
%
%   INITIALISERESPONSEPIPELINERESPONSEPIXX(equipment) allows you to 
%   indicate a dummy mode (RESONSEPixx absent) that is useful for
%   development and debugging. 'equipment' is a structure, but this
%   function only reads one field:
%
%   equipment.dummyMode [default = 0] indicates whether the function should
%   run in the absence of a RESPONSEPixx box. Defaults to 0, indicating
%   that a RESPONSEPixx is present. Set to 1 to initialise dummy mode,
%   using the keyboard as a response device. In practice, this just
%   bypasses the function, but allows it to remain in the experimental code
%   without returning an error.
%
%   06/09/16 PTG wrote it.

    if nargin < 1
        equipment = struct;
    end

    if ~isfield(equipment,'dummyMode')              % Check whether dummy mode is required
        equipment.dummyMode = 0;                    % Default to off (RESPONSEPixx is present)
    end

    if ~equipment.dummyMode
        ResponsePixx('Close');
    end

end

