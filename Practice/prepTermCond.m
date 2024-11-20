% function prepTermCond(term_cond)
%
% TreasureHunt function
% prepares to display the potential amount of money they can lose. This
% will be shown during the trials
%
% @buffer_num: which cogent buffer it will be stored
% @term_cond: termination condition that will be displayed
%
% TH, 09.14/12.14
%
function prepTermCond(term_cond)

global params
global window

%cgrect([params.task.termXY(1) params.task.termXY(1)],...
    %[params.task.termXY(2) params.task.termXY(2)],...
    %[params.task.term_map_size(1) params.task.term_map_size(1)-params.task.term_thickness],...
    %[params.task.term_map_size(2) params.task.term_map_size(2)-params.task.term_thickness],...
    %[params.task.term_cols(term_cond,:); params.general.display.bg_col]);


rect_pos = [params.task.termXY(1), params.task.termXY(2)];   % Center position
outer_rect_size = [params.task.term_map_size(1), params.task.term_map_size(2)];  % Outer rectangle size
inner_rect_size = [params.task.term_map_size(1)-params.task.term_thickness, params.task.term_map_size(2)-params.task.term_thickness];  % Inner rectangle (thickness reduced)

outer_rect = CenterRectOnPointd([0 0 outer_rect_size(1) outer_rect_size(2)], rect_pos(1), rect_pos(2));
inner_rect = CenterRectOnPointd([0 0 inner_rect_size(1) inner_rect_size(2)], rect_pos(1), rect_pos(2));

Screen('FillRect', window, params.task.term_cols(term_cond,:), outer_rect);

Screen('FillRect', window, params.general.display.bg_col, inner_rect);


end