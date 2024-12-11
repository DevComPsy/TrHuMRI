function [window, windowRect, xCenter, yCenter, ifi, ...
    black, white, grey, outcomecolor, ...
    leftRect, rightRect] = setupScreen(debug)
% SetupScreen.m sets up the screen parameters for the experiment
%
% Input: 
% debug:                    if true, opens a smaller window for debugging purposes
%
% Output: 
% window:                    on-screen window for the experiment
% windowRect:                defines the spatial dimensions of the window on the screen
% xCenter, yCenter:          x and y coordinates of the center of the window, respectively
% ifi:                       "inter-frame interval" represents the duration (in seconds) of a single frame flip on the screen
% black, white, grey:        define black & white colors
% outcomecolor:              color of reward shown to participants
% leftRect, rightRect:       size of left/right image

%----------------------------------------------------------------------

% Set the screen number to the external screen (change if necessary)
screenNumber = max(Screen('Screens'));

% Define black, white, and grey colors
white = WhiteIndex(screenNumber);
grey = 213; % Modified grey level
black = BlackIndex(screenNumber);

% Define colors for outcome
outcomecolor = [1 0 0; 0 1 0];  % Red and green colors

% Aleya: addeed debug section to enable smaller screen
if debug
    % Open a smaller window for debugging (e.g., 800x600)
    windowRect = [0 0 800 600];  % Smaller window size
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, windowRect, 32, 1);
else
    % Open fullscreen window for regular task execution
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 1);
end

% Get the size of the window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Query the frame duration (inter-frame interval)
ifi = Screen('GetFlipInterval', window);

% Set the locations for the left and right images
stim.frameSide = round(screenXpixels * 0.3);
stimRect = [0 0 stim.frameSide stim.frameSide];  % Frame for stimulus presentation

% Define the left rectangle position
rectXposL = screenXpixels * 0.25;
rectYposL = screenYpixels * 0.5;
leftRect = CenterRectOnPointd(stimRect, rectXposL, rectYposL);

% Define the right rectangle position
rectXposR = screenXpixels * 0.75;
rectYposR = screenYpixels * 0.5;
rightRect = CenterRectOnPointd(stimRect, rectXposR, rectYposR);

end
