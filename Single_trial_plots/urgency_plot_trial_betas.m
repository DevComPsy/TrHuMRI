clear all; close all; clc
addpath(genpath('D:\BE Code\gen_funct-master'));

%% To create plot 4B for urgency

tmp = dir(['E:\Information_gathering-main\Analysis\new\1stL\cues_single_trial\1*']);
sl = [];
for s = 1:length(tmp)
    try
        sl = [sl str2num(tmp(s).name)];
    end
end
%sl(find(sl==715)) = [];

%% DMPFC
coi = {'trial'};   %trial number = urgency
ROI = 'rightDMPFCurgency';
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

%% bilateral LC
ROI = 'LC_urgency_all';
% ROI = 'LC_urgency_all_roi_SVC';
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
dataframe.lc = [sub beh_beta_new];

%remove NaNs
dataframe.lc(any(isnan(dataframe.lc), 2), :) = [];
dataframe_raw = dataframe;   % add this before the binning section
%% PLOT DATA (3 Bars per Delta-EV Level) - corrected SE and errorbar placement

roi_names = {'Right dmPFC', 'Bilateral LC'};
roi_fields = {'dmpfc', 'lc'};

bin_edges = 0:2:12;       % bins: [0–2), [2–4), ..., [14–16]
bin_labels = 1:6;         % bin numbers 1–8
% bin_edges = 0:4:12;       % bins: [0–4), [4–8), [8–12]
% bin_labels = 1:3;         % bin numbers 1–3
% 1) collect all binned deltaEV values
all_groups = [];
for i = 1:length(roi_fields)
    df = dataframe.(roi_fields{i});
    % Bin deltaEV column (2nd column)
    df(:,2) = discretize(df(:,2), bin_edges, bin_labels);
    dataframe.(roi_fields{i}) = df;
    all_groups = [all_groups; unique(double(df(:,2)))];
end
uniqueGroups = unique(all_groups, 'sorted');
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
xticklabels({'1–2','3–4','5–6','7–8', '9-10', '11-12'});
% xticklabels({'0–4','4–8','8–12'});
legend(roi_names, 'Location', 'best', 'FontSize', 14);
box off;
hold off;
%% regressions
% dmPFC
groupVars = dataframe_raw.dmpfc(:,1:2);
means = grpstats(dataframe_raw.dmpfc(:,3), groupVars, 'mean');
result = unique(groupVars, 'rows');
result(:,3) = means;
dmpfc = array2table(result,'VariableNames',{'subID' 'trial' 'Beta'});
lme = fitlme(dmpfc,'Beta~trial+(1|subID)');
lme

% LC
groupVars = dataframe_raw.lc(:,1:2);
means = grpstats(dataframe_raw.lc(:,3), groupVars, 'mean');
result = unique(groupVars, 'rows');
result(:,3) = means;
lc = array2table(result,'VariableNames',{'subID' 'trial' 'Beta'});
lme = fitlme(lc,'Beta~trial+(1|subID)');
lme

 

