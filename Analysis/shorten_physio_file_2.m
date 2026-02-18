%% Script to shorten physio regressor files

clc; close all; clear;

%change this to your path
data_path = 'D:\InformationGatheringMRI\derivatives\';
% addpath(genpath('D:\BE Code\gen_funct-master'));
addpath(genpath('D:\InformationGatheringMRI\derivatives\'));

%get foldernames
files1 = dir(data_path);

% Filter out items that are not directories and ensure names start with 'sub-' followed by digits only
isDir = [files1.isdir];
names = {files1(isDir).name};
matches = regexp(names, '^sub-\d+$', 'match');

% Create a logical array where each entry is true if a match was found for the entire name
bool = cellfun(@(x) ~isempty(x), matches);

% Filter the original list to keep only participant folders with 'sub-###' format
files = files1(isDir);
files = files(bool);


for i = 1:length(files)
    %subject loop begins
    subject = str2double(regexp(files(i).name, '\d+', 'match'));
  
     %make sure we're in correct subject's func folder
    mri_dir = [data_path 'sub-' num2str(subject)  '\' ];
    cd(mri_dir);
    
    for b = 1:4

       % get paths to movement regressors
        path_to_move_params{b} =  {['D:\InformationGatheringMRI\derivatives\sub-' num2str(subject)...
        '\physio\multiple_regressors-run' num2str(b) '.txt']};
        
        %read in movement parameter regressor
        ori_file = readmatrix(char(path_to_move_params{b}));

        %cut file only up to column 24
        cut_file = ori_file(:, 1:24);
        
        % Save to .txt file
        filename = ['D:\InformationGatheringMRI\derivatives\sub-' num2str(subject)...
        '\physio\multiple_regressors_new-run' num2str(b) '.txt'];
        writematrix(cut_file, filename, 'Delimiter', '\t');

    end 



end 