%% For plotting behavioural horizon data (Fig 1B)
clc; close all; clear;

%% Read in and process data

%per trial data
horizon_table = readtable("~\horizon_data_all_subjects.csv");
tbl = groupsummary(horizon_table,["SubjectID", "Condition"],"mean","NumCuesObserved"); %get means per condition and per subject
tbl.Condition = categorical(tbl.Condition); %convert Long vs Short to categorical 

%make data wide
tbl_wide = unstack(tbl,'mean_NumCuesObserved','Condition');

%separate into short and long
means_long = rmmissing(tbl_wide.Long);
means_short = rmmissing(tbl_wide.Short);


means = [mean(means_short); mean(means_long)];
errors = [std(means_short); std(means_long)]; % Assuming you want to use standard deviation as error

clf;

h = bar(means');
h.FaceColor = 'flat';
h.CData(1,:) = [0.996 0.596 0.922];
h.CData(2,:) = [0.2 0.8 0.2];
hold on

% Add error bars
x = [1, 2]; % X positions of the bars
errorbar(x, means, errors, 'k', 'linestyle', 'none'); % 'k' for black error bars
% Add individual data points with outlines and offset
scatter(repmat(x(1) - 0.1, size(means_short)), means_short, 'filled', 'MarkerFaceColor', [0.996 0.596 0.922], 'MarkerEdgeColor', 'k');
scatter(repmat(x(2) + 0.1, size(means_long)), means_long, 'filled', 'MarkerFaceColor', [0.2 0.8 0.2], 'MarkerEdgeColor', 'k');

% Add lines between corresponding data points
for i = 1:length(means_short)
    plot([x(1) - 0.1, x(2) + 0.1], [means_short(i), means_long(i)], 'k:');
end

% Replace x-axis labels
set(gca, 'XTick', x, 'XTickLabel', {'Short', 'Long'}, 'FontSize',14);

% Add y-axis label
ylabel('Mean number of draws', 'FontSize', 14);

box off;



%% Plot grouped horizon histogram
clf;

% Plot frequency histograms (normalized to show proportions)
hold on
h1 = histogram(means_short, 'Normalization', 'probability', ...
    'FaceColor', [1 0.4 0.6], 'EdgeColor', 'k', 'FaceAlpha', 0.6);

h1.BinWidth = 0.3;

h2 = histogram(means_long, 'Normalization', 'probability', ...
    'FaceColor', [0.2 0.8 0.2], 'EdgeColor', 'k', 'FaceAlpha', 0.6);

h2.BinWidth = 0.3;

% Add legend
legend({'Short', 'Long'});

% Add labels
xlabel('Draws to a decision');
ylabel('Frequency [%]');
%title('Distribution of draws per subject (normalized)');

hold off


%% check if long and short are significantly different

[h,p,ci,stats] = ttest(means_short,means_long);
h
p
ci
stats
