function [ envelope, phi, rampOnly, sinOnly ] = makeTemporalEnvelope( Ft, stimulus, display, phi )
%MAKETEMPORALENVELOPE Makes a vector intended for temporal contrast
%modulation. There are two possible parts to this: (1) a raised cosine ramp
%at the beginning and end of the vector, from 0 to 1; and (2) a sinusoidal
%modulation, from -1 to 1.
%
%   MAKETEMPORALENVELOPE returns a vector 100 elements long (i.e. 1 second
%   at 100 Hz) with a ramp on over the first 25 elements and off over the
%   last 25 elements, with no sinusoidal modulation (i.e. DC).
%
%   MAKETEMPORALENVELOPE(Ft) returns the same vector but with sinusoidal
%   modulation at Ft Hz, assuming a 100 Hz refresh. The phase of the
%   modulation is randomised with respect to the envelope.
%
%   MAKETEMPORALENVELOPE(Ft, stimulus) allows you to specify some
%   additional properties. Again, 100 Hz refresh is assumed. The following
%   fields can be set:
%   
%   stimulus.presentationDuration_s sets the length of the vector in
%   seconds, i.e. the presentation duration.
%
%   stimulus.rampDuration_s sets the duration of each ramp in seconds.
%
%   MAKETEMPORALENVELOPE(Ft, stimulus, display) allows you to set the
%   refresh rate of the display in the field display.refreshRate_Hz.
%
%   MAKETEMPORALENVELOPE(Ft, stimulus, display, phi) allows you to specify
%   the phase of the waveform relative to the envelope. If empty or omitted
%   the phase is randomised.
%
%   [envelope, phi] = MAKETEMPORALENVELOPE optionally returns the spatial
%   phase offset of the sinusoidal modulation relative to the window. This
%   is obviously nonsense if Ft == 0.
%
%   [envelope, phi, rampOnly] = MAKETEMPORALENVELOPE optionally returns the
%   ramps only (without the sinusoidal modulation) in the third argument.
%
%   [envelope, phi, rampOnly, sinOnly] = MAKETEMPORALENVELOPE optionally 
%   returns the sinusoidal modulation only (without the ramps) in the
%   fourth argument.

if (nargin < 4) || isempty(phi)
    phi = 2*pi*rand;
end

if (nargin < 3) || isempty(display)
    display.refreshRate_Hz = 100;
end

if ~isfield(display,'refreshRate_Hz')
    % Check whether a number has been passed directly
    if isnumeric(display)
        % If so, assume that this is the intended refresh rate
        refresh = display;
        display = struct;
        display.refreshRate_Hz = refresh;
    else
        display = struct;
        display.refreshRate_Hz = 100;
    end
end

if (nargin < 2) || isempty(stimulus)
    stimulus.presentationDuration_s = 1.0;
    stimulus.rampDuration_s = 0.25;
end

if ~isfield(stimulus,'presentationDuration_s')
    stimulus.presentationDuration_s = 1.0;
end

if ~isfield(stimulus,'rampDuration_s')
    stimulus.rampDuration_s = 0.25;
end

if (nargin < 1) || isempty(Ft)
    Ft = 0;
end

% Create a vector of times in seconds
vectorLength = display.refreshRate_Hz * stimulus.presentationDuration_s;
t = linspace(0,stimulus.presentationDuration_s,vectorLength+1);
t = t(1:vectorLength);

% Make the sinusoidal modulation
if Ft == 0
    sinOnly = ones(size(t));
else
    sinOnly = sin((t*Ft*2*pi) + phi);
end

% Make the ramps
rampLength = display.refreshRate_Hz * stimulus.rampDuration_s;
rampOnly = ones(size(t));

if rampLength > 0
    raisedPart = (1+(cos(linspace(0,pi,rampLength+1))))/2;
    raisedPart = raisedPart(2:rampLength+1);
    rampOnly(1:rampLength) = 1-raisedPart;
    rampOnly(end-rampLength+1:end) = raisedPart;
end

% Combine the vectors and return
envelope = sinOnly .* rampOnly;

end