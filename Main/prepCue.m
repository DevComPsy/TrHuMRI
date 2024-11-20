% function prepCue(n_cues)
%
% TreasureHunt function
% prepares cues.
%
% @n_cues: number of cues to be displayed for each color [y b]
% @col: colors of cues
%
% TH, 11.14/12.14
%
function cue_poss = prepCue(n_cues, col, given_cue_pos)

global params user
global window %Aleya: passed 'window' as a global function

% if cues have to be newly drawn
if nargin <= 2
    unused_cues = find(user.grid.used == 0);
    n_unused_cues = numel(unused_cues);
    if n_unused_cues < sum(n_cues)
        error('less unused cue positions available than needed')
    end
    
    
    
    cue_poss = [];
    for cl = 1:length(n_cues)   % color of cue
        for c = 1:n_cues(cl)
            
            % randomly choose position
            
            rand_pos = randi(n_unused_cues,1);
            cue_pos = user.grid.posXY(unused_cues(rand_pos),:);


            % draw cues using Psychtoolbox
            cue_posX = cue_pos(1);
            cue_posY = cue_pos(2);
            cue_size = params.map.cue_size;
            cue_color = col(cl, :);  % Color for the cue
            
            %Aleya: convert cgrect to PTB function

            % Define the rectangle's coordinates: [left, top, right, bottom]
            rect = CenterRectOnPointd([0 0 cue_size cue_size], cue_posX, cue_posY);
            
            % Draw the rectangle at the specified position with the given color
            Screen('FillRect', window, cue_color, rect);
            
            % draw cues (old in cogent)
            %cgrect(cue_pos(1),cue_pos(2),params.map.cue_size,params.map.cue_size,col(cl,:));
            
            % update unused cues
            user.grid.used(unused_cues(rand_pos)) = 1;
            unused_cues = find(user.grid.used == 0);
            n_unused_cues = numel(unused_cues);
            
            cue_poss = [cue_poss;  cue_pos cl];
        end
    end
    
else    % if the cue locationsa re already known
    for c = 1:size(given_cue_pos,1)
         % draw cues
         %cgrect(given_cue_pos(c,1),given_cue_pos(c,2),params.map.cue_size,params.map.cue_size,col(given_cue_pos(c,3),:));
        cue_posX = given_cue_pos(c, 1);
        cue_posY = given_cue_pos(c, 2);
        cue_size = params.map.cue_size;
        cue_color = col(given_cue_pos(c, 3), :);  % Color for the cue
        
        % Define the rectangle's coordinates: [left, top, right, bottom]
        rect = CenterRectOnPointd([0 0 cue_size cue_size], cue_posX, cue_posY);
        
        % Draw the rectangle at the specified position with the given color
        Screen('FillRect', window, cue_color, rect);

% Optionally, flip the screen if needed to display the rectangle
% Screen('Flip', window);
    end
    cue_poss = given_cue_pos;
end

end