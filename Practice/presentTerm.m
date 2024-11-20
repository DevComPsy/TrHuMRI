function presentTerm(b,g,term_cond,mode,cols,chosen,currOutcome)


global user params  window


Screen('FillRect', window,params.map.bg_col);
prepOutcome(currOutcome);
prepTermCond(term_cond);

%if chosen ==0
rectPosition = [params.map.posXY(1) - (params.map.sizeXY(1) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(2) - (params.map.sizeXY(2) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(1) + (params.map.sizeXY(1) + params.map.borderSize / 2) / 2, ...
              params.map.posXY(2) + (params.map.sizeXY(2) + params.map.borderSize / 2) / 2];

% Draw map
borderPosition = [params.map.posXY(1) - params.map.sizeXY(1) / 2, ...
           params.map.posXY(2) - params.map.sizeXY(2) / 2, ...
           params.map.posXY(1) + params.map.sizeXY(1) / 2, ...
           params.map.posXY(2) + params.map.sizeXY(2) / 2];





% First, draw the border (if applicable)
Screen('FillRect', window, params.map.col , borderPosition);

% Then, draw the inner rectangle
Screen('FillRect', window, params.colSp.terminationCol, rectPosition);

%end
prepButton(mode,cols,b,g,chosen)
prepFixCross();


vbl = Screen('Flip', window); 

user.termination(end+1) = vbl;
t_tmp = GetSecs;

logstring=[num2str(t_tmp) '; Termination'];
disp(logstring);
WaitSecs(1.5);% how long to present pink square

%waituntil(params.task.term_dur + t_tmp);
%WaitSecs(params.task.term_dur*0.001);
