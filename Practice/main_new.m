clear all; close all; clc
[userID debug] = getIDdlg();
addpath(genpath('.'));


%% initialize experiment
global params user
TreasHunt_initialize(userID,debug);
TreasHunt_user_initialize(userID,debug);
mkdir(params.general.res_dir);
TreasHunt_games_initialize_noFixThresh_noGoodSp()

%% check whether logfiles from this subject already exist
if exist([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.mat'],'file') > 0
    error('logfile of this subject already exists! Did you enter the wrong subject number?')
end

%% logfile
diary([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.dry'])
config_log([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.log'])

%% general settings

[window, windowRect, xCenter, yCenter, ifi, ...
    black, white, grey, outcomecolor, ...
    leftRect, rightRect] = setupScreen();

% Set the text font and size
Screen('TextFont', window, params.general.text.font);
Screen('TextSize', window, params.general.text.font_size);


% Initialize keyboard input
[params.general.keys.escape, params.general.keys.l ,params.general.keys.r , params.general.keys.trigger, params.general.keys.confirm] = setupKeys();
global current_volume triggerKey

triggerKey = params.general.keys.trigger;
current_volume = 1; %Recorded the first trigger
[current_volume, lastTriggerPressed] = waitForVolumes(params.trigger.tr_dummies); % Wait 6 vols before starting


% KbQueue setup for checking keys
KbQueueCreate(); 

% Start the queue
KbQueueStart();

%% start psychtoolbox
PsychDefaultSetup(2);


%% run experiment
% general instruction


Screen('FillRect', window, white); 
vbl = Screen('Flip', window);
tstart = vbl;
params.time.start = tstart;

DrawFormattedText(window, 'press button to start experiment', 'center', 'center', grey); 

t_tmp = Screen('Flip', window); 
params.time.generalinstruction = t_tmp;
disp([num2str(t_tmp) '; resp general instruction']);
waitSecs(params.trigger.nulltime * 0.001);


%readkeys
%logkeys
[pressed, firstPressTimes] = KbQueueCheck(); % Check for key presses


l = 1;  % logbook-line
currOutcome = median([1 params.outcome.n_steps]); % initialize outcome-bar
for b = 1:params.task.exp.n_blocks


    % log & trigger
    disp([int2str(b) 'Block: ']);
    params.currentBlock = int2str(b);
    waitSecs(params.trigger.nulltime * 0.001);
    
    % block instruction
    Screen('FillRect', window, white);
    blockText = ['Block ' int2str(b) ' of ' int2str(params.task.exp.n_blocks)];
    DrawFormattedText(window, blockText, 'center', 'center', grey);

    t_tmp = Screen('Flip', window); 
    params.time.blockInstruction = t_tmp;
    disp([num2str(t_tmp) '; block instruction']);
    waitSecs(params.trigger.nulltime * 0.001);

    % loop through games
    for g = 1:params.task.exp.n_games
        
        % pre-game fixation, log stuff & send triggers

        [pressed, firstPressTimes] = KbQueueCheck();
        if pressed
            
            keyPressTimes = find(firstPressTimes);
            for i = 1:length(keyPressTimes)
                params.keypresstimes(end+1) = keyPressTimes(i);
            end 
        end

        logstring=['Game: ' int2str(b) '_' int2str(g)];
        params.currentgamenumber = logstring;
        disp(logstring);
        Screen('FillRect', window, white); 
        prepFixCross();
        prepOutcome(currOutcome);
        prepPhotoDiode();
        t_tmp = Screen('Flip', window); 
        WaitSecs(params.trigger.nulltime * 0.001);
       
            
         % initialize grid
        prepGrid()   
        
        % display game instruction (buffer 1)
        Screen('FillRect', window, white); 
        [mode,cols,term_cond,triggerInstr] = prepGameInstr(b,g);
        prepOutcome(currOutcome);
        prepFixCross();
        prepPhotoDiode();
        t_tmp = Screen('Flip', window);
        logstring=[num2str(t_tmp) '; gameInstr '];
        params.time.instruction = t_tmp;
        disp(logstring);
        WaitSecs(params.trigger.nulltime * 0.001);

        [pressed, firstPressTimes] = KbQueueCheck(); % Check for key presses

        if pressed
            keyPressTimes = find(firstPressTimes);
            for i = 1:length(keyPressTimes)
                params.keypresstimes(end+1) = keyPressTimes(i);
            end
        end
        

        % loop through trials until subject responds
        terminated = 0;
        t = 1;
        chosen = 0;                  % whether color was chosen
        rt = nan;
        
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
                
                % fixation
              
                [pressed, firstPressTimes] = KbQueueCheck();

                Screen('FillRect', window, [0 0 0]); 
                prepFixCross();
                prepOutcome(currOutcome);
                prepPhotoDiode();
                t_tmp = Screen('Flip', window); 
                logstring=[num2str(t_tmp) '; fixation outcome'];
                params.time.fixationoutcome = t_tmp;
                disp(logstring);
                WaitSecs(params.trigger.nulltime*0.001);
                
                
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
                    
    
                
                user.log(l,18) = rton;
                user.log(l,19) = rtoff;
                user.log(l,20) = rating;

                
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
%             end
            
            
        end
        

              
        
    end
%% save between blocks
save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.mat']);
    
    
%% break between blocks
%readkeys
%logkeys
[pressed, firstPressTimes] = KbQueueCheck();

if pressed
    
    keyPressTimes = find(firstPressTimes);
    for i = 1:length(keyPressTimes)
        params.keypresstimes(end+1) = keyPressTimes(i);
    end 
end

    if b < params.task.exp.n_blocks
        Screen('FillRect', window, [0 0 0]); 
        DrawFormattedText(window, ['Block ' int2str(b) ' of ' int2str(params.task.exp.n_blocks) ' done.'], 'center', 'center', [255, 255, 255]);
        t_tmp = Screen('Flip', window);
        logstring=[ num2str(t_tmp) '; nextBlockAwait'];
        params.time.blockBreak = t_tmp;
        disp(logstring);
        WaitSecs(params.trigger.nulltime * 0.001);
        

        DrawFormattedText(window, 'Press button to start next block.', 'center', 'center', grey);
        Screen('Flip', window);
        %[keyout, t_tmp] = waitkeydown(inf,params.general.keys.confirm);
        [secs, keyCode] = KbWait([], 2); 
        keyout = find(keyCode, 1); 
        logstring=[num2str(t_tmp) '; nextBlockStart: ' int2str(keyout)];
        params.time.nextBlock = t_tmp;
        params.time.keyout = keyout;
        disp(logstring);
        WaitSecs(params.trigger.nulltime * 0.001);
        
    elseif b == params.task.exp.n_blocks
    %     %% stop eyetracking & save file
    %     if params.general.eyelink
    %         Eyelink( 'StopRecording' )                   % stop recording
    %         Eyelink( 'Closefile' )                       % close the file
    %         Eyelink( 'ReceiveFile' )                     % copy the file from eyetracker PC to Stim PC
    %         try
    %             movefile([int2str(userID) '_' int2str(b) '.edf'],params.general.res_dir);
    %         catch
    %             warning(['not able to move eyetracking file of block' int2str(b) '!']);
    %         end
    %     end
    % end
    
    
    end

%% end of experiment

WaitSecs(params.trigger.nulltime * 0.001);


% finished


Screen('FillRect', window, params.general.display.bg_col);
DrawFormattedText(window, 'finished!', 'center', 'center', grey);  
t_tmp = Screen('Flip', window);
params.time.finished(t_tmp);

% Wait for a key press or timeout after 2 seconds 
[secs, keyCode] = KbWait([], 2, GetSecs() + 2);  
 


% Clear the screen.
sca;


%% determine outcome
display('--------------------------------------------------------------------')
tmp_outcs = find(~isnan(user.log(:,10)));
if ~isempty(tmp_outcs)
    user.final_outcome = sum(user.log(tmp_outcs,10)) * params.outcome.poundPerWin;
else
    user.final_outcome = 0;
end
display(['You have won additional £' num2str(user.final_outcome,'%.2f') '!']);
display('--------------------------------------------------------------------')


 
%% save data
save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '.mat'])
save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) '_log.mat'],'user','params')
diary off
