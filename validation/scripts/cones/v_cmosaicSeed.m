%% v_cmosaicSeed
%
%  Show that we get the same spatial mosaic when we set the mosaic seed to
%  a value
%

cm = coneMosaic('mosaic seed',1);
uData = cm.plot('cone mosaic');

cm2 = coneMosaic('mosaic seed',1);
uData2 = cm2.plot('cone mosaic');

ieNewGraphWin;
plot(uData.mosaicImage(:),uData2.mosaicImage(:),'.');
identityLine; grid on; axis equal

%%  But if we change the seed, we get a different mosaic

cm2 = coneMosaic('mosaic seed',2);
uData2 = cm2.plot('cone mosaic');

ieNewGraphWin;
plot(uData.mosaicImage(:),uData2.mosaicImage(:),'.');
identityLine; grid on; axis equal

%%