function [current_volume, Trigger_received]  = waitForVolumes(n)
global user
% Wait until n volume is acquired before continuying
% Input : number of volume before starting
global triggerKey current_volume  % could not use subscript to call trigger
    while current_volume < n
        % Simulate receiving a volume (replace this with your actual code)
        Trigger_received = KbTriggerWait(triggerKey);
        if Trigger_received
            current_volume = current_volume + 1;
            disp(['Received volume ', num2str(current_volume)]);
             user.triggertime(end+1) = Trigger_received;
             user.triggerno(end+1) = current_volume;

        end
        % Wait for trigger (replace kbwait with your actual trigger function)
    end
    disp(['Received ', num2str(n), ' volumes']);
end