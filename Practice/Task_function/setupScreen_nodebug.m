
function [window, windowRect, xCenter, yCenter, ifi, ...
    black, white, grey, outcomecolor, ...
    leftRect, rightRect] = setupScreen()
% SetupScreen.m sets up the screen parameters for the experiment
%
% Input: 
% None
%
% Output: 
% window:                     on-screen window for the experiment
% windowRect:                 defines the spatial dimensions of the window on the screen
% xCenter, yCenter:           x and y coordinates of the center of the window, respectively
% ifi:                       "inter-frame interval" represents the duration (in seconds) of a single frame flip on the screen
% black, white, grey:         define black & white colors
% outcomecolor:               color of reward shown to participants
% isiTimeFrames:              Interstimulus interval time in frames
% leftRect,rightRect:         size of left/right image


%----------------------------------------------------------------------
%                       Screen information
%----------------------------------------------------------------------


% Set the screen number to the external secondary monitor if there is one
% connected

% Set the screen number to the external screen (change if necessary)
screenNumber = max(Screen('Screens'));

% Define black, white and grey
%
white = WhiteIndex(screenNumber);
grey = white / 2;
grey = 193/255;
black = BlackIndex(screenNumber);
% Define colours
outcomecolor = [ 1 0 0;0 1 0];

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 1);

% Open a window on the external screen with a gray background

% Get the size of the window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter]      = RectCenter(windowRect); % Get the centre coordinate of the window in pixels
% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the locations for the left and right images
stim.frameSide      = round(screenXpixels*0.3);
stimRect            = [0 0 stim.frameSide stim.frameSide]; % Frame for stimulus presentation

rectXposL            = screenXpixels * 0.25;
rectYposL            = screenYpixels * .5;
scr.rectCoordL       = CenterRectOnPointd(stimRect, rectXposL, rectYposL);
leftRect = scr.rectCoordL;

rectXposR            = screenXpixels * 0.75;
rectYposR            = screenYpixels * .5;
scr.rectCoordR       = CenterRectOnPointd(stimRect, rectXposR, rectYposR);

rightRect = scr.rectCoordR; % [screenXpixels / 2, 0, screenXpixels, screenYpixels];



end
