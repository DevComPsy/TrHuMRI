function [escapeKey, leftKey, rightKey, triggerscan,confirm] = setupKeys2()
% Set up the keys
% Input: 
% None
%
% Output: 
% escapeKey,leftKey,rightKey: definitions of keyboard keys
% triggerscan:                trigger key from scanner

% update 30.04.2025 added KbName('UnifyKeyNames'); 
%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames'); 
escapeKey = KbName('ESCAPE');
leftKey = KbName('z'); %yellow
rightKey = KbName('g'); %green
triggerscan = KbName('t');
confirm = KbName('space');


end