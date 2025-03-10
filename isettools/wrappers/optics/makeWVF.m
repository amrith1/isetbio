function theWVF = makeWVF(wavefrontSpatialSamples, zcoeffs, measWavelength, wavelengthsToCompute, ...
    measPupilDiameterMM, calcPupilDiameterMM, umPerDegree, name, varargin)

    % Parse input
    p = inputParser;
    p.addParameter('flipPSFUpsideDown', false, @islogical);
    p.addParameter('upsampleFactor', [], @(x)(isempty(x) || ((isnumeric(x))&&(numel(x)==1)&&(x>0))));
    p.parse(varargin{:});
    flipPSFUpsideDown = p.Results.flipPSFUpsideDown;
    upsampleFactor = p.Results.upsampleFactor;
    
    theWVF = wvfCreate(...
    			'umPerDegree', umPerDegree, ...
                'calc wavelengths',wavelengthsToCompute,...
                'measuredpupil', measPupilDiameterMM, ...
                'calc pupil size',calcPupilDiameterMM, ...
                'spatialsamples', wavefrontSpatialSamples, ...
                'zcoeffs', zcoeffs,...
                'measured wl', measWavelength, ...
                'name', name, ...
                'flipPSFUpsideDown', flipPSFUpsideDown);
    
    if (~isempty(upsampleFactor))
        arcminPerSample = wvfGet(theWVF,'psf angle per sample','min',measWavelength);
        theWVF = wvfSet(theWVF,'ref psf sample interval',arcminPerSample/double(upsampleFactor));
    end
    
    % Now compute the PSF
    theWVF = wvfComputePSF(theWVF);
end