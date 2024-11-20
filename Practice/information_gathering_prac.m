clear all; close all; clc
%% Basic PTB setup

cd;
addpath(genpath('C:\Users\aleya\OneDrive\Desktop\PTB_practice - Copy'))
[userID pract] = getPractDlg();
%% initialize experiment
global params user window 
% Initialize keyboard input
[params.general.keys.escape, params.general.keys.l ,params.general.keys.r , params.general.keys.confirm] = setupKeys2();

% global  xCenter yCenter windowRect black white  outcomecolor ...
%     leftRect rightRect ;  %aleya: make these global parameters
Screen('Preference', 'SkipSyncTests', 1); %for debugging
debug = false; %to enable small screen for debugging

screenNumber = max(Screen('Screens'));
if debug ==true
    % Open a smaller window for debugging (e.g., 800x600)
    windowRect = [0 0 800 600];  % Smaller window size
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [213 213 213], windowRect, 32, 1);
else
    % Open fullscreen window for regular task execution
    screenID = max(Screen('Screens')); % Get the screen ID of the display
    oldResolution = Screen('Resolution', screenID, 1024, 768); % Set resolution to a lower value (1024x768)
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [213 213 213], [], 32, 1);
end

% Get the size of the window

% Get the center coordinate of the window
[params.screen.xCenter, params.screen.yCenter] = RectCenter(windowRect);

debug = 0;
TreasHunt_pract_initialize(userID,debug,pract);
TreasHunt_user_initialize(userID,debug);
mkdir(params.general.res_dir);
TreasHunt_games_initialize_noFixThresh_noGoodSp()

params.task.jitters = CreateJitter(2,sum(user.conditions.block(1).termination),[1,4]);
params.task.jitters_byblock = CreateJitter(2,params.task.exp.n_games ,[1,4]);



%% check whether logfiles from this subject already exist
if exist([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.mat'],'file') > 0
    error('logfile of this subject already exists! Did you enter the wrong subject number?')
end

%% logfile
diary([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '_pract' int2str(pract) '.dry'])
%config_log([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.log']) %Aleya: might be a cogent function


%% general PTB settings

% Set the text font and size
Screen('TextFont', window, params.general.text.font);
Screen('TextSize', window, params.general.text.font_size);

%global current_volume triggerKey lastTriggerPressed

%DrawFormattedText(window, 'Please wait for scanner', 'center', 'center', params.general.display.text_col );
t_tmp = Screen('Flip', window);

user.tstartlog = t_tmp;

%[current_volume, lastTriggerPressed] = waitForVolumes(params.trigger.tr_dummies); % Wait 6 vols before starting


% KbQueue setup for checking keys
KbQueueCreate();

% Start the queue
KbQueueStart();

%% run experiment
% general instruction
PsychDefaultSetup(2);

Screen('FillRect', window,params.map.bg_col);
vbl = Screen('Flip', window);
tstart = vbl;

l = 1;  % logbook-line
currOutcome = median([1 params.outcome.n_steps]); % initialize outcome-bar

for b = 1:params.task.exp.n_blocks

disp([int2str(b) 'Block: ']);
Screen('FillRect', window,params.map.bg_col);
% Concatenate the string for the block message
blockText = 'Starting Practice';
DrawFormattedText(window, blockText, 'center', 'center', params.general.display.text_col );
t_tmp = Screen('Flip', window);

params.time.blockInstruction = t_tmp;
disp([num2str(t_tmp) '; block instruction']);

%to make the horizons the same as in the MRI task
user.conditions.block(b).termination(user.conditions.block(b).termination >= 10)...
    = user.conditions.block(b).termination(user.conditions.block(b).termination >= 10) - 2;

% loop through games
for g = 1:params.task.exp.n_games

    Screen('FillRect', window,params.map.bg_col);

    prepFixCross();
    prepOutcome(currOutcome);
    trial_beg = Screen('Flip', window);



    % initialize grid
    prepGrid()

    % display game instruction (buffer 1)
    [mode,cols,term_cond,triggerInstr] = prepGameInstr(b,g); 
    prepOutcome(currOutcome);

    game_ins = Screen('Flip', window);
    WaitSecs(2);

    % loop through trials until subject responds
    terminated = 0;
    t = 1;
    chosen = 0;                  % whether color was chosen
    rt = nan;
    params.j = 1;
 

    while terminated == 0
        % present fixation or cues
        [chosen, rt] = presentCue(b,g,t,term_cond,mode,cols,chosen,rt,currOutcome);
        % last trial in game?
        if user.conditions.block(b).termination(g) == t 
            terminated = 1;
            % present termination screen
            presentTerm(b,g,term_cond,mode,cols,chosen,currOutcome)
        end



        %% outcome
        if terminated

            Screen('FillRect', window,params.map.bg_col);
            prepFixCross();
            prepOutcome(currOutcome);
            %t_tmp = Screen('Flip', window, params.map.bg_col);
            t_tmp = Screen('Flip', window);
            user.fixation_outcome(end+1) = t_tmp;

           
            % determine outcome (whether right object was chosen)
            if chosen ~= 0 && chosen ~= 999 && ~isnan(chosen)
                if cols(chosen,:) == params.colSp.cueCols(1,:)
                    col_c = 1;
                elseif cols(chosen,:) == params.colSp.cueCols(2,:)
                    col_c = 2;
                end
                if col_c == user.conditions.block(b).game(g).corr_col
                    corr = 1;
                else
                    corr = 0;
                end
            end
            if chosen == 0 || chosen == 999 || isnan(chosen)
                deltaOutcome = params.outcome.outcomeSteps(2);
            elseif corr == 1
                deltaOutcome = params.outcome.outcomeSteps(3);
            else
                deltaOutcome = params.outcome.outcomeSteps(1);
            end

            % present outcome
            [currOutcome,winloss] = presentOutcome2(currOutcome,deltaOutcome);
            WaitSecs(2); %show outcome for 2s longer
        end
      
        %% log data
        %             if terminated || strcmp(CueFix,'fix')
        user.log(l,:) = nan(1,length(user.log_descr));
        user.log(l,1:3) = [b,g,t];
        user.log(l,5)   = user.conditions.block(b).termination(g);
        user.log(l,6) = user.conditions.block(b).term_cond(g);
        %                 user.log(l,7)   = user.conditions.block(b).GoodsAction(g);
        % color on right (?) side
        if cols(1,:) == params.colSp.cueCols(1,:)
            col_r = 1; % gold
        elseif cols(1,:) == params.colSp.cueCols(2,:)
            col_r = 2; %bronze
            %                 elseif cols(1,:) == params.resp.uniman.col
            %                     col_r = 3; %uniman
        else
            error('unknown color');
        end
        user.log(l,7)   = col_r;

        if chosen > 0

            user.log(l,8)   = chosen;
            if chosen == 999
                col_c = nan;
            elseif cols(chosen,:) == params.colSp.cueCols(1,:)
                col_c = 1;
            elseif cols(chosen,:) == params.colSp.cueCols(2,:)
                col_c = 2;
            else
                error('unknown color');
            end
            user.log(l,11)  = col_c;
            if isnan(user.log(l-user.log(l,3)+1:l,12))
                user.log(l,12)  = rt;
            end
        end
        user.log(l,13)  = sum( user.conditions.block(b).game(g).n_cues(1:t,1));     % total ev yellow
        user.log(l,14)  = sum( user.conditions.block(b).game(g).n_cues(1:t,2));     % total ev blue
        user.log(l,15)  = user.conditions.block(b).game(g).n_cues(t,1);             % current ev yellow
        user.log(l,16)  = user.conditions.block(b).game(g).n_cues(t,2);             % current ev blue
        user.log(l,17)  = trial_beg;
        user.log(l,18)  = game_ins;
        % when miss trial: set next trial as slider trial
        if terminated && user.conditions.block(b).slider_term(g) && (chosen == 0 || chosen == 999)
            if g < params.task.exp.n_games
                user.conditions.block(b).slider_term(g+1) = 1;
            elseif b < params.task.exp.n_blocks
                user.conditions.block(b+1).slider_term(1) = 1;
            end
        end
        if terminated && user.conditions.block(b).slider_resp(g) && (chosen == 0 || chosen == 999)
            if g < params.task.exp.n_games
                user.conditions.block(b).slider_resp(g+1) = 1;
            elseif b < params.task.exp.n_blocks
                user.conditions.block(b+1).slider_resp(1) = 1;
            end
        end

        if terminated   % outcome of game after termination
            user.log(l,4) = deltaOutcome; % change in outcome
            user.log(l,9) = currOutcome;
            user.log(l,10) = winloss;
            if ~isnan(winloss)  % reset currOutcome after reward/punishment
                currOutcome = median([1 params.outcome.n_steps]);
            end
        end
        % next trial / line in logfile
        t = t+1;
        l = l+1;
    end
end

%% end of experiment

Screen('FillRect', window, params.general.display.bg_col);
DrawFormattedText(window, 'Finished!', 'center', 'center', [0  0  0 ]);
t_tmp = Screen('Flip', window);

% Wait for a key press or timeout after 2 seconds
[secs, keyCode] = KbWait([], 2, GetSecs() + 2);


end 
%% save data
save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '_pract' int2str(pract) '.mat'])
save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '_pract' int2str(pract) '_log.mat'],'user','params')
diary off

clear all; close all; clc
sca;