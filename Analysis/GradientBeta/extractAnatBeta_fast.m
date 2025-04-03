% function [Betas,ROI_xyz,maskMNI] = extractAnatBeta(Mask_file,MT_file)
%
% Tobias Hauser, 23.09.2013/27.02.2014/05.03.14/02.12.15
%
function [Betas,maskXYZ,maskMNI] = extractAnatBeta_fast(Mask_file,MT_file)

curr_dir = pwd;


% load mask
ROI = spm_vol(Mask_file);
[ROI_dat,XYZ] = spm_read_vols(ROI,0);
ROI_xyz = XYZ(:,find(ROI_dat > 0));    % mm space


% extract betas
fprintf(['extracting data... ']);
con_tmp = spm_vol(MT_file);

xyz_tmp = con_tmp.mat\[ROI_xyz;ones(1,length(ROI_xyz))];
Betas = spm_sample_vol(con_tmp,xyz_tmp(1,:),xyz_tmp(2,:),xyz_tmp(3,:),0);
maskXYZ = xyz_tmp(1:3,:)';
maskMNI = ROI_xyz';

% average over voxels
% meanBeta = nanmean(betas);


cd(curr_dir);

fprintf('done.\n');
end
