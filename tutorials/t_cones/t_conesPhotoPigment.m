% Illustrate photoPigment object
%
% Description:
%    The photoPigment object represents the spectral responsivity of
%    the cone photopigments.  These values are needed to calculate the
%    capture of light by cones, along with the oi spectral irradiance
%    and the other inert pigments (lens, macular). 
%
%    This tutorial illustrates how it works.
%
% See also
%    

%% Initialize
ieInit;

%% Create photoPigment object
% Plot spacing at 5 nm looks a little nicer than the default spacing.
pp = photoPigment('wave', 400:5:700);

%% Wavelength
% The internal wavelength representation of the parameters is from 390:830
% at 1 nm. The user can set the wavelength representation used for
% interface with other routines. By default this is 400:10:700.

%%  Absorbance
% The cone absorbance function used by default is obtained via data routine
% coneAbsorbanceReadData.
%
% Absorbance is sometimes called optical density.
%
% The peak absorbance is 1 by convention in how the values are tabulated.
ieNewGraphWin;
plot(pp.wave, pp.absorbance)
grid on;
xlabel('Wavelength (nm)');
ylabel('Relative sensitivity');

%% Geometry
% See coneDensityReadData for explanation of retinal coordinate system.
eccentricity = 0.0;
angle = 0;

% Spacing (um), aperture (um), density (cones/mm2)
[s, a, d] = coneSizeReadData('eccentricity', eccentricity, 'angle', angle)

%%