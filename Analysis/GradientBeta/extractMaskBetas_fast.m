% function [maskBetas, subjects] = extractMaskBetas_fast(SPM_dir,Mask_file)
%
% extracts all beta values of a mask image for a given contrast.
%
% IN:
% @SPM_dir: string of directory containing SPM.mat file of the 2nd-level contrast.
%
% @Mask_file: string of the name and location of the mask/ROI ('*.img')
%
% OUT:
% @maskBetas: matrix containing betas for each voxel of mask for each subject
%
% @maskXYZ: matrix with XYZ coordinates of each voxel (image space)
%
% @maskMNI: matrix with XYZ coordinates of each voxel (MNI space)
%
% @subjects: list with subjects from which data was derived
%
% Tobias Hauser, 02.12.15
%
function [maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(Mask_file,SPM_dir,verbose)

if nargin < 3
    verbose = 1;
end
if nargin < 2
    SPM_dir = [spm_select(1,'dir','select 2ndL contrast') '\'];
end
if nargin < 1
    Mask_file = spm_select(1,'image','select mask');
end

curr_dir = pwd;

% load SPM
load([SPM_dir 'SPM.mat']);

% load mask
ROI = spm_vol(Mask_file);
[ROI_dat,XYZ] = spm_read_vols(ROI,0);
ROI_xyz = XYZ(:,find(ROI_dat > 0));    % mm space

% find beta-files
con_files = SPM.xY.P;
con_num = length(con_files);


% extract betas
betas = [];
subjects = [];
spm('CreateIntWin','on'); spm_progress_bar('Clear'); spm_progress_bar('Init',con_num,'subject','data extraction');
display(['extracting data...']);
for s=1:con_num
    [pathstr, ~, ~] =fileparts(SPM.xY.P{s});
    [selected_outputs] = regexp(pathstr,'\','split');
    try
        subjects(s) = str2num(selected_outputs{end});
    catch
        warning('extracting subject number from path does not work.')
    end
    con_tmp = spm_vol(con_files{s});
    xyz_tmp = con_tmp.mat\[ROI_xyz;ones(1,length(ROI_xyz))];
    maskBetas(s,:) = spm_sample_vol(con_tmp,xyz_tmp(1,:),xyz_tmp(2,:),xyz_tmp(3,:),0);
    maskXYZ(s,:,:) = xyz_tmp(1:3,:);
    maskMNI(s,:,:) = ROI_xyz;
    spm_progress_bar('Set', s);
end
spm_progress_bar('clear');

% average voxels
maskXYZ = squeeze(mean(maskXYZ,1));
maskMNI = squeeze(mean(maskMNI,1));

cd(curr_dir);

display('done');

if verbose
    plot_ROIvoxels(squeeze(nanmean(maskBetas))',maskXYZ')
end

end
