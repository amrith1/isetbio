function [spacing, aperture, density, params, comment] = coneSizeReadData(varargin)
% Cone size parameters for different eccentricities and angles
%
% Syntax:
%    [spacing, aperture, density, params, comment] = coneSizeReadData(varargin)
%
% Descirption:
%     Calculate expected cone spacing and aperture size at this
%     eccentricity and angle. This is done based on cone density, obtained
%     via parameter coneDensitySource.
%
%     The coordinate system is as defined by coneDensityReadData.
%
%     The cone inner segment aperture is set to 0.7*spacing.
%
% Input:
%     ecc          Eccentricity in meters.
%     ang          Angle in degrees.
%
% Output:
%     spacing      Center to center spacing in meters.
%     aperture     Inner segment linear capture size in meters.  Typically,
%                  we set the photoPigment pdHeight and pdWidth both equal
%                  to this (diameter)
%     density      Cones per mm2. This is the density returned by
%                  coneDensityReadData. 
%
% Optional key/value pairs
%    'species'                What species? 'human' (default)
%    'cone density source'    Source for cone density estimate, on which
%            other values are based. This is passed on to
%            coneDensityReadData. See help for that function.
%    'eccentricity'           Retinal eccentricity, default is 0.
%    'angle'                  Polar angle of retinal position in degrees
%                             (default 0). May be a vector same numel as
%                             eccentricity.
%    'which eye'              Which eye, 'left' or 'right' (default 'left').
%    'eccentriticy units'     String specifying units for eccentricity.
%                                  'm'                  Meters (default).             
%                                  'mm'                 Millimeters.
%                                  'um'                 Micrometers.
%                                  'deg'                Degrees of visual angle, 0.3 mm/deg.
%    'angle units'            String specifying units  for angle.
%                                  'deg'                Degrees (default).
%                                  'rad'                Radians.
%    'use parfor'             Logical. Default false. Used to parallelize
%                             the interp1 function calls which take a
%                             long time. This is useful when generating
%                             large > 5 deg mosaics.
%
% See also: 
%   coneDensityReadData

% BW ISETBIO Team, 2016
%
% 08/16/17  dhb  Call through new coneDensityReadData rather than old coneDensity.
% 02/17/19  npc  Added useParfor k/v pair

% Example:
%{
  % Returns a single value
  [spacing, aperture, density, params, comment] = coneSizeReadData;
%}
%{
 % Input arrays of eccentricities and angles 
 ecc = logspace(-0.5,1.5,20);
 angles = ones(size(ecc))*90;
 [spacing,aperture,density] = ...
        coneSizeReadData('eccentricity',ecc, 'eccentricity units','deg', ...
                         'angle',angles,'angle units','deg',...
                         'cone density source','curcio1990');
 ieNewGraphWin([],'tall');
 subplot(2,1,1); semilogy(ecc,pi*(aperture).^2); grid on;
 xlabel('Eccentricity (deg)')
 ylabel('Cone aperture area (m^2)');
 subplot(2,1,2); semilogy(ecc,density); grid on;
 xlabel('Eccentricity (deg)')
 ylabel('Cone density (cones/mm^2)');
%}

%% Parse inputs
varargin = ieParamFormat(varargin);

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('species','human', @ischar);
p.addParameter('conedensitysource','curcio1990',@(x) (ischar(x) || isa(x,'function_handle')));
p.addParameter('eccentricity',0, @isnumeric);
p.addParameter('angle',0, @isnumeric);
p.addParameter('whicheye','left',@(x)(ismember(x,{'left','right'})));
p.addParameter('eccentricityunits','m',@ischar);
p.addParameter('angleunits','deg',@ischar);
p.addParameter('useparfor', false, @(x)((islogical(x))||(isempty(x))));
p.parse(varargin{:});

%% Set up params return.
params = p.Results;

%% Take care of case where a function handle is specified as source
%
% This allows for custom data to be defined by a user, via a function that
% could live outside of ISETBio.
%
% This function needs to handle 
if (isa(params.conedensitysource,'function_handle'))
    [spacing, aperture, density, comment] = params.coneSizeSource(varargin{:});
    return;
end

%% Read the density.

% This can just take the params structure, except we change the source name
% 
[density,~,comment] = coneDensityReadData(varargin{:});
conesPerMM = sqrt(density);
conesPerM = conesPerMM*1e3;

%% Compute spacing 
spacing = 1./conesPerM;

%% Compute aperture

% The 0.7 value should be a parameter.  It is the size of the inner segment
% as a fraction of the spacing.  We need to document why we chose this
% number (BW).
aperture = 0.7*spacing;  

end