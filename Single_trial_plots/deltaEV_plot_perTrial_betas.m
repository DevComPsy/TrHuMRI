clear all; close all; clc
addpath(genpath('D:\BE Code\gen_funct-master'));

%% To create plot 3D for delta-EV

tmp = dir(['E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\1*']);
sl = [];
for s = 1:length(tmp)
    try
        sl = [sl str2num(tmp(s).name)];
    end
end
%sl(find(sl==715)) = [];

%% DMPFC
coi = {'deltaev'};    
% ROI = 'dmPFC_dEV_sphere';
ROI = 'deltaev_leftDMPFC';
%mean_beta = 1;

% load betas
betas_dir = 'E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\';
roi = load([betas_dir 'cues_all_trials_' ROI '.mat']);

% Reshape and clean betas 

for s = 1:length(sl)
  
    meanbetas = mean(roi.df(s).maskBetas, 2); %get means of betas across all voxels

    %detrend betas
    mean_overall = mean(meanbetas);

    for k = 1:length(meanbetas) 
        meanbetas(k) = meanbetas(k) - mean_overall;
    end 
    
    %get behavioural data
    beh =  load(['E:\Information_gathering-main\Analysis\BEH\' num2str(sl(s)) '\' num2str(sl(s)) 'beh_regs.mat']);
    
    if sl(s) == 102 || sl(s) == 118
       
        beh_vertcat = vertcat(beh.beh_regs(1:3).(coi{1}));
    elseif sl(s) == 114
        beh.beh_regs(2) = [];
        beh_vertcat = vertcat(beh.beh_regs.(coi{1}));

    elseif sl(s) == 120
        beh_vertcat = vertcat(beh.beh_regs(2:4).(coi{1}));

    else

        beh_vertcat = vertcat(beh.beh_regs.(coi{1}));
    end

    %concatenate behaviour and betas
    beh_beta(s).data = horzcat(beh_vertcat, meanbetas);

    %repeat subject number
    rep_sub(s).sub = repelem(sl(s), length(meanbetas))';
end 

%make data long
beh_beta_new = vertcat(beh_beta(1:end).data);
sub = vertcat(rep_sub(1:end).sub);

%make dataframe
dataframe.dmpfc = [sub beh_beta_new];

%remove NaNs
dataframe.dmpfc(any(isnan(dataframe.dmpfc), 2), :) = [];

%% bilateral striatum
ROI = 'Nacc_both';
%mean_beta = 1;

% load betas
betas_dir = 'E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\';
roi = load([betas_dir 'cues_all_trials_' ROI '.mat']);

% Reshape and clean betas 

for s = 1:length(sl)
  
    meanbetas = mean(roi.df(s).maskBetas, 2); %get means of betas across all voxels

    %detrend betas
    mean_overall = mean(meanbetas);

    for k = 1:length(meanbetas) 
        meanbetas(k) = meanbetas(k) - mean_overall;
    end 
    
    %get behavioural data
    beh =  load(['E:\Information_gathering-main\Analysis\BEH\' num2str(sl(s)) '\' num2str(sl(s)) 'beh_regs.mat']);
    
    if sl(s) == 102 || sl(s) == 118
       
        beh_vertcat = vertcat(beh.beh_regs(1:3).(coi{1}));
    elseif sl(s) == 114
        beh.beh_regs(2) = [];
        beh_vertcat = vertcat(beh.beh_regs.(coi{1}));

    elseif sl(s) == 120
        beh_vertcat = vertcat(beh.beh_regs(2:4).(coi{1}));

    else

        beh_vertcat = vertcat(beh.beh_regs.(coi{1}));
    end

    %concatenate behaviour and betas
    beh_beta(s).data = horzcat(beh_vertcat, meanbetas);

    %repeat subject number
    rep_sub(s).sub = repelem(sl(s), length(meanbetas))';
end 

%make data long
beh_beta_new = vertcat(beh_beta(1:end).data);
sub = vertcat(rep_sub(1:end).sub);

%make dataframe
dataframe.r_striatum = [sub beh_beta_new];

%remove NaNs
dataframe.r_striatum(any(isnan(dataframe.r_striatum), 2), :) = [];
dataframe_raw = dataframe;


%% PLOT DATA (3 Bars per Delta-EV Level) - corrected SE and errorbar placement

roi_names = {'Left dmPFC', 'Bilateral Striatum'};
roi_fields = {'dmpfc', 'r_striatum'};

% 1) collect union of all deltaEV values across ROIs
all_groups = [];
for i = 1:length(roi_fields)
    all_groups = [all_groups; unique(dataframe.(roi_fields{i})(:,2))];
end
uniqueGroups = unique(all_groups, 'sorted');   % final x-axis groups
ngroups = length(uniqueGroups);
nbars = length(roi_fields);

% Prealloc
groupMeans_all = NaN(ngroups, nbars);
groupSEs_all   = NaN(ngroups, nbars);



% 2) compute mean, std, n per group for each ROI
for i = 1:nbars
    df = dataframe.(roi_fields{i});
    if isempty(df)
        continue
    end
    deltaVals = df(:,2);
    betas     = df(:,3);
    
    % For each uniqueGroups value compute stats
    for g = 1:ngroups
        gv = uniqueGroups(g);
        idx = deltaVals == gv;
        vals = betas(idx);
        if ~isempty(vals)
            groupMeans_all(g, i) = mean(vals);
            groupSEs_all(g, i)   = std(vals) / sqrt(numel(vals)); % SE per group
        else
            groupMeans_all(g, i) = NaN;
            groupSEs_all(g, i)   = NaN;
        end
    end
end

% 3) plot grouped bar and use bar handles for correct x positions
figure;
hb = bar(uniqueGroups, groupMeans_all, 'grouped');
hold on;

% Use bar object to get x positions for each bar (MATLAB R2019b+ supports XEndPoints)
for i = 1:nbars

        x = hb(i).XEndPoints;  % bar centers for current ROI across groups
 
    
    % Only plot errorbars for non-NaN groups
    valid = ~isnan(groupMeans_all(:, i));
    errorbar(x(valid), groupMeans_all(valid, i), groupSEs_all(valid, i), 'k', 'linestyle', 'none', 'linewidth', 1);
end

% Style
set(gca, ...
    'XTick', uniqueGroups, ...
    'FontSize', 16, ...         % <<--- Bigger tick labels
    'LineWidth', 1.5);      % <<--- Bold tick labels
%xlabel('ΔEV');
%ylabel('Mean Beta');
legend(roi_names, 'Location', 'best');
%title('ROI Betas as a Function of ΔEV (means ± SE)');
box off;
hold off;

%% 3 bins images
%% preserve continuous deltaEV before binning (for regression use later)

% bin deltaEV into 3 groups
bin_edges  = [-6 -2 2 6];
bin_labels = 1:3;

for i = 1:length(roi_fields)
    df = dataframe.(roi_fields{i});
    df(:,2) = discretize(df(:,2), bin_edges, bin_labels);
    dataframe.(roi_fields{i}) = df;
end

% PLOT DATA (3 Bars per Delta-EV Bin) - corrected SE and errorbar placement
roi_names = {'Left dmPFC', 'Bilateral Striatum'};

% 1) collect union of all deltaEV bin values across ROIs
all_groups = [];
for i = 1:length(roi_fields)
    all_groups = [all_groups; unique(dataframe.(roi_fields{i})(:,2))];
end
uniqueGroups = unique(all_groups(~isnan(all_groups)), 'sorted');   % final x-axis groups
ngroups = length(uniqueGroups);
nbars = length(roi_fields);

% Prealloc
groupMeans_all = NaN(ngroups, nbars);
groupSEs_all   = NaN(ngroups, nbars);

% 2) compute mean, std, n per group for each ROI
for i = 1:nbars
    df = dataframe.(roi_fields{i});
    if isempty(df)
        continue
    end
    deltaVals = df(:,2);
    betas     = df(:,3);

    % For each uniqueGroups value compute stats
    for g = 1:ngroups
        gv = uniqueGroups(g);
        idx = deltaVals == gv;
        vals = betas(idx);
        if ~isempty(vals)
            groupMeans_all(g, i) = mean(vals);
            groupSEs_all(g, i)   = std(vals) / sqrt(numel(vals)); % SE per group
        else
            groupMeans_all(g, i) = NaN;
            groupSEs_all(g, i)   = NaN;
        end
    end
end

% 3) plot grouped bar and use bar handles for correct x positions
figure;
hb = bar(uniqueGroups, groupMeans_all, 'grouped');
hold on;

% Use bar object to get x positions for each bar (MATLAB R2019b+ supports XEndPoints)
for i = 1:nbars
    x = hb(i).XEndPoints;  % bar centers for current ROI across groups
    % Only plot errorbars for non-NaN groups
    valid = ~isnan(groupMeans_all(:, i));
    errorbar(x(valid), groupMeans_all(valid, i), groupSEs_all(valid, i), 'k', 'linestyle', 'none', 'linewidth', 1);
end

% Style
set(gca, ...
    'XTick', uniqueGroups, ...
    'FontSize', 16, ...
    'LineWidth', 1.5);
xticklabels({'-5,-3','-1,1','3,5'});
legend(roi_names, 'Location', 'best');
box off;
hold off;
%% regressions
%get means per subject per unique delta -ev value

%dmPFC

% Extract groups (subject, delta ev)
 groupVars = dataframe.dmpfc(:,1:2);
% 
% % Compute means of betas for each group
 means = grpstats(dataframe.dmpfc(:,3), groupVars, 'mean');
% 
% % Combine results
 result = unique(groupVars, 'rows');
 result(:,3) = means;

 dmpfc = array2table(result,'VariableNames',{'subID' 'deltaEV' 'Beta'});

 %regression for dmpfc

 lme = fitlme(dmpfc,'Beta~deltaEV+(1|subID)');
 lme

%r striatum

 groupVars = dataframe.r_striatum(:,1:2);
% 
% % Compute means of betas for each group
 means = grpstats(dataframe.r_striatum(:,3), groupVars, 'mean');
% 
% % Combine results
 result = unique(groupVars, 'rows');
 result(:,3) = means;

r_striatum = array2table(result,'VariableNames',{'subID' 'deltaEV' 'Beta'});

 %regression for dmpfc

 lme = fitlme(r_striatum,'Beta~deltaEV+(1|subID)');
 lme


