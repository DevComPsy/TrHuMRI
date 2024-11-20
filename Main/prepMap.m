% function prepMap()
%
% TreasureHunt function
% prepares the map to be drawn for the trials
%
% TH, 09.14
%
function prepMap()

global params
global window


% Draw map border
borderRect = [params.map.posXY(1) - (params.map.sizeXY(1) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(2) - (params.map.sizeXY(2) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(1) + (params.map.sizeXY(1) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(2) + (params.map.sizeXY(2) + params.map.borderSize / 2) / 2];
Screen('FillRect', window,params.map.col , borderRect);

% Draw map
mapRect = [params.map.posXY(1) - params.map.sizeXY(1) / 2, ...
           params.map.posXY(2) - params.map.sizeXY(2) / 2, ...
           params.map.posXY(1) + params.map.sizeXY(1) / 2, ...
           params.map.posXY(2) + params.map.sizeXY(2) / 2];
Screen('FillRect', window, params.map.bg_col , mapRect);


end