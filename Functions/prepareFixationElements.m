function elements = prepareFixationElements( subtense, centre, polarity, lineWidth )
%PREPAREFIXATIONELEMENTS Prepare drawing elements for a fixation marker.
%
%   Prepares the elements of a bullseye fixation marker with overlaid
%   crosshairs. The marker can then be drawn by passing the output to the
%   drawFixationElements function. If modifications are required, you could
%   instead draw the marker with calls to Screen('FillOval') and
%   Screen('DrawLines').
%
%   elements = PREPAREFIXATIONELEMENTS returns the structure 'ovals' with
%   the parameters required to draw a bulls-eye fixation marker using the
%   drawFixationElements function. The structure has five fields:
%   - elements.ovalRect returns the bounding rects of the ovals.
%   - elements.ovalColour returns the colour values of the ovals.
%   - elements.lineXY returns the start and end coordinates of the lines.
%   - elements.lineColour returns the colour values of the lines.
%   - elements.lineWidth returns the width of the lines.
%
%   PREPAREFIXATIONELEMENTS(subtense) lets you specify the subtense of the
%   marker (presumably in pixels, but you can technically use any unit you
%   want). If one value is given, the outer black ring is drawn with this
%   subtense, with an inner white circle of a subtense matching the width
%   of the crosshair lines (defaults to 2 pixels). If two values are given,
%   the outer black ring is drawn with the subtense of the higher number,
%   and the inner white circle with the subtense of the lower number.
%   Any further values are ignored. The outer-ring subtense defaults to 20
%   pixels.
%
%   PREPAREFIXATIONELEMENTS(subtense, centre) additionally lets you specify
%   the centre (x, y) of the marker. If only one element is passed, this is 
%   taken to be the desired centre in both x and y. If two or more, the
%   first is taken to be the x-centre, and the second to be the y-centre.
%   Defaults to [0 0].
%
%   PREPAREFIXATIONELEMENTS(subtense, centre, polarity) lets you invert the
%   contrast polarity of the marker. It might be a good idea to alternate
%   polarities occasionally if using a display susceptible to screen burn. 
%   Defaults to 0 (outer black ring, inner white circle); any non-zero 
%   value for this argument will invert the contrast polarity.
%
%   PREPAREFIXATIONELEMENTS(subtense, centre, polarity, lineWidth)
%   additionally lets you specify the width of the crosshair lines
%   (defaults to 2 pixels). This really only matters if you're passing the
%   output to the drawFixationElements function; if you're using
%   Screen('DrawLines'), you'll need to specify the line width there.

if (nargin < 4) || isempty(lineWidth)
    lineWidth = 1;
end

if (nargin < 3) || isempty(polarity)
    polarity = 0;
end

if (nargin < 2) || isempty(centre)
    centre = [0 0];
end

if (nargin < 1) || isempty(subtense)
    subtense = 20;
end

if isscalar(centre)
    centre = centre*ones(1,2);
end

if isscalar(subtense)
    subtense = [subtense 2];
end

subtense = sort(subtense(1:2));

innerRect = [0 0 subtense(1) subtense(1)];
outerRect = [0 0 subtense(2) subtense(2)];

elements.ovalRect = CenterRectOnPointd([outerRect; innerRect], centre(1), centre(2))';
elements.ovalColour = [zeros(3,1) ones(3,1)];

outerLength = subtense(2)/2;
linesX = [-outerLength outerLength 0 0] + centre(1);
linesY = [0 0 -outerLength outerLength] + centre(2);

elements.lineXY = [linesX; linesY];
elements.lineColour = 0.5;
elements.lineWidth = lineWidth;

if polarity
    elements.ovalColour = fliplr(elements.ovalColour);
end

end

