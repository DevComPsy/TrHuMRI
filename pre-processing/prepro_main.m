clear all ; close all
global param

param = load_param();

%add path
addpath 'C:\Users\Kenza Kedri\Documents\GitHub\MRI'
addpath 'C:\Users\Kenza Kedri\Documents\GitHub\TU01_RSanalysis\NaDaEL\MRI-master\MRI-master'

% mri_path = 'D:\pilot/'
cd(param.mri_path)

list = (dir('sub-*'));
list(param.exclude) = [];

for i = 21:length(list)
    ID = list(i).name(5:end); %remove sub- from subject ID

    mr = run_MRI(ID);
end