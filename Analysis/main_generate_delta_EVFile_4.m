%% To obtain behavioural files for MRI analysis

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

model_predictions = load('model_predictions.mat');
model_pred = model_predictions.model_predictions;

for i = 1:length(files)
    %subject loop begins
    subject = files(i).name;

    
    %% generate regressor function (pertinent variable is delta ev)
    beh_dir = [data_path subject '\'];
    out_dir = [data_path subject '\'];
    meg_dir = [data_path subject '\'];
    data_dir = [data_path subject '\'];

    MEG_get_beh(str2double(subject), beh_dir, meg_dir)

    generate_MdR_regressors(str2double(subject),beh_dir,out_dir)

    aggregateBEH(str2double(subject), data_dir)

    %make sure we're in correct subject folder
    beh_dir = [data_path subject '\'];
    cd(beh_dir);

    %% save regressors file to struct
      % load regressors log file 
    pattern = [num2str(subject) '_regressors.mat'];

    % Search for the file that matches the pattern
    fileInfo = dir(pattern);

    load(fileInfo(1).name);

    %load trials log file 
    pattern = ['*_' num2str(subject) '*_4_log.mat'];

    % Search for the file that matches the pattern
    fileInfo = dir(pattern);

    load(fileInfo(1).name);

    %% calculate points
    % Initialize the index array with zeros of the same length trials.trial
    % index = zeros(size(trials.trial(:,1)));
    % 
    % % identify when games end
    % for k = 2:length(trials.trial(:,1))
    %     if trials.trial(k,1) == 1
    %         index(k-1) = 1; % Set the previous element to 1 if current element is 1
    %     end
    % end
    % 
    % %ensure final row is also 1
    % index(end) = 1;
    % 
    % points = trials.trial(:,24);
    % 
    % % get points only on the last trial per game
    % trials.trial(index == 0,24) = 0;
    % points(index == 0) = 0;
    % 
    % %convert current values to points
    % points(trials.trial(:,24) == 1) = 2; %2 points added
    % points(trials.trial(:,24) == 2) = -2; %-2 points
    % points(isnan(trials.trial(:,24))) = -1;%-1 point

        points = user.log (:,4);
    %% Get when they made choice

    pattern = [num2str(subject) '_beh.mat'];

    % Search for the file that matches the pattern
    fileInfo = dir(pattern);

    load(fileInfo(1).name);

    pmat = [];
    pmat.mat    = beh.dat;
    pmat.names  = beh.descr';

    dist2ch         = get_from_mat(pmat,'distance2choice');
    
    % dep variable (choice):
    cont_ch    = NaN(1,length(dist2ch)); %initialise as NANs
    % search:
    cont_ch(find(dist2ch>0)) = 1;
    % stop:
    cont_ch(find(dist2ch==1)+1) = 0;
    cont_ch = cont_ch';

     %flip continue/stop
    cont_ch = cont_ch-1;
    cont_ch(find(cont_ch==-1)) = 1;
    
    %get block for splitting this variable
    block_for_choice = get_from_mat(pmat,'block');

    %% Get probability of choice from regression model
    current_model_pred = model_pred(model_pred(:,2)==str2num(subject));

    %% put all regressors into struct
    
    for block = 1:4
        %total ev - as regressor
        beh_regs(block).totevminus = data.totevminus(data.block==block);
        %get delta_ev as regressor
        beh_regs(block).deltaev = data.deltaev(data.block==block);
        %get trial number as regressor
        beh_regs(block).trial = data.trial(data.block == block);
        %points as regressor
        beh_regs(block).points = points(data.block == block);
        %choice
        beh_regs(block).choice = cont_ch(block_for_choice == block);
        %prob choice
        beh_regs(block).prob_choice = current_model_pred(block_for_choice == block);
    end 


    save([num2str(subject) 'beh_regs.mat'], "beh_regs");
    disp(['Saved reg struct for' num2str(subject)]);


end 
