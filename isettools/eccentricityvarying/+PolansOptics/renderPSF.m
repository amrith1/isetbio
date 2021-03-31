function renderPSF(axesHandle, xSupport, ySupport, thePSF, xyRange, zLevels, cmap, contourLineColor, varargin)
    % Parse input
    p = inputParser;
    p.addParameter('superimposedConeMosaic', [], @(x)(isempty(x)||isa(x, 'coneMosaicHex')));
    p.addParameter('fontSize', 14, @isnumeric);
    p.addParameter('plotTitle', '', @ischar);
    p.addParameter('xyTicks', -8:1:8, @isnumeric);
    
    p.parse(varargin{:});
    theConeMosaic = p.Results.superimposedConeMosaic;
    xyTicks = p.Results.xyTicks;
    fontSize = p.Results.fontSize;
    plotTitle = p.Results.plotTitle;
    
    if (~isempty(theConeMosaic))
        % Retrieve cone positions (microns), cone spacings, and cone types
        cmStruct = theConeMosaic.geometryStructAlignedWithSerializedConeMosaicResponse();
        conePositionsArcMin = cmStruct.coneLocs * 60;
        coneAperturesArcMin = cmStruct.coneApertures * 60;
        renderConeApertures(axesHandle, conePositionsArcMin, coneAperturesArcMin, [1 1 1]-contourLineColor);
    end
    
    
    C = contourc(xSupport, ySupport, thePSF, zLevels);
    dataPoints = size(C,2);
    
    cmapLength = size(cmap,1);
    minZ = 0;
    maxZ = 1;
    
    hold(axesHandle, 'on');
    
    % Faces for all zLevels
    startPoint = 1;
    while (startPoint < dataPoints)
        theLevel = C(1,startPoint);
        theCMapIndex = round((theLevel-minZ)/(maxZ-minZ)*cmapLength);
        theCMapIndex = min([cmapLength max([1 theCMapIndex])]);
        theLevelVerticesNum = C(2,startPoint);
        x = C(1,startPoint+(1:theLevelVerticesNum));
        y = C(2,startPoint+(1:theLevelVerticesNum));
        v = [x(:) y(:)];
        f = 1:numel(x);
        patch(axesHandle, 'Faces', f, 'Vertices', v, ...
                'FaceColor', cmap(theCMapIndex,:), ...
                'FaceAlpha', 0.5, ...
                'EdgeColor', 'none');
        
        startPoint = startPoint + theLevelVerticesNum+1;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    end
    
   % Edges for the outlined levels only
    startPoint = 1;
    while (startPoint < dataPoints)
        theLevelVerticesNum = C(2,startPoint);
        x = C(1,startPoint+(1:theLevelVerticesNum));
        y = C(2,startPoint+(1:theLevelVerticesNum));
        v = [x(:) y(:)];
        f = 1:numel(x);
        patch(axesHandle, 'Faces', f, 'Vertices', v, ...
                  'FaceColor', 'none', 'EdgeColor', contourLineColor);
        startPoint = startPoint + theLevelVerticesNum+1;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    end
    xlabel(axesHandle, 'arc min');
    ylabel(axesHandle, 'arc min');
    axis(axesHandle, 'equal');
    grid(axesHandle, 'on');
    box(axesHandle, 'on');
    set(axesHandle, 'XLim', xyRange, 'YLim', xyRange, 'Color', [1 1 1]);
    set(axesHandle, 'XTick', xyTicks, 'YTick', xyTicks);
    set(axesHandle, 'FontSize', fontSize);
    
    if (~isempty(plotTitle))
        title(axesHandle,plotTitle);
    end
    
    drawnow;
end

function renderConeApertures(axesHandle, conePositionsArcMin, coneAperturesArcMin, color)
    hold(axesHandle, 'on');
    
    xOutline = cosd(0:5:360);
    yOutline = sind(0:5:360);
    for iCone = 1:size(conePositionsArcMin,1)
        r = 0.5*coneAperturesArcMin(iCone);
        plot(axesHandle, xOutline*r +  conePositionsArcMin(iCone,1), ...
                         yOutline*r +  conePositionsArcMin(iCone,2), ...
                         'k-', 'Color', color, 'LineWidth', 1.5);
    end
                 
end

