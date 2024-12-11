function information_gathering(subjectID,block)
% subjectID = 999;
% block = 1;
% clearvars -except subjectID block
% sca
% close all
userID = subjectID;

%% Basic PTB setup

cd;
%addpath '    C:\Users\Kenza Kedri\Documents\GitHub\Information_gathering\PTB_task\Task_function'
addpath 'F:\TreasureHunt';
addpath 'F:\TreasureHunt\Task_function';
addpath(genpath('C:\home\AG_Hauser\TreasureHunt'));
addpath(fullfile('C:\home\AG_Hauser\TreasureHunt\Task_function')) %kk:to check
%% initialize experiment
global params user window lastTriggerPressed
% Initialize keyboard input
[params.general.keys.escape, params.general.keys.l ,params.general.keys.r , params.general.keys.trigger, params.general.keys.confirm] = setupKeys2();

% global  xCenter yCenter windowRect black white  outcomecolor ...
%     leftRect rightRect ;  %aleya: make these global parameters
Screen('Preference', 'SkipSyncTests', 1); %for debugging
debug = false; %to enable small screen for debugging

if block == 2
    params.general.res_dir              = [pwd '\logs\'];
    params.general.rest_dir_participant = [params.general.res_dir,num2str(userID) '\'] ;
    userfile = dir([params.general.rest_dir_participant ,'*block_1*']);
    disp(['found ' num2str(length(userfile)) ' files, taking the last one'])
            lastFile = userfile(end);  % get the last file in the list
        load([lastFile.folder '\' lastFile.name] ,'user' ,'params');
end
if block == 3
    params.general.res_dir              = [pwd '\logs\'];
    params.general.rest_dir_participant = [params.general.res_dir,num2str(userID) '\'] ;
    userfile = dir([params.general.rest_dir_participant ,'*block_2*']);
    disp(['found ' num2str(length(userfile)) ' files, taking the last one'])
            lastFile = userfile(end);  % get the last file in the list
        load([lastFile.folder '\' lastFile.name] ,'user' ,'params');
end



screenNumber = max(Screen('Screens'));
if debug ==true
    % Open a smaller window for debugging (e.g., 800x600)
    windowRect = [0 0 800 600];  % Smaller window size
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [213 213 213], windowRect, 32, 1);
else
    % Open fullscreen window for regular task execution
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [213 213 213], [], 32, 1);
end

% Get the size of the window

% Get the center coordinate of the window
[params.screen.xCenter, params.screen.yCenter] = RectCenter(windowRect);

if block == 1

    TreasHunt_initialize(userID,debug);
    TreasHunt_user_initialize(userID,debug);
    mkdir(params.general.res_dir);
    TreasHunt_games_initialize_noFixThresh_noGoodSp()

     mkdir(params.general.rest_dir_participant)
end

%Here the jitter can be reduced
params.task.jitters = CreateJitter(2,1440,[1,3]);
params.task.jitters_byblock = CreateJitter(2,1440,[2,4]);
params.task.jitter_outocme = CreateJitter(4,1440,[2,6]);

user.conditions.block(block).termination(user.conditions.block(block).termination >= 10) = user.conditions.block(block).termination(user.conditions.block(block).termination >= 10) - 2;

%% check whether logfiles from this subject already exist
if exist([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.mat'],'file') > 0
    error('logfile of this subject already exists! Did you enter the wrong subject number?')
end

%% logfile
diary([params.general.res_dir int2str(user.date) '_' int2str(user.ID) 'block_' int2str(block) '.dry'])
%config_log([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.log']) %Aleya: might be a cogent function


%% general PTB settings
% Set the text font and size
Screen('TextFont', window, params.general.text.font);
Screen('TextSize', window, params.general.text.font_size);

global current_volume triggerKey lastTriggerPressed

DrawFormattedText(window, 'Please wait for scanner', 'center', 'center', params.general.display.text_col );
t_tmp = Screen('Flip', window);

triggerKey = params.general.keys.trigger;
current_volume = 0; %Recorded the first trigger
KbQueueRelease()

user.tstartlog(end+1)= t_tmp; %start before dummy

[current_volume, lastTriggerPressed] = waitForVolumes(params.trigger.tr_dummies); % Wait 6 vols before starting
% KbQueue setup for checking keys
KbQueueCreate();
% Start the queue
KbQueueStart();

%% run experiment
% general instruction
PsychDefaultSetup(2);

Screen('FillRect', window,params.map.bg_col);
vbl = Screen('Flip', window);
user.exp_begin(end+1) = vbl; %start of experiment

if block ==1
    %have to save it for next block
    currOutcome = median([1 params.outcome.n_steps]); % initialize outcome-bar

else
    try
        % Attempt to log the current outcome
        lastValidIdx = find(~isnan(user.log(:, 9)), 1, 'last');
        currOutcome = user.log(lastValidIdx, 9);    catch
        % If the log attempt fails, initialize outcome-bar using the median
        currOutcome = median([1, params.outcome.n_steps]);
    end
end

b = block;
getvolume();

if b ==1
    l = 1;  % logbook-line
else
    l = length(user.log) +1;

end

% log & trigger
disp([int2str(b) 'Block: ']);
getvolume();

% block instruction
Screen('FillRect', window,params.map.bg_col);
% Concatenate the string for the block message
blockText = ['Block ' int2str(b) ' of ' int2str(params.task.exp.n_blocks)];
DrawFormattedText(window, blockText, 'center', 'center', params.general.display.text_col );
t_tmp = Screen('Flip', window);



%logstring([ num2str(t_tmp) '; block instruction']);
user.blockInstruction(end+1) = t_tmp;
disp([num2str(t_tmp) '; block instruction']);
tic
while toc < 2
    getvolume()

end

% loop through games
for g = 1:params.task.exp.n_games
    % pre-game fixation, log stuff & send triggers
    getvolume();

    logstring=['Game: ' int2str(b) '_' int2str(g)];
    logstring=['Trigger: ' int2str(current_volume) '_' int2str(lastTriggerPressed)];

    params.currentgamenumber = logstring;
    disp(logstring);
    Screen('FillRect', window,params.map.bg_col);

    getvolume();
    prepFixCross();
    prepOutcome(currOutcome);
    trial_beg = Screen('Flip', window);

    % initialize grid
    prepGrid()
    getvolume();


    % display game instruction (buffer 1)
    [mode,cols,term_cond, triggerInstr] = prepGameInstr(b,g); %aleya: a black rectangle in the upper left corner is displayed here for some reason
    prepOutcome(currOutcome);

    game_ins = Screen('Flip', window);
    logstring=[num2str(game_ins) '; gameInstr '];


    %%kk we do not need this ?
    % params.time.instruction(end+1) = t_tmp;
    disp(logstring);

    %wait 1 sec for screen to display (show the outcome 1sec)
    tic
    while toc < params.trigger.nulltime/10
        getvolume()
    end

    % loop through trials until subject responds
    terminated = 0;
    t = 1;
    chosen = 0;                  % whether color was chosen
    rt = nan;
    params.j = 1;

    while terminated == 0
        getvolume();

        % present fixation or cues
        [chosen, rt] = presentCue(b,g,t,term_cond,mode,cols,chosen,rt,currOutcome);
        % last trial in game?
        if user.conditions.block(b).termination(g) == t || chosen ~=0
            terminated = 1;
            getvolume();

            % present termination screen
            presentTerm(b,g,term_cond,mode,cols,chosen,currOutcome)
            getvolume();

        end



        %% outcome
        if terminated

            % fixation
            getvolume();



            Screen('FillRect', window,params.map.bg_col);
            prepFixCross();
            getvolume();

            prepOutcome(currOutcome);
            t_tmp = Screen('Flip', window);
            user.fixation_outcome(end+1) = t_tmp;

            tic
            while toc < params.task.jitters_byblock(g)
                getvolume();

            end

            logstring=[num2str(t_tmp) '; fixation outcome'];
            params.time.fixationoutcome = t_tmp;
            getvolume();

            disp(logstring);
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
            getvolume();


            prepFixCross();
            prepOutcome(currOutcome);

            t_tmp = Screen('Flip', window);
            fixation_outcome2 = t_tmp;

            %add fixation
            tic
            while toc < params.task.jitter_outocme(l)
                getvolume()
            end
            t_tmp = Screen('Flip', window);
            user.fixation_outcome_out = t_tmp;



        end


        %% log data
        %             if terminated || strcmp(CueFix,'fix')
        getvolume();
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
        user.log(l,19) = user.cue_pres(end);
        user.log(l,20) = user.fixation1(end);

        user.log(l,21) = user.response(end);

        %fixation 2
        % outcome

        % when miss trial: set next trial as slider trial
        if terminated && user.conditions.block(b).slider_term(g) && (chosen == 0 || chosen == 999)
            getvolume();

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
                getvolume();

            end
        end

        if terminated   % outcome of game after termination
            user.log(l,4) = deltaOutcome; % change in outcome
            user.log(l,9) = currOutcome;
            user.log(l,10) = winloss;
            user.log(l,22) = user.fixation_outcome(end);
            user.log(l,23) = user.outcome(end);
            user.log(l,24) = fixation_outcome2;

            if ~isnan(winloss)  % reset currOutcome after reward/punishment
                currOutcome = median([1 params.outcome.n_steps]);
            end
        end
        % next trial / line in logfile
        t = t+1;
        l = l+1;
        save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '_log.mat']);
    end
    getvolume();

end


if b < 4
    Screen('FillRect', window);
    %preparestring(['block ' int2str(b) ' of ' int2str(params.task.exp.n_blocks) ' done.'],1,0,50);
    DrawFormattedText(window, ['Block ' int2str(b) ' of ' int2str(params.task.exp.n_blocks) ' done.'], 'center', 'center', params.general.display.text_col );

    t_tmp = Screen('Flip',window);
    params.time.blockBreak = t_tmp;
    disp(logstring);
    %wait(params.trigger.nulltime);
    getvolume();
    WaitSecs(5)% To change if needed


end
%% end of experiment

getvolume();
save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '.mat'],'user','params');
save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '_log.mat']);

if b ==3
    Screen('FillRect', window, params.general.display.bg_col);
    DrawFormattedText(window, 'finished!', 'center', 'center', params.general.display.text_col );
    
    t_tmp = Screen('Flip', window);
    %% determine outcome

    tmp_outcs = find(~isnan(user.log(:,10)));
    if ~isempty(tmp_outcs)
        user.final_outcome = sum(user.log(tmp_outcs,10)) * params.outcome.poundPerWin;
    else
        user.final_outcome = 0;
    end
    tic 
    while toc < 2
        getvolume()
    end


    Screen('FillRect', window,params.general.display.bg_col);
    DrawFormattedText(window, ['You have won additional €' num2str(user.final_outcome,'%.2f') '!'] ...
        , 'center', 'center', [0 0 0]);
    Screen('Flip', window);
    tic 
    while toc < 5
        getvolume()
    end
end


%% save data
save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '.mat'],'user','params');
save([params.general.rest_dir_participant  int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) '_log.mat']);

diary off

clear all; close all; clc
sca;


end