function [ gaussianRing ] = makeGaussianRing( SD, peak, textureSupport, channelRanges )
%MAKEGAUSSIANBLOB Creates an image matrix of a Gaussian blob.
%
%   MAKEGAUSSIANBLOB returns two-dimensional (100 x 100) image matrix with
%   a Gaussian ring with a peak at a radius of 25 pixels and a standard 
%   deviation 10 pixels.
%
%   MAKEGAUSSIANBLOB(SD) returns a two-dimensional image matrix of edge
%   size 25 + (2.5 SD) containing a Gaussian ring with a peak at 50 pixels 
%   and a standard deviation SD pixels.
%
%   MAKEGAUSSIANBLOB(SD, peak) allows you to specify the peak location in
%   pixels, and returns the matrix with edge size peak + (2.5 SD).
%
%   MAKEGAUSSIANBLOB(SD, peak, textureSupport) allows you to specify the 
%   size of the texture sipport for the Gaussian ring. If a single number, 
%   this is taken as the height and width of each channel. If a pair, this
%   is taken as the number of rows (height) and columns (width), in that
%   order.
%
%   MAKEGAUSSIANBLOB(SD, peak, textureSupport, channelRanges) allows you to
%   specify the range to apply to each channel. The number of channels C is
%   also inferred from the number of elements in this is argument (or in 
%   channelBases), which should be a 2 x C matrix. The first row should
%   specify the background value of each channel; the second row should 
%   specify the range for each channel. Each column is a channel. For
%   example, the default [0 1] would return an image matrix ranging from 
%   ~0 at the edges (background) to ~1 at the peak of the blob. A value of
%   [.5 .5] would return an image matrix ranging from ~.5 at the edges, to
%   ~1 at the peak. A value of [.5 -.5] would result in a range from ~.5 at
%   the edges to ~0 at the peak. Or a value of [0 255] would result in a
%   range from ~0 at the edges to ~255 at the peak.

if nargin < 4 || isempty(channelRanges)
    channelRanges = [0 1]';
end

if nargin < 3 || isempty(peak)
    peak = 25;
end

if nargin < 1 || isempty(SD)
    SD = 10;
end

if nargin < 2 || isempty(textureSupport)
    textureSupport = 2*(peak + (2.5*SD))*ones(1,2);
end

if numel(textureSupport)==1
    textureSupport = textureSupport*ones(1,2);
end

if size(channelRanges,1)~=2 || ~ismatrix(channelRanges)
    error('MakeGaussianRing:InvalidChannelRanges', 'Channel ranges must be a 2 x N matrix!');
end

% Make a single channel
x = linspace(-textureSupport(2),textureSupport(2),textureSupport(2))/2;     % Get a vector of x-values
y = linspace(-textureSupport(1),textureSupport(1),textureSupport(1))/2;     % Get a vector of y-values
[meshX,meshY] = meshgrid(x,y);                                              % Make matrices of x- and y-values
[~,meshR] = cart2pol(meshX,meshY);

gaussianRing = exp(-((meshR-peak).^2)/((2*SD).^2));  % Make the ring

nChannels = size(channelRanges,2);
gaussianRing = repmat(gaussianRing,[1 1 nChannels]);
gaussianRing = bsxfun(@times,gaussianRing,reshape(channelRanges(2,:),1,1,nChannels));
gaussianRing = bsxfun(@plus,gaussianRing,reshape(channelRanges(1,:),1,1,nChannels));

end

