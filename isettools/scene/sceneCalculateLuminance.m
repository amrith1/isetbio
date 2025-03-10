function [luminance, meanLuminance] = sceneCalculateLuminance(scene)
% Calculate scene luminance (cd/m^2)
%
% Syntax:
%   [luminance, meanLuminance] = sceneCalculateLuminance(scene)
%
% Description:
%    Calculate the luminance (cd/m^2) at each point in a scene.
%
%    Calculations of the scene luminance usually begin with radiance
%    (photons/sec/nm/sr/m^2). These values are converted to energy, and
%    then transformed with the luminosity function and wavelength sampling
%    scale factor.
%
% Inputs:
%    scene         - A scene structure
%
% Outputs:
%    luminance     - The luminance at each point in the scene
%    meanLuminance - The mean scene luminance
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC, 2003.
%    12/29/17  jnm  Formatting
%    01/25/18  jnm  Formatting update to match Wiki.

if notDefined('scene'), error('Scene variable required.'); end

% User may turn on the wait bar, or not, with ieSessionSet('wait bar')
showBar = ieSessionGet('wait bar');

nCols = sceneGet(scene, 'cols');
nRows = sceneGet(scene, 'rows');
wave = sceneGet(scene, 'wave');
binWidth = sceneGet(scene, 'binwidth');

% Read the V-lambda curve based from the photopic luminosity data at the
% relevant wavelengths for these data. If these data extend beyond 780, we
% still stop at that level because the luminosity is zero past there.
fName = fullfile(isetbioDataPath, 'human', 'luminosity.mat');
V = ieReadSpectra(fName, wave);

if showBar, h = waitbar(0, 'Calculating luminance from photons'); end

% Calculate the luminance from energy
if nRows * nCols < ieSessionGet('image size threshold')
    % If the image is small enough, we calculate luminance using a single
    % matrix multiplication. We don't set a particular criterion size
    % because that may differ depending on memory in that user's computer.
    energy = sceneGet(scene, 'energy');
    if isempty(energy)
        if showBar, waitbar(0.3, h); end
        photons = sceneGet(scene, 'photons');
        energy = Quanta2Energy(wave(:), photons);
    end
    
    if showBar, waitbar(0.7, h); end
    
    [xwData, rows, cols, ~] = RGB2XWFormat(energy);
    
    % Convert into luminance using the photopic luminosity curve in V.
    luminance = 683 * (xwData * V) * binWidth;
    luminance = XW2RGBFormat(luminance, rows, cols);
else
    % We think we are in this condition because the image is big. So we
    % convert to energy one waveband at a time and sum  the wavelengths
    % weighted by the luminance efficiency function. When the photon image
    % is really big, should we figure that there is no stored energy?
    % energy = sceneGet(scene, 'energy');
    wave = sceneGet(scene, 'wave');
    lumWaves = find(wave <= 780, 1, 'last');  % Luminance wavelength range
    luminance = zeros(nRows, nCols);
    for ii = 1 : lumWaves
        if showBar, waitbar(ii / lumWaves, h); end
        energy = sceneGet(scene, 'energy', wave(ii));
        luminance = luminance + 683 * energy * V(ii) * binWidth;
    end
end

% Close the waitbar
if showBar, close(h); end

if nargout == 2, meanLuminance = mean(luminance(:)); end

end