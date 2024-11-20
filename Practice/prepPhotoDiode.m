function prepPhotoDiode(window)

global user
global window
global user params

size_square = 60;

%% Determine color of square
c = user.tmp.col;
if c == 1
    col = [255, 255, 255];  % White (RGB in [0, 255] for Psychtoolbox)
    user.tmp.col = 0;
else
    col = [0, 0, 0];  % Black
    user.tmp.col = 1;
end

%% Define the position and size of the square
xPos = -1024/2 + size_square/2;
yPos = -768/2 + size_square/2;

% Calculate the coordinates of the rectangle (centered on xPos, yPos)
rect = CenterRectOnPointd([0 0 size_square size_square], xPos, yPos);

%% Display the square using Psychtoolbox
Screen('FillRect', window, col, rect);

end
