%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create Gradient figure
% 
% K.Kadri 2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


matlabbatch{1}.spm.util.imcalc.input = {
                                        'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii,1'
                                        'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\prob_choice.nii,1'
                                        % 'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\toteminus.nii,1'
                                        'C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\trial_no.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'P_choice_imcalc';
matlabbatch{1}.spm.util.imcalc.outdir = {'D:\InformationGatheringMRI\derivatives\Analysis\TreasHunt_gradient'};
matlabbatch{1}.spm.util.imcalc.expression = '(abs(i1) > abs(i2) & abs(i1) > abs(i3)) * 1 + (abs(i2) > abs(i1) & abs(i2) > abs(i3)) * 2 + (abs(i3) > abs(i1) & abs(i3) > abs(i2)) * 3';

% matlabbatch{1}.spm.util.imcalc.expression = '(abs(i1) >= abs(i2) & abs(i1) >= abs(i3) & abs(i1) >= abs(i4)) * 1 +  (abs(i2) > abs(i1) & abs(i2) >= abs(i3) & abs(i2) >= abs(i4)) * 2 +  (abs(i3) > abs(i1) & abs(i3) > abs(i2) & abs(i3) >= abs(i4)) * 3 +  (abs(i4) > abs(i1) & abs(i4) > abs(i2) & abs(i4) > abs(i3)) * 4';


matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

    spm_jobman('run',matlabbatch(1));    



    %%
    % Load NIfTI volumes
nii1 = niftiread('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii');
nii2 = niftiread('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\prob_choice.nii');

% nii2 = niftiread('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\toteminus.nii');
nii3 = niftiread('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\trial_no.nii');

% Convert to double for safety
nii1 = double(nii1);
nii2 = double(nii2);
nii3 = double(nii3);

% Initialize output volume
% Initialize label map with zeros
label = zeros(size(nii1));

% Loop through voxels
for x = 1:size(nii1,1)
    for y = 1:size(nii1,2)
        for z = 1:size(nii1,3)

            v1 = abs(nii1(x,y,z));
            v2 = abs(nii2(x,y,z));
            v3 = abs(nii3(x,y,z));

            if v1 > v2 && v1 > v3
                label(x,y,z) = 1;
            elseif v2 > v1 && v2 > v3
                label(x,y,z) = 2;
            elseif v3 > v1 && v3 > v2
                label(x,y,z) = 3;
            else
                label(x,y,z) = 0; % tie or all equal
            end
        end
    end
end

V = spm_vol('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii');  % get header of nii1
V.fname = 'D:\InformationGatheringMRI\derivatives\Analysis\TreasHunt_gradient\P_choice_spm.nii';  % output file
spm_write_vol(V, label);  % write the label volume
% Save result as NIfTI (using nii1 header)


%% niftiwrite
info = niftiinfo('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii');
outFile = 'D:\InformationGatheringMRI\derivatives\Analysis\TreasHunt_gradient\P_choice_nifti.nii';
assert(isequal(size(label), info.ImageSize), ...
    'Size mismatch: label is %s, header expects %s', ...
    mat2str(size(label)), mat2str(info.ImageSize));


% Cast label to the header datatype
switch info.Datatype
    case 'uint8',  dataToWrite = uint8(label);
    case 'int16',  dataToWrite = int16(label);
    case 'int32',  dataToWrite = int32(label);
    case 'single', dataToWrite = single(label);
    case 'double', dataToWrite = double(label);
    otherwise,     dataToWrite = cast(label, info.Datatype);
end


% Save the label map with MNI orientation preserved
niftiwrite(dataToWrite, outFile, info, 'Compressed', false);


%% Abs
nii_all = cat(4, nii1, nii2, nii3);

% Compute mean of absolute beta per ROI and contrast (no normalization)
nROI = 3;
nMaps = 3;
mean_abs_beta = zeros(nROI, nMaps);
sem_abs_beta  = zeros(nROI, nMaps);  % standard error

for r = 1:nROI
    roi_mask = (label == r);
    for m = 1:nMaps
        roi_values = nii_all(:,:,:,m);
        roi_voxels = abs(roi_values(roi_mask));
        mean_abs_beta(r,m) = mean(abs(roi_values(roi_mask)), 'omitnan');
        sem_abs_beta(r,m)  = std(abs(roi_values(roi_mask)), 'omitnan');

    end
end
% --- Plot grouped bar plot with error bars ---
figure('Color','white');
h = bar(mean_abs_beta); % demeaned for visualization
hold on;

% Color bars by contrast
bar_colors = [
    1 0 1;    % dev → pink
    0 1 0;    % prob_choice → green
    1 0 0];   % trial_no → red
for m = 1:length(h)
    h(m).FaceColor = bar_colors(m,:);
end

% Add error bars
ngroups = nROI;
nbars = nMaps;
groupwidth = min(0.8, nbars/(nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth/(2*nbars);
    errorbar(x, mean_abs_beta(:,i), sem_abs_beta(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1);
end

% X-axis labels and colors
roi_colors = [
    1 0 1;  % ROI1
    0 1 0;  % ROI2
    1 0 0]; % ROI3

roi_labels = {'Pink','Green','Red'};
xticks(1:nROI);
xticklabels(roi_labels);
xtickangle(45);
ax = gca;
ax.FontSize = 18;  % tick labels font size
for i = 1:length(roi_labels)
    ax.XAxis.TickLabel{i} = ['\color[rgb]{' num2str(roi_colors(i,1)) ',' ...
                              num2str(roi_colors(i,2)) ',' num2str(roi_colors(i,3)) '}' roi_labels{i}];
end

% Legend and axis labels
lgd = legend({'\DeltaES', 'DCS', 'Urgency Signal'}, 'Location', 'northoutside','Orientation','horizontal');
lgd.FontSize = 18;
ylim([8 12.5])
ylabel('Mean |Beta|','FontSize',18);
xlabel('ROI','FontSize',18);

% Remove title
% title('Mean Absolute Beta Values by ROI and Contrast');

box off;
hold off;

%% Rigth
roi_folder = 'D:\InformationGatheringMRI\derivatives\Analysis\TreasHunt_gradient\ROIR';
beta_maps = cat(4, nii1, nii2, nii3); % already loaded
nMaps = size(beta_maps, 4);
trial_no = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed';
probchoice = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed';
dev = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';


% List of ROI files
roi_files_struct = dir(fullfile(roi_folder, 'ROI*.nii'));
roi_files = fullfile({roi_files_struct.folder}, {roi_files_struct.name});
nROI = length(roi_files);




% Preallocate mean absolute beta matrix
mean_abs_beta = zeros(nROI, nMaps);
% sem_abs_beta  = zeros(nROI, nMaps);  % standard error

% Loop over ROIs
for r = 1:nROI
    % Load ROI header
    Vroi = spm_vol(roi_files{r});

    % Use first beta map as reference
    Vbeta = spm_vol('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii'); % we just need header info for dimensions
    Vbeta.fname = 'temp_beta.nii';
    % Actually, we will match sizes manually using reslice in memory

    % Reslice ROI to beta map dimensions
    % Create a template of beta map size
    beta_size = size(beta_maps(:,:,:,1));
    roi_data = niftiread(roi_files{r});
    
    % Resample ROI to beta map size using nearest neighbor (binary)
    roi_resliced = imresize3(roi_data, beta_size, 'nearest'); 
    roi_mask = roi_resliced > 0;


  % --- Compute ROI center and radius in MNI space ---
    [x, y, z] = ind2sub(size(roi_mask), find(roi_mask)); % voxel indices

    % Convert all voxel coordinates to MNI (mm) using affine matrix
    coords_vox = [x y z ones(numel(x),1)]';
    coords_mni = Vroi.mat * coords_vox;
    coords_mni = coords_mni(1:3, :)';  % keep only x,y,z

    % Center (mean of all voxel coordinates)
    center_mni = mean(coords_mni, 1);
    roi_centers_mni(r, :) = center_mni;

    % Radius = mean Euclidean distance (mm) from center to all voxels
    dists = sqrt(sum((coords_mni - center_mni).^2, 2));
    roi_radii_mm(r) = mean(dists);


    % Loop over beta maps
    for m = 1:nMaps
        beta_values = beta_maps(:,:,:,m);
        mean_abs_beta(r,m) = mean(abs(beta_values(roi_mask)), 'omitnan');
        % sem_abs_beta(r,m)  = std(abs(roi_values(roi_mask)), 'omitnan');

    end
end

trial_no = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed';
probchoice = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed';
dev = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';


% List of ROI files
roi_files_struct = dir(fullfile(roi_folder, 'rROI*.nii'));
roi_files = fullfile({roi_files_struct.folder}, {roi_files_struct.name});
nROI = length(roi_files);

% List of participant beta masks
% Trial number
trial_2nd_level = 'D:\InformationGatheringMRI\2ndL\trialNum_unsmoothed\trial_num';
trial_1st = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed\';
%DEV
deltaev_2nd = 'D:\InformationGatheringMRI\2ndL\deltaEV_unsmoothed\daEV';
deltaev_1st = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';
%Prob_choice
prob_choice_2nd = 'D:\InformationGatheringMRI\2ndL\probchoice_unsmoothed\prob_choice';
prob_choice_1st = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed\';

for r = 1:nROI


[maskBetas, ~, ~, ~] = extractMaskBetas_fast(char(roi_files(r)),deltaev_2nd,deltaev_1st,0);
sem_abs_beta(r,1) = std(nanmean(maskBetas,2));


[maskBetas, maskXYZ, ~, ~] = extractMaskBetas_fast(char(roi_files(r)),prob_choice_2nd,prob_choice_1st,0);
sem_abs_beta(r,2) = std(nanmean(maskBetas,2));

[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(char(roi_files(r)),trial_no_beta,trial_1st,0);
sem_abs_beta(r,3) = std(nanmean(maskBetas,2));

end



%Plot
figure('Color','white')
% Bar plot (optional demeaning for visualization)
% h = bar(mean_abs_beta - mean(mean(mean_abs_beta))); % grouped bar
% h = bar(mean_abs_beta ); % grouped bar
h = bar(mean_abs_beta ); % demeaned for visualization

% Color bars by contrast
bar_colors = [...
    1 0 1;    % dev → pink
    0 1 0;    % prob_choice → green
    1 0 0];   % trial_no → red

for m = 1:length(h)
    h(m).FaceColor = bar_colors(m,:);
end
hold on
% Add error bars
ngroups = nROI;
nbars = nMaps;
groupwidth = min(0.8, nbars/(nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth/(2*nbars);
    errorbar(x, mean_abs_beta(:,i), sem_abs_beta(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1);
end
% X-axis labels
roi_labels = {'ROI-1','ROI-2','ROI-3','ROI-4','ROI5-','ROI-6','ROI-7','ROI-8'};
xticks(1:8);
xticklabels(roi_labels);
xtickangle(45);

% Color x-axis labels by ROI group
% ROIs 1-3 red, 4-6 green, 7-8 pink
roi_colors = [...
    1 0 0;  % ROI1
    1 0 0;  % ROI2
    1 0 0;  % ROI3
    0 1 0;  % ROI4
    0 1 0;  % ROI5
    0 1 0;  % ROI6
    1 0 1;  % ROI7
    1 0 1]; % ROI8

ax = gca;
for i = 1:length(roi_labels)
    ax.XAxis.TickLabel{i} = ['\color[rgb]{' num2str(roi_colors(i,1)) ',' ...
                              num2str(roi_colors(i,2)) ',' num2str(roi_colors(i,3)) '}' roi_labels{i}];
end
ylim([8 14])
% Add legend, labels, title
% legend({'\DeltaES', 'DCS', 'Urgency Signal'}, 'Location','northoutside','Orientation','horizontal');
ylabel('Mean |Beta|');
xlabel('ROI');
% title('Mean Absolute Beta Values by ROI and Contrast');
box off;



%% Check ROI centroids
% Loop over ROIs
for r = 1:nROI
    % Load ROI header
    Vroi = spm_vol(roi_files{r});

    % Reference image (functional, already in MNI space)
    Vbeta = spm_vol('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii');

    % Reslice ROI to match beta map grid (like MarsBaR does)
    flags = struct('interp', 0, 'mean', false, 'which', 1, 'wrap', [0 0 0], 'mask', false);
    spm_reslice({Vbeta.fname, roi_files{r}}, flags);
    [~, roi_name, ~] = fileparts(roi_files{r});
    resliced_fname = fullfile(fileparts(roi_files{r}), ['r' roi_name '.nii']);

    % Load resliced ROI
    Vroi_resliced = spm_vol(resliced_fname);
    roi_data = spm_read_vols(Vroi_resliced);
    roi_mask = roi_data > 0;

    % --- Compute ROI center and radius in MNI space ---
    [x, y, z] = ind2sub(size(roi_mask), find(roi_mask)); % voxel indices
    coords_vox = [x y z ones(numel(x),1)]';
    coords_mni = Vroi_resliced.mat * coords_vox; % convert to MNI mm
    coords_mni = coords_mni(1:3, :)';

    % Center (mean of all voxel coordinates)
    center_mni = mean(coords_mni, 1);
    roi_centers_mni(r, :) = center_mni;

    % Radius = mean Euclidean distance (mm) from center to all voxels
    dists = sqrt(sum((coords_mni - center_mni).^2, 2));
    roi_radii_mm(r) = mean(dists);

    % --- MarsBaR-style centroid (mass center in resliced space) ---
    % MarsBaR uses SPM’s spm_ROI_center-of-mass logic, i.e. world center of ROI mask.
    % Equivalent to:
    [x_mm, y_mm, z_mm] = ind2sub(size(roi_mask), find(roi_mask));
    coords_all = [x_mm, y_mm, z_mm, ones(numel(x_mm),1)] * Vroi_resliced.mat';
    marsbar_center = mean(coords_all(:,1:3), 1);

    % Diagnostic printout
    fprintf('\nROI: %s\n', roi_name);
    fprintf('  Your MNI center (resliced):  [%.2f %.2f %.2f]\n', center_mni);
    fprintf('  MarsBaR-like center (MNI):   [%.2f %.2f %.2f]\n', marsbar_center);
    fprintf('  Difference (mm):             [%.2f %.2f %.2f]\n', abs(center_mni - marsbar_center));

    % --- Compute mean absolute beta values ---
    for m = 1:nMaps
        beta_values = beta_maps(:,:,:,m);
        mean_abs_beta(r,m) = mean(abs(beta_values(roi_mask)), 'omitnan');
    end
end


%% Left


% Loop over ROIs
for r = 1:nROI
    % Load ROI header
    Vroi = spm_vol(roi_files{r});

    % Reference image (functional, already in MNI space)
    Vbeta = spm_vol('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii');

    % Reslice ROI to match beta map grid (like MarsBaR does)
    flags = struct('interp', 0, 'mean', false, 'which', 1, 'wrap', [0 0 0], 'mask', false);
    spm_reslice({Vbeta.fname, roi_files{r}}, flags);
    [~, roi_name, ~] = fileparts(roi_files{r});
    resliced_fname = fullfile(fileparts(roi_files{r}), ['r' roi_name '.nii']);

    % Load resliced ROI
    Vroi_resliced = spm_vol(resliced_fname);
    roi_data = spm_read_vols(Vroi_resliced);
    roi_mask = roi_data > 0;

    % --- Compute ROI center and radius in MNI space ---
    [x, y, z] = ind2sub(size(roi_mask), find(roi_mask)); % voxel indices
    coords_vox = [x y z ones(numel(x),1)]';
    coords_mni = Vroi_resliced.mat * coords_vox; % convert to MNI mm
    coords_mni = coords_mni(1:3, :)';

    % Center (mean of all voxel coordinates)
    center_mni = mean(coords_mni, 1);
    roi_centers_mni(r, :) = center_mni;

    % Radius = mean Euclidean distance (mm) from center to all voxels
    dists = sqrt(sum((coords_mni - center_mni).^2, 2));
    roi_radii_mm(r) = mean(dists);

    % --- MarsBaR-style centroid (mass center in resliced space) ---
    % MarsBaR uses SPM’s spm_ROI_center-of-mass logic, i.e. world center of ROI mask.
    % Equivalent to:
    [x_mm, y_mm, z_mm] = ind2sub(size(roi_mask), find(roi_mask));
    coords_all = [x_mm, y_mm, z_mm, ones(numel(x_mm),1)] * Vroi_resliced.mat';
    marsbar_center = mean(coords_all(:,1:3), 1);

    % Diagnostic printout
    fprintf('\nROI: %s\n', roi_name);
    fprintf('  Your MNI center (resliced):  [%.2f %.2f %.2f]\n', center_mni);
    fprintf('  MarsBaR-like center (MNI):   [%.2f %.2f %.2f]\n', marsbar_center);
    fprintf('  Difference (mm):             [%.2f %.2f %.2f]\n', abs(center_mni - marsbar_center));

    % --- Compute mean absolute beta values ---
    for m = 1:nMaps
        beta_values = beta_maps(:,:,:,m);
        mean_abs_beta(r,m) = mean(abs(beta_values(roi_mask)), 'omitnan');
    end
end


%%
roi_folder = 'D:\InformationGatheringMRI\derivatives\Analysis\TreasHunt_gradient\ROIs';
beta_maps = cat(4, nii1, nii2, nii3); % already loaded
nMaps = size(beta_maps, 4);
trial_no = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed';
probchoice = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed';
dev = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';


% List of ROI files
roi_files_struct = dir(fullfile(roi_folder, 'rROI*.nii'));
roi_files = fullfile({roi_files_struct.folder}, {roi_files_struct.name});
nROI = length(roi_files);




% Preallocate mean absolute beta matrix
mean_abs_beta = zeros(nROI, nMaps);
% sem_abs_beta  = zeros(nROI, nMaps);  % standard error

% Loop over ROIs
for r = 1:nROI
    % Load ROI header
    Vroi = spm_vol(roi_files{r});

    % Use first beta map as reference
    Vbeta = spm_vol('C:\Users\Kenza Kedri\Documents\GitHub\TrHuMRI\Analysis\GradientBeta\dev.nii'); % we just need header info for dimensions
    Vbeta.fname = 'temp_beta.nii';
    % Actually, we will match sizes manually using reslice in memory

    % Reslice ROI to beta map dimensions
    % Create a template of beta map size
    beta_size = size(beta_maps(:,:,:,1));
    roi_data = niftiread(roi_files{r});
    
    % Resample ROI to beta map size using nearest neighbor (binary)
    roi_resliced = imresize3(roi_data, beta_size, 'nearest'); 
    roi_mask = roi_resliced > 0;


  % --- Compute ROI center and radius in MNI space ---
    [x, y, z] = ind2sub(size(roi_mask), find(roi_mask)); % voxel indices

    % Convert all voxel coordinates to MNI (mm) using affine matrix
    coords_vox = [x y z ones(numel(x),1)]';
    coords_mni = Vroi.mat * coords_vox;
    coords_mni = coords_mni(1:3, :)';  % keep only x,y,z

    % Center (mean of all voxel coordinates)
    center_mni = mean(coords_mni, 1);
    roi_centers_mni(r, :) = center_mni;

    % Radius = mean Euclidean distance (mm) from center to all voxels
    dists = sqrt(sum((coords_mni - center_mni).^2, 2));
    roi_radii_mm(r) = mean(dists);


    % Loop over beta maps
    for m = 1:nMaps
        beta_values = beta_maps(:,:,:,m);
        mean_abs_beta(r,m) = mean(abs(beta_values(roi_mask)), 'omitnan');
        % sem_abs_beta(r,m)  = std(abs(roi_values(roi_mask)), 'omitnan');

    end
end

trial_no = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed';
probchoice = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed';
dev = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';


% List of ROI files
roi_files_struct = dir(fullfile(roi_folder, 'rROI*.nii'));
roi_files = fullfile({roi_files_struct.folder}, {roi_files_struct.name});
nROI = length(roi_files);

% List of participant beta masks
% Trial number
trial_2nd_level = 'D:\InformationGatheringMRI\2ndL\trialNum_unsmoothed\trial_num';
trial_1st = 'D:\InformationGatheringMRI\1stL\trialNum_unsmoothed\';
%DEV
deltaev_2nd = 'D:\InformationGatheringMRI\2ndL\deltaEV_unsmoothed\daEV';
deltaev_1st = 'D:\InformationGatheringMRI\1stL\deltaEV_unsmoothed';
%Prob_choice
prob_choice_2nd = 'D:\InformationGatheringMRI\2ndL\probchoice_unsmoothed\prob_choice';
prob_choice_1st = 'D:\InformationGatheringMRI\1stL\probchoice_unsmoothed\';

for r = 1:nROI


[maskBetas, ~, ~, ~] = extractMaskBetas_fast(char(roi_files(r)),deltaev_2nd,deltaev_1st,0);
sem_abs_beta(r,1) = std(nanmean(maskBetas,2));


[maskBetas, maskXYZ, ~, ~] = extractMaskBetas_fast(char(roi_files(r)),prob_choice_2nd,prob_choice_1st,0);
sem_abs_beta(r,2) = std(nanmean(maskBetas,2));

[maskBetas, maskXYZ, maskMNI, subjects] = extractMaskBetas_fast(char(roi_files(r)),trial_2nd_level,trial_1st,0);
sem_abs_beta(r,3) = std(nanmean(maskBetas,2));

end



%Plot
figure('Color','white')
% Bar plot (optional demeaning for visualization)
% h = bar(mean_abs_beta - mean(mean(mean_abs_beta))); % grouped bar
% h = bar(mean_abs_beta ); % grouped bar
h = bar(mean_abs_beta ); % demeaned for visualization

% Color bars by contrast
bar_colors = [...
    1 0 1;    % dev → pink
    0 1 0;    % prob_choice → green
    1 0 0];   % trial_no → red

for m = 1:length(h)
    h(m).FaceColor = bar_colors(m,:);
end
hold on
% Add error bars
ngroups = nROI;
nbars = nMaps;
groupwidth = min(0.8, nbars/(nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth/(2*nbars);
    errorbar(x, mean_abs_beta(:,i), sem_abs_beta(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1);
end
% X-axis labels
roi_labels = {'ROI-1','ROI-2','ROI-3','ROI-4','ROI5-','ROI-6','ROI-7','ROI-8'};
xticks(1:8);
xticklabels(roi_labels);
xtickangle(45);

% Color x-axis labels by ROI group
% ROIs 1-3 red, 4-6 green, 7-8 pink
roi_colors = [...
    1 0 0;  % ROI1
    1 0 0;  % ROI2
    1 0 0;  % ROI3
    0 1 0;  % ROI4
    0 1 0;  % ROI5
    0 1 0;  % ROI6
    1 0 1;  % ROI7
    1 0 1]; % ROI8

ax = gca;
for i = 1:length(roi_labels)
    ax.XAxis.TickLabel{i} = ['\color[rgb]{' num2str(roi_colors(i,1)) ',' ...
                              num2str(roi_colors(i,2)) ',' num2str(roi_colors(i,3)) '}' roi_labels{i}];
end
ylim([6 13])
% Add legend, labels, title
% legend({'\DeltaES', 'DCS', 'Urgency Signal'}, 'Location','northoutside','Orientation','horizontal');
ylabel('Mean |Beta|');
xlabel('ROI');
% title('Mean Absolute Beta Values by ROI and Contrast');
box off;

