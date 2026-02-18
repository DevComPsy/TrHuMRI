%loop to run all subjects for 1st level MRI analysis 

clc; close all; clear;

%change this to your path
data_path = 'D:\InformationGatheringMRI\derivatives\';
addpath(genpath('C:\Users\Kenza Kedri\Documents\GitHub\gen_funct'));
% addpath(genpath('D:\Observational Study\Information_gathering-main\Analysis'));

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
ID = [];
for i = 29:length(files)
    %subject loop begins
    subject = str2double(regexp(files(i).name, '\d+', 'match'));
  
     %make sure we're in correct subject's func folder
    mri_dir = [data_path 'sub-' num2str(subject)  '\' ];
    cd(mri_dir);
    
    % load mri file 
    pattern = [num2str(subject) '.mat'];

    % Search for the file that matches the pattern
    fileInfo = dir(pattern);

    load(fileInfo(1).name);

    %run 1st level analysis function
    try 
        TrHu_1stL_02(mri); %for more predictors
    catch
        ID(end+1) = subject;
    end
    %TrHu_1stL_01_oneReg(mri); %for one predictor
    %TrHu_1stL_mask(mri); %with snvta mask

    disp(['Subject' num2str(subject) ':finished.'])
end 