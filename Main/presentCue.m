function [chosen, rt] = presentCue(b, g, t, term_cond, mode, cols, chosen, rt, currOutcome)

global user params lastTriggerPressed current_volume
global window
% Screen('Flip', window);

% Read keypresses
getvolume();

% Clear screen by filling it with black
Screen('FillRect', window, params.map.bg_col);


% Prepare visual elements
prepOutcome(currOutcome);
prepTermCond(term_cond);
prepMap();
prepFixCross();

getvolume();


% Prepare cues
logstring = ['Trial: ' int2str(b) '_' int2str(g) '_' int2str(t)];

disp(logstring);
user.grid.log{b,g,t} = prepCue(user.conditions.block(b).game(g).n_cues(t,:), params.colSp.cueCols);

% Prepare response buttons
prepButton(mode, cols, b, g, chosen);
getvolume();


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
while toc  < (dur + params.task.jitters(params.j))
    %while under Choice Duration limit

    [pressed, firstPress]=KbQueueCheck;% check if trigger was pressed
    % KbQueueFlush
    if pressed
            if firstPress(params.general.keys.l) ~=0
                chosen = 2;
                user.response(end+1) = firstPress(params.general.keys.l);
                % user.fixation1(end+1) = firstPress(params.general.keys.l);

                break
            elseif firstPress(params.general.keys.r) ~=0
                chosen = 1;               
                user.response(end+1) = firstPress(params.general.keys.r);
                % user.fixation1(end+1) = firstPress(params.general.keys.l);
                break
            elseif firstPress(params.general.keys.trigger) ~=0

                current_volume = current_volume +1;
                time = firstPress(params.general.keys.trigger); %take last trigger
                user.triggerno(end+1) = current_volume;
                user.triggertime(end+1) = time;
                lastTriggerPressed = time;

            elseif firstPress(params.general.keys.escape) ~=0
                save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '_log.mat']);

                KbQueueRelease();
                sca;
                return
            
        end
    end
    if toc > dur & toflip==1 %do it everytime that toc is higher than dur and smaller than jitt + dur
        Screen('FillRect', window , params.map.bg_col);
        getvolume();

        prepOutcome(currOutcome);
        prepTermCond(term_cond);
        prepMap();
        prepButton(mode, cols, b, g, chosen);
        prepFixCross();
        t_tmp_resp = Screen('Flip', window); % Present updated screen
        toflip = 0;
        user.fixation1(end+1) = t_tmp_resp;
        getvolume();


    end
end

% If a key press occurred
getvolume();


%% Response evaluation
if firstPress(params.general.keys.r) ~=0 ||  firstPress(params.general.keys.l) ~=0

    getvolume();
    % Redraw screen with updated state
    Screen('FillRect', window , params.map.bg_col);
    prepOutcome(currOutcome);
    prepTermCond(term_cond);
    % prepMap();
    % prepCue(user.conditions.block(b).game(g).n_cues(t,:), params.colSp.cueCols, user.grid.log{b,g,t});
    prepButton(mode, cols, b, g, chosen);
    getvolume();

    prepFixCross();
    t_tmp_resp = Screen('Flip', window); % Present updated screen
    getvolume();
    if firstPress(params.general.keys.r) ==0
        user.fixation1(end+1) = firstPress(params.general.keys.l);
    elseif firstPress(params.general.keys.l) ==0
         user.fixation1(end+1) = firstPress(params.general.keys.r);
    end
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
        user.response(end+1) = nan;
    else
        rt = t_tmp_resp - t_tmp;
    end
end
getvolume();


