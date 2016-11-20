function invNoise = makeNoiseInvF( noiseSize, exponent )
%MAKENOISEINVF Make a 1/f^n noise texture in one, two or three dimensions.
%   MAKENOISEINVF returns a 2-D, 1/f noise texture 100 by 100 pixels, with
%   pixel values normalised to the range (0, 1).
%
%   MAKENOISEINVF(noiseSize) returns a noise texture of noiseSize. The
%   dimensionality is inferred from numel(noiseSize). Defaults to [100
%   100], which is a 2-D texture of 100 pixels per side. The function will
%   simply ignore any elements past the third.
%
%   MAKENOISEINVF(noiseSize, exponent) allows you to specify the exponent
%   in the 1/f^n function. Defaults to 1 (i.e. spectrum is 1/f).
%
%   08/09/16 PTG wrote it.

    if nargin < 2 || isempty(exponent)
        exponent = 1;
    end
    
    if nargin < 1 || isempty(noiseSize)
        noiseSize = [100 100];
    end

    centreStim = round(noiseSize/2);
    nDimensions = numel(2*centreStim);
    pixelNoise = rand(2*centreStim);
    pixelNoiseFFT = fftshift(fftn(pixelNoise));
    

    if nDimensions == 1
        mr = -centreStim:(centreStim-1);
        mr(centreStim+1) = 1;                                                           % Replace zero value with one (for inverse)
    elseif nDimensions == 2
        [mx, my] = meshgrid(-centreStim(2):(centreStim(2)-1),...
            -centreStim(1):(centreStim(1)-1));
        mr = sqrt(mx.^2 + my.^2);
        mr(centreStim(1)+1,centreStim(2)+1) = 1;                                        % Replace zero value with one (for inverse)
    elseif nDimensions == 3
        [mx, my, mz] = meshgrid(-centreStim(2):(centreStim(2)-1),...
            -centreStim(1):(centreStim(1)-1), -centreStim(3):(centreStim(3)-1));
        mr = sqrt(mx.^2 + my.^2 + mz.^2);
        mr(centreStim(1)+1,centreStim(2)+1,centreStim(3)+1) = 1;                        % Replace zero value with one (for inverse)
    end

    pixelNoiseFFT = pixelNoiseFFT .* (1./(mr.^exponent));                               % Convolve FFT with frequency spectrum
    invNoise = real(ifftn(fftshift(pixelNoiseFFT)));                                    % Performe inverse FFT
    
    if any(size(invNoise) > noiseSize)                                                  % Crop if necessary
        if nDimensions == 1
            invNoise = invNoise(1:noiseSize);
        elseif nDimensions == 2
            invNoise = invNoise(1:noiseSize(1),1:noiseSize(2));
        elseif nDimensions == 3
            invNoise = invNoise(1:noiseSize(1),1:noiseSize(2),1:noiseSize(3));
        end
    end
    
    invNoise = (invNoise - min(invNoise(:)))/(max(invNoise(:)) - min(invNoise(:)));     % Normalise

end

