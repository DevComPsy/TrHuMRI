%-----------------------------------------------------------------------
% Gradient of beta's within a mask
% 
% K. Kadri, AM Marzuki, 2025
%-----------------------------------------------------------------------
Inputpath = 'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta';
cd(Inputpath)

Mask = 'dmpfc.nii';
trial_no_beta = 'D:\InformationGatheringMRI\derivatives\Analysis\2ndL\trial_num\12\trial_num';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\derivatives\Analysis\1stLevel\12\';

% [meanBetas, subjects] = extractMeanBetas_fast(Mask,trial_no_beta,Optional_path_1stLevel);
% [maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,trial_no_beta,Optional_path_1stLevel);

Optional_path_1stLevel = 'D:\InformationGatheringMRI\derivatives\Analysis\1stLevel\10';
prob_choice = 'D:\InformationGatheringMRI\derivatives\Analysis\2ndL\probchoice\10\prob_choice/';
% [maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,prob_choice,Optional_path_1stLevel);

deltaev = 'D:\InformationGatheringMRI\derivatives\Analysis\2ndL\dev\11\daEV/';
Optional_path_1stLevel = 'D:\InformationGatheringMRI\derivatives\Analysis\1stLevel\11';
[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask,deltaev,Optional_path_1stLevel);


