classdef mRGCmosaic < handle
% Create a midget RGC mosaic connected to a cone mosaic

    properties (Constant)
        LCONE_ID = 2;
        MCONE_ID = 3;
        SCONE_ID = 4;
    end
    
    % Public properties
    properties
        % 'noiseFlag'     - String. Default 'random'. Add Gaussian noise
        %                 (default) or not. Valid values are {'random', 'frozen', 'none'}.
        noiseFlag = 'random';
    end
    
    % Read-only properties
    properties (GetAccess=public, SetAccess=private)
        
        % The eccentricity of the mosaic, in degrees
        eccentricityDegs;
        
        % The size of the mosaic, in degrees
        sizeDegs;
        
        % Eye, left or right
        whichEye;
        
        % The input cone mosaic
        inputConeMosaic;
        
        % Sparse matrix [nCones x mRGC] storing the exclusive connections
        % between the n-th cone to m-th RGC center subregion 
        % (1==connected, 0==disconencted)
        coneConnectivityMatrix;
        
        % Struct containing sparse matrices with weights of cone connections
        % to the RGC center & surround subregions
        coneWeights;
        
        % [m x 2] matrix of RGC positions, in microns
        rgcRFpositionsMicrons;
        
        % [m x 2] matrix of RGC positions, in degrees
        rgcRFpositionsDegs;
    end
    
    % Private properties
    properties (GetAccess=private, SetAccess=private)
        % The metadata of the input cone mosaic (used for connecting cones 
        % to the subregions of the mRGC cell receptive fields.
        inputConeMosaicMetaData;
        
        % Size (in degs) of source lattice from which to crop positions for
        % the desired eccentricity
        sourceLatticeSizeDegs = 45;
        
        % [m x 1] matrix of local spacing for each RGC, in microns
        rgcRFspacingsMicrons;
        
        % [m x 1] matrix of local spacing for each RGC, in degs
        rgcRFspacingsDegs;
        
        % Synthesized RGC RF params
        synthesizedRFparams;
    end
    
    % Public methods
    methods
        % Constructor
        function obj = mRGCmosaic(eccentricityDegs, sizeDegs, whichEye, varargin)
            % Set properties
            obj.eccentricityDegs = eccentricityDegs;
            obj.sizeDegs = sizeDegs;
            obj.whichEye = whichEye;
            
            fprintf('Generating input cone mosaic. Please wait ...\n');
                
            % Import cone and mRGC RF positions by cropping large
            % eccentricity-varying cone and mRGC lattices
            [coneRFpositionsMicrons, ...
             coneRFpositionsDegs, ...
             rgcRFpositionsMicrons, ...
             rgcRFpositionsDegs, ...
             extraDegsForRGCSurround] =  mRGCmosaic.importConeAndRGCpositions(...
                        obj.sourceLatticeSizeDegs, ...
                        eccentricityDegs, ...
                        sizeDegs, ...
                        whichEye);

            % Generate a regular hex mosaic to serve as the
            % input cone mosaic with a custom mean cone spacing 
            % (equal to the median spacing within the imported
            % coneRFpositionsMicrons) and custom optical density and
            % macular pigment appropriate for the eccentricityDegs
            generationMode = 'equivalent regular hex';
            [obj.inputConeMosaic, ...
             obj.inputConeMosaicMetaData] = mRGCmosaic.generateInputConeMosaic(...
                        generationMode, ...
                        eccentricityDegs, ...
                        sizeDegs, ...
                        extraDegsForRGCSurround, ...
                        coneRFpositionsMicrons, ...
                        varargin{:});

            % Plot the imported positions
            plotInputPositions = true;
            if (plotInputPositions)
                coneRFpositionsDegsInRegHexMosaic = RGCmodels.Watson.convert.rhoMMsToDegs(obj.inputConeMosaicMetaData.conePositionsMicrons*1e-3);
                mRGCmosaic.visualizeInputPositions(coneRFpositionsDegs, rgcRFpositionsDegs, coneRFpositionsDegsInRegHexMosaic);
            end
            
            % Wire cones to RGC center subregions with a cone specificity level
            coneSpecificityLevel = 100;
            
            % Wire cones to RGC centers, computing the cone-to-RGC-center
            % connectivity matrix, and the resulting RGC RF positions and
            % spacings
            [obj.coneConnectivityMatrix, ...
             obj.rgcRFpositionsDegs, obj.rgcRFpositionsMicrons, ...
             obj.rgcRFspacingsDegs, obj.rgcRFspacingsMicrons] = mRGCmosaic.wireInputConeMosaicToRGCcenters(...
                rgcRFpositionsDegs, rgcRFpositionsMicrons,  ...
                obj.inputConeMosaicMetaData.conePositionsDegs, ...
                obj.inputConeMosaicMetaData.conePositionsMicrons, ...
                obj.inputConeMosaicMetaData.coneSpacingsMicrons, ...
                obj.inputConeMosaicMetaData.coneTypes, ...
                obj.inputConeMosaicMetaData.indicesOfConesNotConnectingToRGCcenters, ...
                coneSpecificityLevel);
            
            % Compute weights of connections between cones and RGC
            % center/surround subregions, and update tge RGC RF positions
            % based on the connectivity
            [obj.coneWeights, obj.rgcRFpositionsDegs, obj.synthesizedRFparams] = mRGCmosaic.computeConeWeights(...
                obj.inputConeMosaicMetaData.conePositionsDegs, ...
                obj.inputConeMosaicMetaData.coneTypes, ...
                obj.coneConnectivityMatrix);
            
            % Update RGCRF positions and spacings
            obj.rgcRFpositionsMicrons = 1e3*RGCmodels.Watson.convert.rhoDegsToMMs(obj.rgcRFpositionsDegs);
            obj.rgcRFspacingsDegs = RGCmodels.Watson.convert.positionsToSpacings(obj.rgcRFpositionsDegs);
            obj.rgcRFspacingsMicrons = RGCmodels.Watson.convert.positionsToSpacings(obj.rgcRFpositionsMicrons);
        end
        
        % Method to compute the response of the RGC mosaic for the passed cone mosaic response
        [mRGCresponses, temporalSupportSeconds] = compute(obj, coneMosaicResponses, timeAxis, varargin);
        
        % Method to visualize the tesselation of the input cone mosaic by
        % the RF centers of the RGC mosaic
        visualizeConeMosaicTesselation(obj, domain);
        
        % Method to visualize the synthesized RF params, retinal and visual
        visualizeSynthesizedParams(obj);
        
        % Method to visualize the cone weights to each RGC
        visualizeConeWeights(obj);
    end
    
    % Static methods
    methods (Static)
        % Static method to import cone and mRGC positions from pre-computed
        % lattices that have the desired size and are centered at the desired eccentricity in the desired eye
        [coneRFpositionsMicrons, coneRFpositionsDegs, ...
         rgcRFpositionsMicrons,  rgcRFpositionsDegs, extraDegsForRGCSurround] = ...
            importConeAndRGCpositions(sourceLatticeSizeDegs, eccentricityDegs, sizeDegs, whichEye);
        
        % Static method to generate a cone mosaic from the imported cone positions
        [theConeMosaic, theConeMosaicMetaData] = ...
            generateInputConeMosaic(generationMode, eccentricityDegs, sizeDegs, ...
            extraDegsForRGCSurround, coneRFpositionsMicrons, varargin); 
        
        % Static method to wire cones to the RGC RF centers
        [connectivityMatrix, rgcRFpositionsDegs, rgcRFpositionsMicrons, rgcRFspacingsDegs, rgcRFspacingsMicrons] = ...
            wireInputConeMosaicToRGCcenters(rgcRFpositionsDegs, rgcRFpositionsMicrons, ...
            conePositionsDegs, conePositionsMicrons, coneSpacingsMicrons, coneTypes, ...
            indicesOfConesNotConnectingToRGCcenters, coneSpecificityLevel);
        
        % Static method to compute weights of connections b/n cones and
        % center-surround RF subregions. Also update RGC RF positions
        [coneWeights, rgcPositionsDegsFromConnectivity, synthesizedRFparams] = computeConeWeights(conePositionsDegs, ...
            coneTypes, connectivityMatrix, eccentricityDegs, sizeDegs);
    
        % Static method to visualize the input cone and RGC positions
        visualizeInputPositions(coneRFpositionsDegs, rgcRFpositionsDegs, coneRFpositionsDegsInRegHexMosaic)
    end
end

