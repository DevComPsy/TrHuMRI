function [chosen, rt] = presentCue(b, g, t, term_cond, mode, cols, chosen, rt, currOutcome)

global user params 
global window
% Screen('Flip', window);

Screen('FillRect', window, params.map.bg_col);

KbReleaseWait; % In PTB, handle key release

% Prepare visual elements
prepOutcome(currOutcome);
prepTermCond(term_cond);
prepMap();
prepFixCross();

% Prepare cues
logstring = ['Trial: ' int2str(b) '_' int2str(g) '_' int2str(t)];

disp(logstring);
user.grid.log{b,g,t} = prepCue(user.conditions.block(b).game(g).n_cues(t,:), params.colSp.cueCols);

% Prepare response buttons
prepButton(mode, cols, b, g, chosen);

t_tmp = Screen('Flip', window );
user.cue_pres(end+1) = t_tmp;

logstring = [num2str(t_tmp) '; cues'];
disp(logstring);

% Wait for the nulltime before nullifying the trigger
% WaitSecs(params.trigger.nulltime);
tic;
% Duration to present stimuli (subtracting nulltime)
dur = params.task.trial.dur_stimulus * 0.2;

% Handle response
% % Wait for Key Press or Choice Duration
KbQueueCreate;
KbQueueStart;
toflip = 1;

% 
% while toc < dur 
%     %while under Choice Duration limit
% 
%     [pressed, firstPress]=KbQueueCheck;% check if trigger was pressed
%     % KbQueueFlush
%     if pressed
%         if firstPress(params.general.keys.l) ~=0 || firstPress(params.general.keys.r) ~=0 || firstPress(params.general.keys.escape) ~=0
%             if firstPress(params.general.keys.l) ~=0
%                 chosen = 2;
%                 user.response(end+1) = firstPress(params.general.keys.l);
%                 break
%             elseif firstPress(params.general.keys.r) ~=0
%                 chosen = 1;               
%                 user.response(end+1) = firstPress(params.general.keys.r);
% 
%                break
%            % elseif firstPress(params.general.keys.trigger) ~=0
% 
%             elseif firstPress(params.general.keys.escape) ~=0
%                 save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '_log.mat']);
% 
%                 KbQueueRelease();
%                 sca;
%                 return
%             end
%         end
%     end

% KbQueueCreate;
% KbQueueStart;
% toflip = 1;

while toc < dur
    % While under Choice Duration limit

    [pressed, firstPress] = KbQueueCheck; % check if trigger was pressed

    if pressed && chosen == 0    
    
        if firstPress(params.general.keys.l) ~= 0 || firstPress(params.general.keys.r) ~= 0 || firstPress(params.general.keys.escape) ~= 0
            if firstPress(params.general.keys.l) ~= 0
                chosen = 2;
                user.response(end + 1) = firstPress(params.general.keys.l);
                break; % Stop the loop after first key press
            elseif firstPress(params.general.keys.r) ~= 0
                chosen = 1;
                user.response(end + 1) = firstPress(params.general.keys.r);
                break; % Stop the loop after first key press
            elseif firstPress(params.general.keys.escape) ~= 0
                save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '_block_' int2str(b) '_log.mat']);
                
                KbQueueRelease(); % Release the queue resources
                sca; % Close screen
                return; % Exit the function or script
            end
        end
    end
end

KbQueueStop; % Stop Queue
KbQueueRelease; % Release the queue resources



    % if toc > dur & toflip==1 %do it everytime that toc is higher than dur and smaller than jitt + dur
    %     Screen('FillRect', window , params.map.bg_col);
    % 
    %     prepOutcome(currOutcome);
    %     prepTermCond(term_cond);
    %     prepMap();
    %     prepButton(mode, cols, b, g, chosen);
    %     prepFixCross();
    %     t_tmp_resp = Screen('Flip', window); % Present updated screen
    %     toflip = 0;
    %     user.fixation1(end+1) = t_tmp_resp;
    % 
    % end


%% Response evaluation
if firstPress(params.general.keys.r) ~=0 ||  firstPress(params.general.keys.l) ~=0

    % Redraw screen with updated state
    Screen('FillRect', window , params.map.bg_col);
    prepOutcome(currOutcome);
    prepTermCond(term_cond);
    prepMap();
    prepCue(user.conditions.block(b).game(g).n_cues(t,:), params.colSp.cueCols, user.grid.log{b,g,t});
    prepButton(mode, cols, b, g, chosen);
    prepFixCross();
    t_tmp_resp = Screen('Flip', window); % Present updated screen
    % Wait until end of stimulus duration

     timetowait = dur - toc;
     if timetowait >0
         WaitSecs(timetowait);
     end

end

%% Reaction time calculation
if isnan(rt)
    if chosen == 0 || chosen == 999
        rt = nan;
    else
        rt = t_tmp_resp - t_tmp;
    end
end

WaitSecs(params.trigger.nulltime); % Wait for the nulltime
end 