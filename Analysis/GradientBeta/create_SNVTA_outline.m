% ROI = spm_vol('C:\data\EffortLearning\results\mainstudy\MRI\2ndL\2015_10_20_SNVTA.nii');
ROI = spm_vol('./SNVTA_regressions/NSPN/roi_num_1.nii');
[ROI_dat,XYZ] = spm_read_vols(ROI,0);

%%
 ROI_dat = round(ROI_dat);
% ROI_dat = round(ROI_dat ./255);
out = nan(size(ROI_dat,1),size(ROI_dat,2),size(ROI_dat,3));
for x = 2:size(ROI_dat,1)-1
    for y = 2:size(ROI_dat,2)-1
        for z=2:size(ROI_dat,3)-1
            if ROI_dat(x,y,z) == 1
                if sum(sum(sum(ROI_dat(x-1:x+1,y-1:y+1,z-1:z+1)))) < numel(ROI_dat(x-1:x+1,y-1:y+1,z-1:z+1))
%                  if (ROI_dat(x-1,y,z) ~=1 || ROI_dat(x+1,y,z) ~=1) || (ROI_dat(x,y-1,z) ~=1 || ROI_dat(x,y+1,z) ~=1) || (ROI_dat(x,y,z-1) ~=1 || ROI_dat(x,y,z+1) ~=1)
                    out(x,y,z) = 1;
                end
            end
        end
    end
end

%%

ROI = rmfield(ROI,'pinfo');
ROI.fname = ['./SNVTA_regressions/NSPN/SNVTA_outline_wz.nii'];

spm_write_vol_no_rescale(ROI,out);