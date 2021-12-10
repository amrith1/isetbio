function [coneAbsorptions] = modify_cone_absorptions(parameterList,onSelectivity,offSelectivity,visualize)
    %{ 
        Modify cone absorptions from testing set according to ON and OFF 
        midget RGC selectivities distributed randomly the respective RGC 
        mosaics.

        @ Parameters
        @ parameterList - string specifying path to experiment of
        interest
        @ onSelectivity - double between 0 and 1 specifying proportion of 
        ON midget RGCs able to be selectively activated
        @ offSelectivity - double between 0 and 1 specifying proportion of
        OFF midget RGCs able to be selectively activated
        @ visualize - boolean specifying whether to visualize cone and RGC
        mosaics

        @ Return
        @ coneAbsorptions - vector of modified cone absorptions simulating
        RGC selectivity
    %} 
    
    path = 'path_to_repo\project\arProject\';

    % Load test dataset cone absorptions
    load([path 'final_data\' parameterList '.mat']);
    coneAbsorptions = test_cones;
    
    % Load ON and OFF midget mosaics and cone mosaic
    load([path 'final_data\midget_mosaics\' parameterList '.mat']);
    onMRGCmosaic = read(onMidgetds);
    offMRGCmosaic = read(offMidgetds);
    
    
    % ----------- SIMULATE ON MIDGET SELECTIVITY ----------------

    coneRFpositions = onMRGCmosaic.inputConeMosaic.coneRFpositionsDegs;
    coneRFspacings = onMRGCmosaic.inputConeMosaic.coneRFspacingsDegs;
    
    rgcRFpositions = onMRGCmosaic.rgcRFpositionsDegs;
    rgcRFspacings = onMRGCmosaic.rgcRFspacingsDegs;
    
    % Randomly assign non-selective cells
    rng('default');
    onMRGCtot = length(rgcRFpositions);
    onNonselective = randperm(onMRGCtot, round(onMRGCtot*(1-onSelectivity)));
    onNonselectiveConeIndices = [];
    
    for cellIndex = onNonselective
        % Instantiate an ROI corresponding to RGC receptive field
        theROI = regionOfInterest(...
                'geometryStruct', struct(...
                'units', 'degs', ...
                'shape', 'ellipse', ...
                'center', rgcRFpositions(cellIndex,:), ...
                'minorAxisDiameter', rgcRFspacings(1,cellIndex), ...
                'majorAxisDiameter', rgcRFspacings(1,cellIndex), ...
                'rotation', 0));
    
        % Determine cones encompassed by RGC receptive field
        indicesOfPointsInside = theROI.indicesOfPointsInside(coneRFpositions);
        onNonselectiveConeIndices = [onNonselectiveConeIndices; indicesOfPointsInside];
    
        coneAbsorptions(:,indicesOfPointsInside) = coneAbsorptions(:,indicesOfPointsInside) * 0;
    end
    
    
    % ------------- SIMULATE OFF MIDGET SELECTIVITY -----------------

    rgcRFpositions = offMRGCmosaic.rgcRFpositionsDegs;
    rgcRFspacings = offMRGCmosaic.rgcRFspacingsDegs;
    
    % Randomly assign non-selective cells
    offMRGCtot = length(rgcRFpositions);
    offNonselective = randperm(offMRGCtot, round(offMRGCtot*(1-offSelectivity)));
    offNonselectiveConeIndices = [];
    
    for cellIndex = offNonselective
        % Instantiate an ROI corresponding to RGC receptive field
        theROI = regionOfInterest(...
                'geometryStruct', struct(...
                'units', 'degs', ...
                'shape', 'ellipse', ...
                'center', rgcRFpositions(cellIndex,:), ...
                'minorAxisDiameter', rgcRFspacings(1,cellIndex), ...
                'majorAxisDiameter', rgcRFspacings(1,cellIndex), ...
                'rotation', 0));
    
        % Determine cones encompassed by RGC receptive field
        indicesOfPointsInside = theROI.indicesOfPointsInside(coneRFpositions);
        offNonselectiveConeIndices = [offNonselectiveConeIndices; indicesOfPointsInside];
    
        coneAbsorptions(:,indicesOfPointsInside) = coneAbsorptions(:,indicesOfPointsInside) * 0;
    end
    

    % ------------------ VISUALIZE MODIFICATIONS --------------------

    if visualize

        % Visualize cone absorption modifications
        figure;
        scatter(coneRFpositions(:,1),coneRFpositions(:,2),35,'black','filled');
        hold on;
        scatter(coneRFpositions(onNonselectiveConeIndices,1),coneRFpositions(onNonselectiveConeIndices,2),35,'cyan','filled');
        hold on;
        scatter(coneRFpositions(offNonselectiveConeIndices,1),coneRFpositions(offNonselectiveConeIndices,2),35,'magenta','filled');
        xlabel('retinal space (degrees)');
        ylabel('retinal space (degrees)');
        set(gca,'Color',[0.75 0.75 0.75]);
        set(gca,'XLim',[-10.9 -9.1]);
        set(gca,'YLim',[-0.9 0.9]);
        
        % Visualize cone and RGC mosaics
        onMRGCmosaic.inputConeMosaic.visualize();
        onMRGCmosaic.visualize();
        offMRGCmosaic.visualize();

        % Visualize cone mosaic tesselation
        %onMRGCmosaic.visualizeConeMosaicTesselation(...
        %            coneRFpositions, coneRFspacings, ...
        %            rgcRFpositions, rgcRFspacings);
    end

end