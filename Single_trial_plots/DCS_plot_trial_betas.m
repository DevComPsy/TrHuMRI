clear all; close all; clc
addpath(genpath('D:\BE Code\gen_funct-master'));

%% To create plot 2B for decision-commitment signal

tmp = dir(['E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\1*']);
sl = [];
for s = 1:length(tmp)
    try
        sl = [sl str2num(tmp(s).name)];
    end
end

%% DMPFC
coi = {'prob_choice'};   
ROI = 'DCS_right_dmpfc_roi';

% load betas
betas_dir = 'E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\';
% roi = load([betas_dir 'cues_all_trials_' ROI '.mat']);
roi = load("E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\cues_all_trials_DCS_right_dmpfc.mat");

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

%% LC
ROI = 'LC_prob_choice_all';

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
dataframe.lc = [sub beh_beta_new];

%remove NaNs
dataframe.lc(any(isnan(dataframe.lc), 2), :) = [];
dataframe_raw = dataframe;   % preserve continuous prob_choice before binning

%% PLOT DATA (3 Bars per Delta-EV Level) - corrected SE and errorbar placement

roi_names = {'Right dmPFC', 'Bilateral LC'};
roi_fields = {'dmpfc', 'lc'};

% Define bin edges and labels
bin_edges  = 0:0.3:1.0001;      % [0–0.2), [0.2–0.4), ..., [0.8–1]
bin_labels = 1:3;               % 5 bins total

% 1) Apply binning to all ROIs
all_groups = [];
for i = 1:length(roi_fields)
    df = dataframe.(roi_fields{i});
    
    % Ensure ΔEV (2nd column) is within [0,1]
    df(df(:,2) < 0, 2) = 0;
    df(df(:,2) > 1, 2) = 1;
    
    % Bin ΔEV values (continuous)
    df(:,2) = discretize(df(:,2), bin_edges, bin_labels);
    
    dataframe.(roi_fields{i}) = df;
    all_groups = [all_groups; unique(df(:,2))];
end

% 2) Get final bin indices
uniqueGroups = unique(all_groups(~isnan(all_groups)), 'sorted');
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
    deltaVals = double(df(:,2));
    betas     = df(:,3);
    
    for g = 1:ngroups
        gv = uniqueGroups(g);
        idx = deltaVals == gv;
        vals = betas(idx);
        if ~isempty(vals)
            groupMeans_all(g, i) = mean(vals);
            groupSEs_all(g, i)   = std(vals) / sqrt(numel(vals));
        end
    end
end

% 3) plot grouped bar
figure;
hb = bar(uniqueGroups, groupMeans_all, 'grouped');
hold on;

% Add error bars at correct positions
for i = 1:nbars
    try
        x = hb(i).XEndPoints;
    catch
        x = (1:ngroups) - 0.35 + (2*i-1)*0.35/nbars;
    end
    valid = ~isnan(groupMeans_all(:, i));
    errorbar(x(valid), groupMeans_all(valid, i), groupSEs_all(valid, i), ...
        'k', 'linestyle', 'none', 'linewidth', 1.5);
end

% --- Styling ---
set(gca, ...
    'XTick', uniqueGroups, ...
    'FontSize', 16, ...
    'LineWidth', 1.5);

% Optional: label bins as ranges
%xticklabels({'0–0.2','0.2–0.4','0.4–0.6','0.6–0.8','0.8–1.0'});
xticklabels({'0–0.3','0.3–0.6','0.6–1.0'});

legend(roi_names, 'Location', 'best', 'FontSize', 14);
box off;
hold off;
%% regressions
%get means per subject per unique delta -ev value

%dmPFC

% Extract groups (subject, delta ev)
 groupVars = dataframe_raw.dmpfc(:,1:2);
% 
% % Compute means of betas for each group
 means = grpstats(dataframe_raw.dmpfc(:,3), groupVars, 'mean');
% 
% % Combine results
 result = unique(groupVars, 'rows');
 result(:,3) = means;

 dmpfc = array2table(result,'VariableNames',{'subID' 'prob_choice' 'Beta'});

 %regression for dmpfc

 lme = fitlme(dmpfc,'Beta~prob_choice+(1|subID)');
 lme


%LC
 groupVars = dataframe_raw.lc(:,1:2);
% 
% % Compute means of betas for each group
 means = grpstats(dataframe_raw.lc(:,3), groupVars, 'mean');
% 
% % Combine results
 result = unique(groupVars, 'rows');
 result(:,3) = means;

lc = array2table(result,'VariableNames',{'subID' 'prob_choice' 'Beta'});

 %regression for dmpfc

 lme = fitlme(lc,'Beta~prob_choice+(1|subID)');
 lme




 

