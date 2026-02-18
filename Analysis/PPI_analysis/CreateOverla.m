% Paths to your input images



img1_path = 'D:\InformationGatheringMRI\2_ppi_totev_4_dmpfc\2_ppi_totev_4_dmpfc\Interaction\spmT_0002.nii';
img2_path = 'D:\InformationGatheringMRI\derivatives\Analysis\Analysis\2ndL\01\daEV\spmT_0001.nii';
out_path  = 'D:\InformationGatheringMRI\overlap_sum.nii';

% Read images
V1 = spm_vol(img1_path);
V2 = spm_vol(img2_path);

data1 = spm_read_vols(V1);
data2 = spm_read_vols(V2);

% Create overlap mask
overlap_mask = (data1 ~= 0) & (data2 ~= 0);

% Initialize output
out_data = zeros(size(data1));

% Sum values where both overlap
out_data(overlap_mask) = data1(overlap_mask) + data2(overlap_mask);

% Save result
V_out = V1;                  % use header of first image
V_out.fname = out_path;      % set output path
spm_write_vol(V_out, out_data);
