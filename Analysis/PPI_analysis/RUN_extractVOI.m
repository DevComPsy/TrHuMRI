clear all; close all; clc
spm('defaults', 'fmri');
spm_jobman('initcfg');

tmp = dir(['D:\InformationGatheringMRI\derivatives\sub-*']);
sl = [];
for s = 1:length(tmp)
    try
        sl = [sl (tmp(s).name)];
    end
end

SPM_dir = 'D:\InformationGatheringMRI\derivatives\';
rois = {'test.nii'};
        % [-2 17 57; -14 8 -3; 11 12 -2];
        % {'10_daE_dmPFC_-2_17_57.nii','10_lVS_-14_8_-3.nii','10_rVS_11_12_-2.nii'};
        % {'bil Accumbens_mask_10.img','bil Accumbens_mask_50.img','bil Accumbens_mask_80.img','sm2mmvenstr.img','VentralStriatum_L.nii','VentralStriatum_R.nii'}
        % [-3 -14 -15; -3 15 59; -11 9 -2; 11 11 0; -9 -26 -12];
        %{'09_daE_dmPFC_-3_15_59','09_daR_lVS_-14_8_-2','09_daR_rVS_11_11_0','2015_10_20_SNVTA'}; %{'09_outcome_V1_9_-65_33'};  %
% roi_size = 5;
roi_dir = 'D:\InformationGatheringMRI\derivatives\Analysis\PPI\';

for s = 1:length(sl)
    disp(int2str(sl(s)))
    for r = 1:length(rois)
%         extractVOI([SPM_dir int2str(sl(s)) '\'],[roi_dir rois{r} '.nii']);
%         extractVOI([SPM_dir int2str(sl(s)) '\'],rois(r,:),roi_size);
        extractVOI([SPM_dir int2str(sl(s)) '\'],[roi_dir rois{r}]);
    end
end