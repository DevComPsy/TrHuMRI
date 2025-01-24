%% For plotting behavioural data
clc; close all; clear;

%initialise paths
data_path = 'D:\Observational Study\Information_gathering-main\Analysis\BEH\';
addpath(genpath('D:\BE Code\gen_funct-master'));
addpath(genpath('D:\Observational Study\Information_gathering-main\Analysis'));

%get foldernames
files1 = dir(data_path);

%remove elements that are not participant folders
matches = regexp({files1([files1.isdir]).name}, {'^\d+|^A\d+'});
bool = cellfun(@(x) any(x), matches);
files = files1(bool);

% Set up figure for subplots
figure;
numSubjects = length(files); % total number of subjects
numRows = ceil(sqrt(numSubjects)); % calculate grid layout for subplots
numCols = ceil(numSubjects / numRows);

means = [];

%% For Horizons
for i = 1:numSubjects
    %subject loop begins
    subject = files(i).name;

    %make sure we're in correct subject folder
    beh_dir = [data_path subject '\'];
    cd(beh_dir);

    % load trial file
    pattern = [num2str(subject) '_trials.mat'];
    fileInfo = dir(pattern);

    % Check if a matching file was found
    if ~isempty(fileInfo)
        load(fileInfo(1).name);
        disp(['Loaded file: ' fileInfo(1).name]);
    else
        error('No file matching the pattern was found.');
    end

    % Process data to obtain number of cues observed per game
    data = [trials.trial(:,26) trials.trial(:,25)];
    data = padarray(data,1,1,'pre');
    onebin = cumsum(data(:,1) == 1);
    num_cues = accumarray(onebin, data(:,1) == 0);
    num_cues(length(num_cues)) = [];
    num_cues = num_cues + 1;
    conds = data(data(:,1) == 1,2);
    conds(1) = [];
    new_matrix = [conds, num_cues];

    means_short(i) = mean(new_matrix(new_matrix(:,1) == 1, 2));
    means_long(i) =  mean(new_matrix(new_matrix(:,1) == 2, 2));

    % Get histogram data
    x = new_matrix(new_matrix(:,1) == 1, 2);
    y = new_matrix(new_matrix(:,1) == 2, 2);
    binRange = 0:1:15;
    hcx = histcounts(x, [binRange Inf]);
    hcy = histcounts(y, [binRange Inf]);

    % Plot in a subplot for each subject
    subplot(numRows, numCols, i);
    bar(binRange, [hcx; hcy]');
    title(['Subject ID: ' subject]);
    xlabel('Cues Observed Before Response');
    ylabel('Frequency');
    legend('Short', 'Long');
end

% Adjust layout for readability
sgtitle('Histograms of Cues Observed per Subject');

%% For Points
for i = 1:numSubjects
    %subject loop begins
    subject = files(i).name;

    %make sure we're in correct subject folder
    beh_dir = [data_path subject '\'];
    cd(beh_dir);

    % load trial file
    pattern = [num2str(subject) 'beh_regs.mat'];
    fileInfo = dir(pattern);

    % Check if a matching file was found
    if ~isempty(fileInfo)
        load(fileInfo(1).name);
        disp(['Loaded file: ' fileInfo(1).name]);
    else
        error('No file matching the pattern was found.');
    end
    
    %remove NaNs from points
    % for m = 1:4
    %     beh_regs(m).points(isnan(beh_regs(m).points) | beh_regs(m).points == 2) = [];
    % end

    for m = 1:4
        beh_regs(m).points(isnan(beh_regs(m).points)) = [];
    end
    
    all_points = vertcat(beh_regs(1).points, beh_regs(2).points, ...
        beh_regs(3).points, beh_regs(4).points);
    
    % Create histograms of points per subject
    x = all_points;
    binRange = -2:1:2;
    hc = histcounts(x, [binRange Inf]);

    % Plot in a subplot for each subject
    subplot(numRows, numCols, i);
    bar(binRange, hc);
    title(['Subject ID: ' subject]);
    xlabel('Points Obtained Per Game');
    ylabel('Frequency');
    ylim([0, 200]);
end

% Adjust layout for readability
sgtitle('Histograms of Points per Subject');

%% For correlations between outcome and response
for i = 1:numSubjects
    %subject loop begins
    subject = files(i).name;

    %make sure we're in correct subject folder
    beh_dir = [data_path subject '\'];
    cd(beh_dir);

    % load onsets file
    pattern = [num2str(subject) 'onsets_struct.mat']; 
    fileInfo = dir(pattern);

    % Check if a matching file was found
    if ~isempty(fileInfo)
        load(fileInfo(1).name);
        disp(['Loaded file: ' fileInfo(1).name]);
    else
        error('No file matching the pattern was found.');
    end

    % load trial file
    pattern = [num2str(subject) 'beh_regs.mat'];
    fileInfo = dir(pattern);

    % Check if a matching file was found
    if ~isempty(fileInfo)
        load(fileInfo(1).name);
        disp(['Loaded file: ' fileInfo(1).name]);
    else
        error('No file matching the pattern was found.');
    end
    
    %remove NaNs from points
    for m = 1:4
        beh_regs(m).points(isnan(beh_regs(m).points)) = [];
    end
    
    
    %remove outcomes without response 
    for m = 1:4
        beh(m).outcome(beh_regs(m).points == -1) = [];
    end

    all_outcomes = vertcat(beh(1).outcome, beh(2).outcome, ...
        beh(3).outcome, beh(4).outcome);
   
    all_response = vertcat(beh(1).response, beh(2).response, ...
        beh(3).response, beh(4).response);

    % Create histograms of points per subject


    % Plot in a subplot for each subject
    subplot(numRows, numCols, i);
    mdl = fitlm(all_outcomes,all_response);
    h = plot(mdl)
    title(['Subject ID: ' subject]);
    xlabel('Outcome Onset');
    ylabel('Response Onset');
end

% Adjust layout for readability
sgtitle('Correlation between response and outcome onsets per Subject');

%% Plot grouped horizon effect
clf;
means = [mean(means_short); mean(means_long)];
errors = [std(means_short); std(means_long)]; % Assuming you want to use standard deviation as error

h = bar(means');
h.FaceColor = 'flat';
h.CData(1,:) = [0 0.4470 0.7410];
h.CData(2,:) = [0.8500 0.3250 0.0980];
hold on

% Add error bars
x = [1, 2]; % X positions of the bars
errorbar(x, means, errors, 'k', 'linestyle', 'none'); % 'k' for black error bars
% Add individual data points with outlines and offset
scatter(repmat(x(1) - 0.1, size(means_short)), means_short, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerEdgeColor', 'k');
scatter(repmat(x(2) + 0.1, size(means_long)), means_long, 'filled', 'MarkerFaceColor', [0.8500 0.3250 0.0980], 'MarkerEdgeColor', 'k');

% Add lines between corresponding data points
for i = 1:length(means_short)
    plot([x(1) - 0.1, x(2) + 0.1], [means_short(i), means_long(i)], 'k-');
end

% Replace x-axis labels
set(gca, 'XTick', x, 'XTickLabel', {'Short', 'Long'});

% Add y-axis label
ylabel('Mean number of draws');