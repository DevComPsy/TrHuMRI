clear all; close all; clc
% to extract volume of interest for total ev minus for PPI analyses

addpath(genpath('D:\BE Code\gen_funct-master'));
%MRI toolbox
addpath(genpath('D:\Observational Study\Information_gathering-main\MRI-master'))
addSPM();
spm('defaults', 'fmri');
spm_jobman('initcfg');

%get participant IDs
%tmp = dir(['D:\DATA\EffortLearning\data\mainstudy\7*']);
tmp = dir(['D:\Observational Study\Information_gathering-main\Analysis\new\1stL\big_model_with_totev\']);
sl = [];
for s = 1:length(tmp)
    try
        sl = [sl str2num(tmp(s).name)];
    end
end

SPM_dir = 'D:\Observational Study\Information_gathering-main\Analysis\new\1stL\big_model_with_totev\';
rois = '4_dmpfc.nii';
        % [-2 17 57; -14 8 -3; 11 12 -2];
        % {'10_daE_dmPFC_-2_17_57.nii','10_lVS_-14_8_-3.nii','10_rVS_11_12_-2.nii'};
        % {'bil Accumbens_mask_10.img','bil Accumbens_mask_50.img','bil Accumbens_mask_80.img','sm2mmvenstr.img','VentralStriatum_L.nii','VentralStriatum_R.nii'}
        % [-3 -14 -15; -3 15 59; -11 9 -2; 11 11 0; -9 -26 -12];
        %{'09_daE_dmPFC_-3_15_59','09_daR_lVS_-14_8_-2','09_daR_rVS_11_11_0','2015_10_20_SNVTA'}; %{'09_outcome_V1_9_-65_33'};  %
 roi_size = 6;
 eoi = 7; % effect of interest, in this case: total ev minus
roi_dir = 'D:\Observational Study\Information_gathering-main\Analysis\rois\';

for s = 1:length(sl)
    disp(int2str(sl(s)))
    %for r = 1:length(rois)
%         extractVOI([SPM_dir int2str(sl(s)) '\'],[roi_dir rois{r} '.nii']);
          extractVOI([SPM_dir int2str(sl(s)) '\'],[roi_dir rois],roi_size, eoi);
       % extractVOI([SPM_dir int2str(sl(s)) '\'],[roi_dir rois{r}]);
    %end


    %% move VOIs to subject folder
out_dir = [SPM_dir int2str(sl(s)) '\' 'VOI\'];
mkdir(out_dir);
try
    movefile([roi_dir 'VOI*'],out_dir);
catch
    warning(['not able to move Files']);
end

end