function [mode,cols,term_cond,triggerInstr] = prepGameInstr(block_num,game_num)

% TreasureHunt function
% prepares the screen for indication the conditions of the game including
% pot punishment, and response mode
%
% @block_num: current block number
% @game_num: current game number
% @mode: response mode: 'uniman' or 'biman'
% @cols: color(s) of the button(s)
% @term_cond: which termination condition one is in
% @triggerInstr: trigger code for game instrtruction encoding potential
% punishment
% @triggerCue: trigger code for given cue encoding Threshold and Action
% condition
%
% TH, 09.14
%

global params user lastTriggerPressed window


getvolume();

term_cond = user.conditions.block(block_num).term_cond(game_num);


prepTermCond(term_cond)
switch term_cond
    case 1
        triggerInstr = params.trigger.tr_gameInstrTerm1;
    case 2
        triggerInstr = params.trigger.tr_gameInstrTerm2;
    otherwise
        error('unknown pot_pun amount.')
end


% response condition
if user.conditions.block(block_num).GoodsAction(game_num) == 1      % action vs goods
    mode = 'biman';
elseif user.conditions.block(block_num).GoodsAction(game_num) == 0
    mode = 'uniman';
else
    error('unknown response condition')
end

% fixed vs free trial duration
if user.conditions.block(block_num).ThreshCond(game_num) == 1 && strcmp(mode,'biman')
    cols = params.colSp.cueCols;
%     triggerCue = params.trigger.tr_cueThreshAction;
elseif user.conditions.block(block_num).ThreshCond(game_num) == 1 && strcmp(mode,'uniman')
    cols = params.resp.uniman.col;
%     triggerCue = params.trigger.tr_cueThreshGoods;
else
    error('unknown response action condition')
end
if user.conditions.block(block_num).respColSide(game_num) == 0
    cols = flipud(cols);
elseif user.conditions.block(block_num).respColSide(game_num) ~= 1
    error('uknown response side')
end

prepMap();
prepButton(mode,cols,block_num,game_num,0);
prepFixCross();
getvolume();

end