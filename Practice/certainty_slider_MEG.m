%[rating, rton, rtoff, alltime] = certainty_slider_MEG()
%
%times are in ms (8000, 4000) and previousrating is 0-1
%rating 0-1, startlocation generally 0.5, rt is time last button contact
% written by Robb Rutledge
% modified by TH
%
function [rating, rton, rtoff, alltime] = certainty_slider_MEG(currOutcome)


global params

sx = [-100 100]; sy = [0 0]; %in pixels, since it's 1024 wide, this is 75% of the screen
rating = nan;                %in case early exit
rton = nan;
rtoff = nan;
respkeys = [params.general.keys.l params.general.keys.r];

% waittime
%cgflip(params.general.display.bg_col);
%cgpencol(params.general.display.fg_col);
%cgrect(0,0,diff(sx),4,[0 0 0]);
%cgrect(sx(1),sy(1),4,20,[0 0 0]);
%cgrect(sx(1)+(diff(sx)/3),sy(1),4,20,[0 0 0]);
%cgrect(sx(1)+(diff(sx)/3)*2,sy(1),4,20,[0 0 0]);
%cgrect(sx(1)+(diff(sx)/3)*3,sy(1),4,20,[0 0 0]);
%prepOutcome(currOutcome);
%cgflip(params.general.display.bg_col);
%tstart = time;

Screen('FillRect', window, params.general.display.bg_col); % Clear screen with background color
Screen('FillRect', window, params.general.display.fg_col, [0 0 diff(sx) 4]); % Draw rating line
Screen('FillRect', window, [0 0 0], [sx(1) sy(1) 4 20]); % Draw initial indicators
Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3) sy(1) 4 20]);
Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3)*2 sy(1) 4 20]);
Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3)*3 sy(1) 4 20]);
prepOutcome(currOutcome); % Prepare outcome display
Screen('Flip', window); % Flip to display
tstart = GetSecs;

%waituntil(params.slider.waittime + tstart);
WaitSecs(params.slider.waittime + tstart);
x = (sx(2)-sx(1))*params.slider.startloc(1) + sx(1); 
y = 0; %starting location
clearkeys;
%keydown = 0;
keydown = [0; 0]; %no key down right now (vs 1 or 2)
firstkeytime = 0;
lastkeytime = 0;
alltime = [tstart time];

nsample = 0;

%{
while time < tstart + params.slider.waittime + params.slider.resptime;
    cgpencol(params.slider.line_col); cgrect(0,0,diff(sx),4,[0 0 0]); %draw rating line
    cgpencol(params.general.display.fg_col);
%     cgtext(params.slider.question,0,150);
%     cgtext('very',sx(1)-48,sy(1)+10); cgtext('unconfident',sx(1)-50,sy(1)-20);
%     cgtext('very',sx(2)+33,sy(2)+10); cgtext('confident',sx(2)+35,sy(2)-20);
    cgrect(sx(1),sy(1),4,20,[0 0 0]);
    cgrect(sx(1)+(diff(sx)/3),sy(1),4,20,[0 0 0]);
    cgrect(sx(1)+(diff(sx)/3)*2,sy(1),4,20,[0 0 0]);
    cgrect(sx(1)+(diff(sx)/3)*3,sy(1),4,20,[0 0 0]);
    
    cgdraw(sx(1),sy(1),sx(2),sy(2));
%     cgellipse(sx(1),sy(1),10,10,'f'); %draw endpoints
%     cgellipse(sx(2),sy(2),10,10,'f');
    cgpencol(params.slider.indicator_col); cgellipse(x,y,10,10,'f');
    prepOutcome(currOutcome);
    cgflip(params.general.display.bg_col);
    nsample = nsample+1;
    
    readkeys;  
    [key,ktime,nkeypress] = getkeydown(respkeys);
    if nkeypress, %0, 1 or 2 - key was pressed last - both possible
        keydown = (keydown + (respkeys(:) == sort(key(:))))>0; %1 0, 0 1 or 1 1
    end;
    [key,ktime,nkeyrelease] = getkeyup(respkeys);
    if nkeyrelease, %key was released
        keydown = (keydown - (respkeys(:) == sort(key(:))))>0; %1 0, 0 1 or 1 1; 
    end;
    if sum(keydown), %at least one button pressed
        if keydown(1), %if both pressed, go left
            x = x - params.slider.pixperkey;
        else,
            x = x + params.slider.pixperkey;
        end;
        if ~firstkeytime, 
            firstkeytime = time; 
        end; %first key press
        lastkeytime = time; %circle moved
        if x < sx(1), x = sx(1); end
        if x > sx(2), x = sx(2); end;
    end;
end
%}



while GetSecs < tstart + params.slider.waittime + params.slider.resptime
    % --- Draw Slider --- %
    Screen('FillRect', window, params.slider.line_col, [0 0 diff(sx) 4]); % Draw rating line
    Screen('FillRect', window, params.general.display.fg_col, [sx(1) sy(1) 4 20]); % Draw indicators
    Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3) sy(1) 4 20]);
    Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3)*2 sy(1) 4 20]);
    Screen('FillRect', window, [0 0 0], [sx(1)+(diff(sx)/3)*3 sy(1) 4 20]);
    
    % Draw the current slider position
    Screen('FillOval', window, params.slider.indicator_col, [x-10 y-10 x+10 y+10]); % Draw indicator

    prepOutcome(currOutcome); % Prepare outcome
    Screen('Flip', window); % Update screen
    nsample = nsample + 1; % Increment sample count

    % --- Handle Key Presses --- %
    [keyIsDown, keyCode, ~] = KbCheck; % Check if a key is pressed
    if keyIsDown
        for i = 1:length(respkeys)
            if keyCode(respkeys(i))
                keydown(i) = 1; % Mark key down
            end
        end
    else
        keydown(:) = 0; % Reset if no key is down
    end
    
    % Update slider position based on key press
    if keydown(1) % Left key pressed
        x = x - params.slider.pixperkey;
    elseif keydown(2) % Right key pressed
        x = x + params.slider.pixperkey;
    end
    
    % Bound the slider position within limits
    if x < sx(1), x = sx(1); end
    if x > sx(2), x = sx(2); end
    
    % Track timing of key presses
    if any(keydown)
        if firstkeytime == 0
            firstkeytime = GetSecs; % Record first key press time
        end
        lastkeytime = GetSecs; % Update last key press time
    end
end


disp(nsample); %should be 240 samples in the 4s period

rating = (x - sx(1)) / (sx(2) - sx(1)); %0 to 1
if lastkeytime,
    rton = (firstkeytime - tstart - params.slider.waittime)/1000;
    rtoff = (lastkeytime - tstart - params.slider.waittime)/1000; 
end; %if pressed, last press in s
params.slider.startloc(1) = [];