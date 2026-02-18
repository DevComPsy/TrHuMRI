function [outfile] = write_ROIvoxels2vol(data,MNI,outfile,dummy_vol)

if nargin < 4
    dummy_vol = 'C:\Users\Kenza Kedri\Documents\MATLAB\spm12\canonical\single_subj_T1.nii';
end

if nargin < 3
    outfile = [pwd '\outfile.nii'];
end

if length(data) ~= length(MNI)
    error('datapoints in data must match number of MNI voxels')
end

if size(MNI,2) ~= 3
    MNI = MNI';
end

%% load dummy volume
V = spm_vol(dummy_vol);
[V_dat,V_XYZ] = spm_read_vols(V,0);

%% create new file
W = V;
try
    W = rmfield(W,'pinfo');
end
W.fname = outfile;
data = mean(data)+10;
%% fill in data
Y = V_dat;
Y(:) = nan;
for i = 1:length(data)
    idx = find(V_XYZ(1,:)==MNI(i,1) & V_XYZ(2,:)==MNI(i,2) & V_XYZ(3,:)==MNI(i,3));
    Y(idx) = data(i);
end

outfile = spm_write_vol_no_rescale(W,Y);