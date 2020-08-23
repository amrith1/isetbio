%% s_watsonPyramid
%
% Formulae from the Watson Pyramid paper
%
%  
%﻿The Field of View, the Field of Resolution, and the Field of Contrast Sensitivity  
%

% FOV (he calls Fixated FOV for FFoV)

% When fixated, Beau claims FOV is -65 deg (in) to 105 deg (out)
%                                  -74 deg (down) to 62 deg (up)
%


%% Highest spatial freq that can be detected with contrast = 1
%
% (We should conditionalize on size and duration of the grating, also mean
% luminance/color) 
%
% What is the formula for the CSF in Figure 1?  Maybe the formula is in
% Refs 5-9?  Not obvious, though.


%% The pyramid scheme
%
%    (Equation 1)
%    S = C0 + CW W + CF F + CL L
%
%  S = Log contrast sensitivity
%  W - Temporal Freq  (Hz)
%  F - Spatial Freq   (cpd)
%  L - Luminance (cd/m2)
%
% He will give us the constants at some point
%
% What is the pyramid?  Suppose you fix L at 100.  Then you have
%
%    S = C0' + CW W + CF F
% 
% Which is Figure 2.  TO be a pyramid, notice, we need both positive and
% negative frequency values.  Hmmm.  What does that mean exactly?  It
% imposes symmetry in some sense.  But the formula for the pyramid doesn't
% really work with that.  If we have +F  and -F the S valuke would be quite
% different in the linear equation.  So, what's up?
%
%   Figure 2 plots the points that satsify this linear equation.  These
%   points form a surface.  For example, take the points where S = 0.  For
%   those points, when L is a fixed luminance level, we have
%   
%        0 = (K) + CW W + CF F, where K = C0 + CL L
%
%        -K   = CW W + CF F
%       -(CW W + K)  = CF F
%
%  If the weights are both 1 you can see that this is just
%
%        F =  -W + K
%        W =  F - K

%% What's the pyramid?
%
% I know what we mean when we plot positive spatial and temporal frequency.
%  Don Kelly provided a summary of 15 years of work in a paper in 1979
%  showing S = log(contrast sensitivity) as a function of these two
%  variable.s

% fs = logspace(-0.2, log10(30), 80);
% ft = logspace(-0.2, log10(60), 100);

%%

% The Kelly spatial-temporal frequency contrast sensitivity function
% Row is space, col is time
fs = linspace(1, 30, 80);
ft = linspace(1, 60, 100);
sens = humanSpaceTime('kelly79', fs, ft);

% Here is it
surf(ft, fs, sens);
set(gca, 'xscale', 'linear', 'yscale', 'linear');
set(gca, 'xlim', [0 35], 'ylim', [0 20]);
xlabel('Temporal freq (Hz)');
ylabel('Spatial freq (cpd)')

%% Where's the pyramid?

% Rotate Kelly's surface around so you can see the planar side.
az = 57.8821; el = 7.0814;
view([az,el]);

%%
% This is one of the sides of Beau's Pyramid.  Points outside of the
% surface are invisible, and points inside of the surface are visible.
% 
az = 0; el = 90;
view([az el]);

%%  Suppose we want to plot -F and -W, too.

% What does a F and -F sin(2*piF*x) look like?
F = 2;
x = (0:0.01:1);
vP = sin(2*pi*F*x);
vN = sin(2*pi*(-1*F)*x);

% They are just opposite contrast - black is white and white is black.
ieNewGraphWin;
p = plot(x,vP,'k-',x,vN,'k:');
for ii=1:2, p(ii).LineWidth = 2; end
legend({'Positive F','NegativeF '})

%% The pyramid

CS = [rot90(sens,2), flipud(sens);
    flipud(rot90(sens,-2)), sens];

Time = [fliplr(-ft),ft];
Space = [fliplr(-fs),fs];
imagesc(Time,Space,CS)

%%
[X,Y] = meshgrid(Time,Space);
surf(X,Y,CS)
ylabel('space');
xlabel('time');
zlabel('CS')

%% END

