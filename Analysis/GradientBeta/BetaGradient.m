%-----------------------------------------------------------------------
% Gradient of beta's within a mask
% 
% K. Kadri, AM Marzuki, 2025
%-----------------------------------------------------------------------
Inputpath = 'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta';
cd(Inputpath)

Mask = 'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta/raal_frontal_mask.nii';

%% Trial number

trial_no_beta = 'D:\InformationGatheringMRI\2ndL\trialNum_unsmoothed\trial_num';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed\';

% [meanBetas, subjects] = extractMeanBetas_fast(Mask,trial_no_beta,Optional_path_1stLevel);
[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,trial_no_beta,Optional_path_1stLevel,0);
% dummyvol = 'D:\InformationGatheringMRI\2ndL\deltaEV_unsmoothed\daEV/spmT_0001.nii';
% namefile =  [pwd '\trial_no.nii'];
% write_ROIvoxels2vol(maskBetas,maskMNI,namefile,dummyvol)
TrialnoAvg = nanmean(maskBetas,2);
%% P-choice

prob_choice = 'D:\InformationGatheringMRI\2ndL\probchoice_unsmoothed\prob_choice';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed\';
[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,prob_choice,Optional_path_1stLevel,0);
% namefile =  [pwd '\prob_choice.nii'];
% write_ROIvoxels2vol(maskBetas,maskMNI,namefile,dummyvol)
P_choiceAvg = nanmean(maskBetas,2);
%% Dev

deltaev = 'D:\InformationGatheringMRI\2ndL\deltaEV_unsmoothed\daEV';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';
[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,deltaev,Optional_path_1stLevel,0);
% namefile =  [pwd '\dev.nii'];
% write_ROIvoxels2vol(maskBetas,maskMNI,namefile,dummyvol)
% 
DevAvg = nanmean(maskBetas,2);
%% Toteminus
toteminus = 'D:\InformationGatheringMRI\2ndL\totevminus_unsmoothed\totevminus';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\1stL\totevminus_unsmoothed';
[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,deltaev,Optional_path_1stLevel,0);
namefile =  [pwd '\toteminus.nii'];
write_ROIvoxels2vol(maskBetas,maskMNI,namefile,dummyvol)

%% Plot T-value
Avg = [P_choiceAvg TrialnoAvg DevAvg]
m = mean(Avg);
figure;
b = bar(m);

% Set x-axis ticks and labels
xticks(1:length(m));                  % positions of bars
xticklabels({'Pchoice','Trial no','DEV'});          % labels under each bar

% Optional: add y-label and title
ylabel('Mean Beta');
title('ROI Betas');

% Optional: rotate labels if needed
xtickangle(0);        