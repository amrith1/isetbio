function [theOI, thePSF, psfSupportMinutesX, psfSupportMinutesY, psfSupportWavelength] = oiForSubjectAtEccentricity(subjectID, whichEye, ecc, ...
    pupilDiamMM, wavelengthsListToCompute, micronsPerDegree, varargin)

    % Parse input
    p = inputParser;
    p.addRequired('subjectID', @(x)(isscalar(x)&&(x>=1)&&(x<=10)));
    p.addRequired('whichEye', @(x)(ischar(x)&&(ismember(x,{PolansOptics.constants.leftEye, PolansOptics.constants.rightEye}))));
    p.addRequired('ecc', @(x)(isnumeric(x)&&(numel(x) == 2)));
    p.addRequired('pupilDiamMM', @(x)(isscalar(x)&&(x>=1)&&(x<=4)));
    p.addRequired('wavelengthsListToCompute', @(x)(isnumeric(x)));
    p.addRequired('micronsPerDegree', @(x)(isscalar(x)));
    p.addParameter('inFocusWavelength', 550, @isscalar);
    p.addParameter('wavefrontSpatialSamples', 801, @isscalar)
    p.addParameter('subtractCentralRefraction', true, @islogical);
    p.addParameter('noLCA', false, @islogical);
    p.parse(subjectID, whichEye, ecc, pupilDiamMM, wavelengthsListToCompute, micronsPerDegree, varargin{:});
    
    inFocusWavelength = p.Results.inFocusWavelength;
    wavefrontSpatialSamples = p.Results.wavefrontSpatialSamples;
    subtractCentralRefraction = p.Results.subtractCentralRefraction;
    noLCA = p.Results.noLCA;
   

    if (strcmp(whichEye, PolansOptics.constants.leftEye))
        % Flip horizontal ecc sign because Z-coeffs correspond to retinal
        % eccentricities on the right eye
        ecc(1) = -ecc(1);
    end
    
    % Obtain z-coeffs at desired eccentricity
    zCoeffs = zCoeffsForSubjectAtEcc(subjectID, ecc, subtractCentralRefraction);
    
    % Compute PSF and WVF from z-Coeffs for the desired pupil and wavelenghts
    [thePSF, ~, ~,~, psfSupportMinutesX, psfSupportMinutesY, theWVF] = ...
        computePSFandOTF(zCoeffs, ...
             wavelengthsListToCompute, wavefrontSpatialSamples, ...
             PolansOptics.constants.measurementPupilDiamMM, ...
             pupilDiamMM, inFocusWavelength, false, ...
             'doNotZeroCenterPSF', true, ...
             'micronsPerDegree', micronsPerDegree, ...
             'name', sprintf('Polans subject %d, eccentricity: %2.1f,%2.1f degs', subjectID, ecc(1), ecc(2)));
    
    % Remove wavelength-dependent defocus if noLCA is set
    if (noLCA)
        % Set all PSFs to the PSF at the in-focus wavelenth
        [~,wTarget] = min(abs(wavelengthsListToCompute-inFocusWavelength));
        targetPSF = thePSF(:,:,wTarget);
        for waveIndex = 1:numel(wavelengthsListToCompute)
            theWVF.psf{waveIndex} = targetPSF;
            thePSF(:,:,waveIndex) = targetPSF;
        end
    end
    
    % Generate the OI from the wavefront map
    theOI = wvf2oiSpecial(theWVF, micronsPerDegree, pupilDiamMM);
    
    psfSupportWavelength = wavelengthsListToCompute;
end

function theOI = wvf2oiSpecial(theWVF, umPerDegree, pupilDiameterMM)

    % Generate oi from the wvf
    theOI = wvf2oi(theWVF);
    
    % Adjust the OI's fNumber and focalLength to be consistent with the
    % micronsPerDegree and pupilDiameter of the WVF
    optics = oiGet(theOI, 'optics');
    focalLengthMM = (umPerDegree * 1e-3) / (2 * tand(0.5));
    fLengthMeters = focalLengthMM * 1e-3;
    pupilRadiusMeters = (pupilDiameterMM / 2) * 1e-3;
    pupilDiameterMeters = 2 * pupilRadiusMeters;
    optics = opticsSet(optics, 'fnumber', fLengthMeters / pupilDiameterMeters);
    optics = opticsSet(optics, 'focalLength', fLengthMeters);
    theOI = oiSet(theOI, 'optics', optics);

    %heightDegs = oiGet(theOI, 'hangular');
    %heightMicrons = oiGet(theOI, 'height')*1e6;
    %fprintf('Achievend microns per deg: %f (desired: %f)\n', heightMicrons/heightDegs, umPerDegree);  
end


function  interpolatedZcoeffs = zCoeffsForSubjectAtEcc(subjectID, ecc, subtractCentralRefraction)

    % Get original z-coeffs at all measured eccentricities
    [zMap, zCoeffIndices] = PolansOptics.constants.ZernikeCoefficientsMap(subjectID);
    zCoeffsNum = size(zMap,3);
    
    % Interpolate zMap at desired ecc
    [X,Y] = meshgrid(...
        PolansOptics.constants.measurementHorizontalEccentricities, ...
        PolansOptics.constants.measurementVerticalEccentricities);
    
    interpolatedZcoeffs = zeros(1, 30);
    for zIndex = 1:zCoeffsNum
         % Retrieve the XY map for this z-coeff
         zz = squeeze(zMap(:,:,zIndex));
         
         % The 4-th z-coeff is defocus. Subtract central defocus from all
         % spatial positions
         if ((zCoeffIndices(zIndex) == 4) && (subtractCentralRefraction))
             idx = find((X==0) & (Y==0));
             zz = zz - zz(idx);
         end
         % Interpolate the XY map at the desired eccentricity
         interpolatedZcoeffs(zCoeffIndices(zIndex)+1) = interp2(X,Y,zz, ecc(1), ecc(2));
     end
end