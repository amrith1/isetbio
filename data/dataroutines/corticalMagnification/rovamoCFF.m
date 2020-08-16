%% Notes on the formulae used by Rovamo et al. 1984
%
% CRITICAL FLICKER FREQUENCY AND M-SCALING OF STIMULUS SIZE AND RETINAL
%   ILLUMINANCE  
%
% This is a series of formulae they use to deal with flicker frequency,
% luminance and cortical magnification.
%
% JEF/BW

%{
 We could use grabit to get the data from Figures 
 N = 4 subjects

  1. CFF as a function of eccentricity for a fixed size and luminance.
     Size is 10 deg and mean luminance is 2510 Trolands with an 8mm pupil
     diamter, so pupil area = pi * 4^2;
     which is (2510 / area) ~ 50 cd/m2 

  2. CFF as a f of e for stimulus area that is scaled by M
  3. CFF as a f of e for stimulus luminance that is scaled by M
  4. The CFF when scaled for both area and luminance

The formulae they use has a Ricco's law term that changes a bit from what
Koendrink did in 1978b, a few years before them.
%}

%  What do we do with this information?
%
%  Suppose we have an image and we want to know the CFF at some
%  eccentricity.  Then we can use the formulae here to estimate the highest
%  flicker frequency that a subject could detect at each point in the
%  scene. We calculate the average luminance of the scene at that
%  eccentricity, we scale it by the ricco's area, and then (figure 4), then
%  CFF is constant at all eccentricities.
%
%  What level is it constant at?  Well, if we have one data point as a
%  function of every luminance level, we can figure that out.  So we need a
%  graph that is CFF as a function of luminance.
%

%% Formulae

%
% E is eccentricity in degrees
% M scaling in mm/deg
%
% {
% Plot the basic function
% At 24 deg M is one.  That might prove convenient.
%
ecc = 0:0.1:100;
M = 7.99*(1 + 0.29*ecc + 0.000012*ecc.^3).^-1; 
ieNewGraphWin;
plot(ecc,M,'-');
xlabel('Eccentricity (deg)'); ylabel('Rovamo magnification (mm/deg)');
grid on
%}

% {
% Ricco's area formula
% ricco in mm on the surface of V1
% At 20 deg Ricco's area they calculate to be approximately 100 microns,
% which is about 1/3 of a degree.

ricco = 0.0263 * (1 + 3.15 * M.^-1);
ieNewGraphWin;
plot(ecc,ricco,'-');
xlabel('Eccentricity (deg)'); ylabel('Ricco area (mm)');
grid on

%}


