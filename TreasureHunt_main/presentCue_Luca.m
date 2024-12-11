function [chosen,rt] = presentCue(b,g,t,term_cond,mode,cols,chosen,rt,currOutcome)


global user params
global window

%readkeys
%logkeys

[pressed, firstPressTimes] = KbQueueCheck(); % Read keypresses
if pressed
    logFile = fopen('key_log.txt', 'a'); % Open log file
    keyPressTimes = find(firstPressTimes);
    for i = 1:length(keyPressTimes)
        fprintf(logFile, 'Key %d pressed at time %.3f\n', keyPressTimes(i), firstPressTimes(keyPressTimes(i)));
    end
    fclose(logFile); % Close log file after logging
end


%clearpict(3)
Screen('FillRect', window, [0 0 0]);
prepOutcome(currOutcome);
prepTermCond(term_cond);
prepMap();
prepFixCross();
prepPhotoDiode();

% prepare cues
logstring = ['Trial: ' int2str(b) '_' int2str(g) '_' int2str(t)];
disp(logstring);
user.grid.log{b,g,t} = prepCue(user.conditions.block(b).game(g).n_cues(t,:),params.colSp.cueCols);


prepButton(mode,cols,b,g,chosen)

% determine trisgger
if chosen == 0 && term_cond == 1
    triggerCue = params.trigger.tr_cueTerm1 + t;
elseif chosen == 0 && term_cond == 2
    triggerCue = params.trigger.tr_cueTerm2 + t;
elseif chosen > 0 && term_cond == 1
    triggerCue = params.trigger.tr_cueTerm1Selected + t;
elseif chosen > 0 && term_cond == 2
    triggerCue = params.trigger.tr_cueTerm2Selected + t;
else
    error('unindentifiable cue trigger');
end

% present
cgflip('v')
%t_tmp = drawpict(3);
t_tmp = Screen('Flip', window);

% send triggers
outportb(params.trigger.scanport, triggerCue); %Aleya: might need to delete this
EyelinkFun('Message',[int2str(triggerCue)]);
logstring=[num2str(t_tmp) '; cues'];
disp(logstring);
%wait(params.trigger.nulltime)
WaitSecs(params.trigger.nulltime);
outportb(params.trigger.scanport, params.trigger.null);

% how long to present
dur = params.task.trial.dur_stimulus - params.trigger.nulltime;
    

% how to respond
keyout = [];
%if chosen == 0
    %[keyout, t_tmp_resp] = waitkeydown(dur,[params.general.keys.r, params.general.keys.l]);
%else
    %waituntil(t_tmp + dur);
%end

if chosen == 0
    % Wait for key press
    KbQueueStart(); % Start monitoring key presses
    [keyout, t_tmp_resp] = KbQueueCheck(); % Check for key presses within the duration
    WaitSecs(dur); % Wait for the specified duration
    KbQueueStop(); % Stop monitoring key presses
else
    %waituntil(t_tmp + dur); 
    WaitSecs( (t_tmp + dur) -  - GetSecs);
end


%if ~isempty(keyout)
if any(keyout)
    if keyout == params.general.keys.r
        trigg = params.trigger.tr_r_buttonpress;
    elseif keyout == params.general.keys.l
        trigg = params.trigger.tr_l_buttonpress;
    else
        error('no trigger for button press available')
    end
    outportb(params.trigger.scanport, trigg);
    logstring = [num2str(t_tmp_resp) '; response: ' int2str(keyout)];
    disp(logstring);
    EyelinkFun('Message',int2str(trigg));
    %wait(params.trigger.nulltime)
    WaitSecs(params.trigger.nulltime*0.001);
    outportb(params.trigger.scanport, params.trigger.null);
end


   
%% response evaluation
%readkeys
%logkeys
[pressed, firstPressTimes] = KbQueueCheck();

%if ~isempty(keyout)
if any(pressed)
    % evaluate chosen option
    if keyout == params.general.keys.r      % chosen: 1: biman_right, 2: biman_left
        chosen = 1;
    elseif keyout == params.general.keys.l
        chosen = 2;
    end
    
    
    % present rest of time
    %clearpict(3)
    Screen('FillRect', window, [0 0 0]); 
    prepPhotoDiode();
    prepOutcome(currOutcome);
    prepTermCond(term_cond);
    prepMap();
    prepCue(user.conditions.block(b).game(g).n_cues(t,:),params.colSp.cueCols,user.grid.log{b,g,t});
    prepButton(mode,cols,b,g,chosen);
    prepFixCross();
    cgflip('v')
    %drawpict(3);
    Screen('Flip', window);
    %waituntil(t_tmp + dur);
    WaitSecs( (t_tmp + dur) -  - GetSecs);
end

%% determine RT
if isnan(rt)
    if chosen == 0 || chosen == 999
        rt = nan;
    else
        rt = t_tmp_resp - t_tmp;
    end
end

outportb(params.trigger.scanport, params.trigger.tr_offset);
EyelinkFun('Message',[int2str(params.trigger.tr_offset)]);
%wait(params.trigger.nulltime)
WaitSecs(params.trigger.nulltime*0.001);
outportb(params.trigger.scanport, params.trigger.null);