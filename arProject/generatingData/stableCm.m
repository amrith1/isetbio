%% Function for Creating a Mosaic to Use on All the Training and Test Sets

function [cm] = stableCm(varargin)
    
    p = inputParser;
    p.addParameter('cmPos',[-10,0],@(x)(isnumeric(x) && (numel(x) == 2)));
    p.addParameter('cmDim',[1.7,1.7],@(x)(isnumeric(x) && (numel(x) == 2)));
    p.addParameter('integrationTime',10/1000,@isscalar);
    p.addParameter('wantSave',false,@islogical);
    p.addParameter('wantView',false,@islogical);
    p.parse(varargin{:});
    
    cmPos = p.Results.cmPos;
    cmDim = p.Results.cmDim;
    int_time = p.Results.integrationTime;
    
    
    ieInit;
    cm = cMosaic('sizeDegs',[cmDim(1), cmDim(2)],'eccentricityDegs',[cmPos(1), cmPos(2)]);
    cm.integrationTime = int_time;
    
    if p.Results.wantView == true
    
        cm.visualize();
    
    end
    

end
