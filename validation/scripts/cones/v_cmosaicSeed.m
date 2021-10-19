function varargout = v_cmosaicSeed(varargin)
%
% Simple cone mosaic calculation.
%
% We will systematically change parameters and see that the results are stable. 
%
% BW, ISETBIO Team Copyright 2016

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);

end

%% The validation code
function ValidationFunction(runTimeParams)
%% v_cmosaicSeed
%
%  Show that we get the same spatial mosaic when we set the mosaic seed to
%  a value
%

%% Initialize
ieInit;

cm1 = coneMosaic('mosaic seed',1);
uData1 = cm1.plot('cone mosaic');

cm2 = coneMosaic('mosaic seed',1);
uData2 = cm2.plot('cone mosaic');

p1 = uData1.mosaicImage(:);
p2 = uData2.mosaicImage(:);
UnitTest.assert( (sum(abs(p1 - p2)) < 1e-8) ,'Equal');

%{
ieNewGraphWin;
plot(uData1.mosaicImage(:),uData2.mosaicImage(:),'.');
identityLine; grid on; axis equal
%}
%%  But if we change the seed, we get a different mosaic

cm2 = coneMosaic('mosaic seed',2);
uData2 = cm2.plot('cone mosaic');
p2 = uData2.mosaicImage(:);
UnitTest.assert( (sum(abs(p1 - p2)) > 0),'Not equal');

%{
ieNewGraphWin;
plot(uData1.mosaicImage(:),uData2.mosaicImage(:),'.');
identityLine; grid on; axis equal
%}

if (runTimeParams.generatePlots), end

end
