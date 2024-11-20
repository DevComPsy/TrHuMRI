function prepFixCross() 

global params window

%cgrect(0,0,5,5,params.general.display.fg_col);

rect_size = 5;  % Size (width and height)
rect_color = params.general.display.fg_col;  % Color

% Define the rectangle's coordinates (centered at 0,0)
rect = CenterRectOnPointd([0 0 rect_size rect_size], params.screen.xCenter, params.screen.yCenter);

% Draw the rectangle at the center of the screen
Screen('FillRect', window, rect_color, rect);

% Optionally, flip the screen if needed to display the rectangle
 
end