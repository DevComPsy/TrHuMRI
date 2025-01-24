%% Script to construct regressor file aligned to triggers

clc; close all; clear;

%change this to your path
data_path = 'D:\Observational Study\Information_gathering-main\Analysis\BEH\';
addpath(genpath('D:\BE Code\gen_funct-master'));
addpath(genpath('D:\Observational Study\Information_gathering-main\Analysis'));

%get foldernames
files1 = dir(data_path);

%remove elements that are not participant folders
matches = regexp({files1([files1.isdir]).name}, {'^\d+|^A\d+'});
bool = cellfun(@(x) any(x), matches);
files = files1(bool);

for i = 18:length(files)
    %subject loop begins
    subject = files(i).name;

    % block loop begins
    for block = 1:4

    %% load log file for specific block

    %make sure we're in correct subject folder
    beh_dir = [data_path subject '\'];
    cd(beh_dir);

    % load log file 
    pattern = ['*_' num2str(subject) 'block_' num2str(block) '_log.mat'];

    % Search for the file that matches the pattern
    fileInfo = dir(pattern);

    % Check if a matching file was found
    if ~isempty(fileInfo)
        % Load the exact file name
        load(fileInfo(1).name);
        disp(['Loaded file: ' fileInfo(1).name]);
    else
        error('No file matching the pattern was found.');
    end

    %% Make sure each block's data is separate

    if block == 1 %if block 1, make var names the same as user.[vars]
        trigger_time = user.triggertime;
        cue_pres_time = user.cue_pres;
        response_time = user.response;
        block_inst_time = user.blockInstruction;
        outcome_time = user.outcome;
        termination_time = user.termination;
        fixation_outcome_after_time = user.log(:,24);
        fixation_before_outcome_time = user.log(:,22);
        fixation_between_cue_time = user.log(:,20);

   % elseif str2double(subject) == 111 & block == 1
   % 
   %          %because block 4 is a bit weird for 102 (it took the aborted
   %          %trials from block3)
   %          trigger_time = user.triggertime(1441+1:end);
   %          cue_pres_time = user.cue_pres(371+1:end);
   %          response_time = user.response(371+1:end);
   %          block_inst_time = user.blockInstruction(3+1:end);
   %          outcome_time = user.outcome(94+1:end);
   %          termination_time  = user.termination(94+1:end);
   %          fixation_outcome_after_time = user.log(371+1:end,24);
   %          fixation_before_outcome_time = user.log(371+1:end,22);
   %          fixation_between_cue_time = user.log(371+1:end,20);
    
    else %if not block 1, subtract length of previous block(s) data from current block
        trigger_time = user.triggertime(trig_time_length+1:end);
        cue_pres_time = user.cue_pres(cue_pre_length+1:end);
        response_time = user.response(response_length+1:end);
        block_inst_time = user.blockInstruction(block_inst_length+1:end);
        outcome_time = user.outcome(outcome_length+1:end);
        termination_time  = user.termination(termination_length+1:end);
        fixation_outcome_after_time = user.log(fix_outcome_after_length+1:end,24);
        fixation_before_outcome_time = user.log(fix_before_outcome_length+1:end,22);
        fixation_between_cue_time = user.log(fix_between_cue_length+1:end,20);
    
    end

%% Find missing triggers 
% Define the threshold gap (around 3 seconds)
threshold_gap = 2.999;                  
% Define the desired interval (1.5 seconds)
desired_interval = 1.5;               

% Initialize a new vector to store adjusted timings
new_triggers = [];  % Start with an empty vector
new_trigger = [];

% Loop through the original timings
for j = 1:length(trigger_time)
   
    % Add the current timing to the new vector
    new_triggers(end+1) = trigger_time(j);
    
    % Check if this is not the last timing
    if j < length(trigger_time)
        % Calculate the gap between current timing and next timing
        gap = trigger_time(j+1) - trigger_time(j);
        
        % If the gap is 3 seconds or more, add new timings in between
        while gap >= threshold_gap
            % Add a new timing with the desired interval (1.5s apart)
            new_trigger = new_triggers(end) + desired_interval;
            new_triggers(end+1) = new_trigger;  % Insert new timing into the new vector
            gap = trigger_time(j+1) - new_triggers;   % Update the gap
        end
    end

      % Check whether any triggers are still missing

      if any(diff(new_triggers)>2.999)
          warning = ['Warning, missing triggers remain for subject_' num2str(subject) '_block_' num2str(block)];
         display(warning);
      end 

end

%% Get all timings for all vars into one table

% Assign vars to new vars
trigger_timings = new_triggers;
cue_pres_timings = cue_pres_time;
response_timings = response_time(~isnan(response_time));
block_inst_timings = block_inst_time;
outcome_timings = outcome_time;
termination_timings = termination_time;
fixation_outcome_after =  fixation_outcome_after_time(~isnan( fixation_outcome_after_time));
fixation_before_outcome = fixation_before_outcome_time(~isnan(fixation_before_outcome_time));
fixation_between_cue = fixation_between_cue_time(~isnan(fixation_between_cue_time));


% Create a cell array for the labels (same length as each corresponding field)
trigger_label = repmat({'trigger'}, length(trigger_timings), 1);
fixation_outcome_after_labels = repmat({'fixation_outcome_after'}, length(fixation_outcome_after), 1);
fixation_before_outcome_labels = repmat({'fixation_before_outcome'}, length(fixation_before_outcome), 1);
fixation_between_cue_labels = repmat({'fixation_between_cue'}, length(fixation_between_cue), 1);
cue_pres_labels = repmat({'cue_pres'}, length(cue_pres_timings), 1);
response_labels = repmat({'response'}, length(response_timings), 1);
block_inst_labels = repmat({'block_instruction'}, length(block_inst_timings), 1);
outcome_labels = repmat({'outcome'}, length(outcome_timings), 1);
termination_labels = repmat({'termination'}, length(termination_timings), 1);

% Combine the labels and timings
all_labels = [trigger_label; fixation_outcome_after_labels; fixation_before_outcome_labels; cue_pres_labels;...
    fixation_between_cue_labels; response_labels; block_inst_labels;  outcome_labels; termination_labels];
all_timings = [trigger_timings';fixation_outcome_after; fixation_before_outcome; fixation_between_cue; cue_pres_timings';...
    response_timings'; block_inst_timings'; outcome_timings'; termination_timings'];

% Create the table
timings_table = table(all_labels, all_timings, 'VariableNames', {'Event', 'Timing'});

% Sort by lowest to longest time
timings_table = sortrows(timings_table, 'Timing');

%convert to categorical
timings_table.Event = categorical(timings_table.Event);

%make sure block instruction exists
if ~any(timings_table.Event == "block_instruction")
    %remove first 6 dummy volumes and behavioural instruction
    msg = 'blockInstruction is missing';
    error(msg)
end 

% make sure trigger is right after block instruction
if timings_table.Event(find(timings_table.Event == "block_instruction")+1) ~= "trigger"
    %remove first 6 dummy volumes and behavioural instruction
    msg = 'trigger does not immediately follow block instruction';
    error(msg)
end 

%remove rows including block instruction
timings_table(1:(find(timings_table.Event == "block_instruction")),:) = [];

%calculate difference between timings
time_diff = diff(timings_table.Timing);

%pad with 0 on top 
time_diff = [0; time_diff(:)];

%calculate new timings based on diff
new_vector = zeros(size(time_diff)); % Initialize a new vector for storing cumulative sums

% Start the cumulative sum from the second row
for k = 2:length(time_diff)
    new_vector(k) = sum(time_diff(1:k));  % Sum from row 1 to row i
end

%add diff timings 
timings_table.time_diff = time_diff;
%add actual timings relative to 7th trigger
timings_table.new_times = new_vector;

%save table with all timings and vars
save([num2str(subject) '_block_' num2str(block) '_all_var_timings.mat'], "timings_table");


%% Put Timings into Struct

timings_table.Event = categorical(timings_table.Event);

beh(block).outcome = timings_table.new_times(timings_table.Event(:) == 'outcome');
beh(block).cue_pres = timings_table.new_times(timings_table.Event(:) == 'cue_pres');
beh(block).fixation_before_outcome = timings_table.new_times(timings_table.Event(:) == 'fixation_before_outcome');
beh(block).fixation_between_cue = timings_table.new_times(timings_table.Event(:) == 'fixation_between_cue');
beh(block).fixation_outcome_after  = timings_table.new_times(timings_table.Event(:) == 'fixation_outcome_after');
beh(block).response  = timings_table.new_times(timings_table.Event(:) == 'response');
beh(block).termination  = timings_table.new_times(timings_table.Event(:) == 'termination');

%% Prepare for next block

%write down current length of original data so this can be accounted for in
%next block
trig_time_length = length(user.triggertime);
cue_pre_length = length(user.cue_pres);
response_length = length(user.response);
block_inst_length = length(user.blockInstruction);
outcome_length = length(user.outcome);
termination_length = length(user.termination);
fix_outcome_after_length = length(user.log(:,24));
fix_before_outcome_length = length(user.log(:,22));
fix_between_cue_length = length(user.log(:,20));

end % block loop ends

%% save data
save([num2str(subject) 'onsets_struct.mat'], "beh");
disp(['Saved struct for' num2str(subject)]);
end %subject loop ends


