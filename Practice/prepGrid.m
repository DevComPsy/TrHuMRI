% function prepGrid()
%
% TreaureHunt function
% prepares a grid for the hidden map which can then be used to place the
% cues.
%
% TH, 09.14
%
function prepGrid()

global user params
global window

% determine size of cue
tot_size = params.map.sizeXY(1) * params.map.sizeXY(2);
cue_size = sqrt(tot_size / params.map.n_cues);
if (cue_size - floor(cue_size)) ~= 0
    warning('area of cue is not an integer; adjusting size')
    cue_size = floor(cue_size);
end
params.map.cue_size = cue_size;

% subdivide grid
n_cues_x = params.map.sizeXY(1) / cue_size;
if (n_cues_x - floor(n_cues_x)) ~= 0
    warning('map along x-axis not divisible by cue-length: decreasing number of cues!')
    n_cues_x = floor(n_cues_x);
end
n_cues_y = params.map.sizeXY(2) / cue_size;
if (n_cues_y - floor(n_cues_y)) ~= 0
    warning('map along x-axis not divisible by cue-length: decreasing number of cues!')
    n_cues_y = floor(n_cues_y);
end

% define grid
user.grid.posXY = nan(params.map.n_cues,2);
user.grid.used = zeros(1,params.map.n_cues);
c = 0;  % current cue
for y = 1:n_cues_y  % loop through y lines
    if y == 1       %initialize
        curr_y = params.map.posXY(2) - params.map.sizeXY(2)/2 + cue_size/2;
    else
        curr_y = curr_y + cue_size;
    end
    for x = 1:n_cues_x % loop through x-axis
        c = c + 1;
        if x == 1       %initialize
            curr_x = params.map.posXY(1) - params.map.sizeXY(1)/2 + cue_size/2;
        else
            curr_x = curr_x + cue_size;
        end
        
        % fill in coordinates
        user.grid.posXY(c,:) = [curr_x curr_y];
    end
end

% check whether all cues are filled
if c ~= params.map.n_cues || ~isempty(find(isnan(user.grid.posXY)))
    warning('number of cues does not fit with predetermined number!')
    user.grid.posXY = user.grid.posXY(1:c,:);
    user.grid.used = user.grid.used(1:c);
end


end