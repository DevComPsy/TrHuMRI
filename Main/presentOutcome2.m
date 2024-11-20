function [currOutcome,winloss] = presentOutcome2(prevOutcome,deltaOutcome)

global params user lastTriggerPressed window

 getvolume();


% clearpict(4)
Screen('FillRect', window, params.map.bg_col); 
prepFixCross();

%% draw current and previous positions
[prevPos,barPos] = prepOutcome(prevOutcome);

currOutcome = prevOutcome + deltaOutcome;
if currOutcome > length(barPos)
    currOutcome = length(barPos);
end
currPos = barPos(currOutcome);

% determine whether currOutcome crossed one of the borders
if currPos > (params.outcome.winBorderX - params.outcome.winBorderSize(1)/2)
    winloss = 1;
elseif currPos < (params.outcome.lossBorderX - params.outcome.lossBorderSize(1)/2)
    winloss = -1;
else
    winloss = nan;
end

getvolume();

% new outcome
if currPos > prevPos
    % cgrect(mean([currPos,prevPos]),params.outcome.posXY(2),...
    % currPos - prevPos,params.outcome.barSizeY,params.outcome.winCol)
    newRect = [mean([currPos, prevPos]) - (currPos - prevPos) / 2, ...
               params.outcome.posXY(2) - params.outcome.barSizeY / 2, ...
               mean([currPos, prevPos]) + (currPos - prevPos) / 2, ...
               params.outcome.posXY(2) + params.outcome.barSizeY / 2];
    Screen('FillRect', window, params.outcome.winCol, newRect);
elseif currPos < prevPos
    % cgrect(mean([currPos,prevPos]),params.outcome.posXY(2),...
    % prevPos - currPos,params.outcome.barSizeY,params.outcome.lossCol)
    newRect = [mean([currPos, prevPos]) - (prevPos - currPos) / 2, ...
               params.outcome.posXY(2) - params.outcome.barSizeY / 2, ...
               mean([currPos, prevPos]) + (prevPos - currPos) / 2, ...
               params.outcome.posXY(2) + params.outcome.barSizeY / 2];
    Screen('FillRect', window, params.outcome.lossCol, newRect);
else
    warning('no change in outcome - this is unusual!')
end


%% present all together

%t_tmp = drawpict(4);
t_tmp = Screen('Flip', window);
user.outcome(end+1) = t_tmp;
logstring = [num2str(t_tmp) '; outcome '];
%save time here
disp([logstring '; outcomee ']);

tic
while toc < params.outcome.duration
    getvolume();

end