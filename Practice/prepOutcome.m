% function [prevPos,barPos] = prepOutcome(prevOutcome)
% 
% prepares the outcome bar and the current outcome, but not the new
% outcome.
%
% @prevOutcome: number of points at the moment
% @prevPos: position of current/prev outcome as location on the screen
% (x-coordinate)
% @barPos: array with possible location of the bar on the screen
% (x-coordinates)
%
% Tobias Hauser, 01.15
%
function [prevPos,barPos] = prepOutcome(prevOutcome)

global params
global window


%% calculate relative position of outcomes
barPos = linspace(params.outcome.posXY(1),params.outcome.maxX,params.outcome.n_steps);  
if prevOutcome > length(barPos)
    prevOutcome = length(barPos);
end
prevPos = barPos(prevOutcome);

% %% previous outcome
% cgrect(mean([params.outcome.posXY(1),prevPos]),params.outcome.posXY(2),...
%     prevPos - params.outcome.posXY(1),params.outcome.barSizeY,params.outcome.barCol)
% 
% %% draw win zone
% cgrect(params.outcome.winBorderX,params.outcome.posXY(2),...
%     params.outcome.winBorderSize(1),params.outcome.winBorderSize(2),params.outcome.winBorderCol)
% %% draw loss zone
%cgrect(params.outcome.lossBorderX,params.outcome.posXY(2),...
%     params.outcome.lossBorderSize(1),params.outcome.lossBorderSize(2),params.outcome.lossBoderCol)


% previous outcome
prevRect = [mean([params.outcome.posXY(1), prevPos]) - (prevPos - params.outcome.posXY(1)) / 2, ...
            params.outcome.posXY(2) - params.outcome.barSizeY / 2, ...
            mean([params.outcome.posXY(1), prevPos]) + (prevPos - params.outcome.posXY(1)) / 2, ...
            params.outcome.posXY(2) + params.outcome.barSizeY / 2];

Screen('FillRect', window, params.outcome.barCol, prevRect);

% draw win zone
winRect = [params.outcome.winBorderX - params.outcome.winBorderSize(1) / 2, ...
           params.outcome.posXY(2) - params.outcome.winBorderSize(2) / 2, ...
           params.outcome.winBorderX + params.outcome.winBorderSize(1) / 2, ...
           params.outcome.posXY(2) + params.outcome.winBorderSize(2) / 2];
Screen('FillRect', window, params.outcome.winBorderCol, winRect);

% %% draw loss zone
lossRect =  [params.outcome.lossBorderX - params.outcome.lossBorderSize(1) / 2, ...
           params.outcome.posXY(2) - params.outcome.lossBorderSize(2) / 2, ...
           params.outcome.lossBorderX + params.outcome.lossBorderSize(1) / 2, ...
           params.outcome.posXY(2) + params.outcome.lossBorderSize(2) / 2];

Screen('FillRect', window, params.outcome.lossBorderCol, lossRect);

end