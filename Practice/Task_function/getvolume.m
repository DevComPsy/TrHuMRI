function getvolume()
%Use either keybord or emulscan
global triggerKey current_volume lastTriggerPressed escapeKey user params
[~, firstPress, ~,~ , ~]=KbQueueCheck;% check if trigger was pressed
if firstPress(triggerKey) ~= 0
    current_volume = current_volume +1;
    time = firstPress(triggerKey); %take last trigger
    user.triggerno(end+1) = current_volume;
    user.triggertime(end+1) = time;
    lastTriggerPressed = time;
elseif firstPress(escapeKey) ~=0
    % time = lastTriggerPressed;
    save([params.general.res_dir int2str(user.date) '_' int2str(user.ID) 'block_' int2str(b) 'temp.mat'],'user','params');
    sca;
    return;
else % if no trigger and no escape
    time = lastTriggerPressed;
end


end
