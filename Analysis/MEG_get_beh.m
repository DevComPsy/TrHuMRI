function beh = MEG_get_beh(subject,beh_dir,meg_dir)

%% general stuff
addpath(genpath('D:\BE Code\gen_funct-master'));
cprintf('*Black',['obtaining behavioural details']);

if nargin < 2
%     error('please specify directories')
%     tmp_dir = ['D:\DATA\TreasureHunt\data\main_study\' int2str(subject) '\'];
    beh_dir = ['D:\Observational Study\Information_gathering-main\Analysis\BEH\' int2str(subject) '\'];
    meg_dir = ['D:\Observational Study\Information_gathering-main\Analysis\BEH\' int2str(subject) '\'];
end

%% load logfile
    % load log file 
list = dir([beh_dir '*_' int2str(subject) '*_4_log.mat']);
if length(list) > 1
    warning('more than one logfile - taking the last')
elseif isempty(list)
    error('no logfile found')
end
load([beh_dir list(end).name]);

%% check version
if ~strcmp(params.task.taskversion,'v2.0')
    error('wrong task version for this analysis script')
end

%% initalize beh
beh = [];
beh.descr = {'block','game','trial','termination','choiceTrial',...
            'chosen','currEvLeft','currEvRight','totEvLeft','totEvRight',...
            'diffCurrEvLeft','diffTotEvLeft','absDiffCurrEv','absDiffTotEv','distance2choice','currEvYellow'};

%% loop through trials
beh.dat = nan(size(user.log,1),length(beh.descr));    % intialize
for l = 1:size(user.log,1) % line in logfile
    
    beh.dat(l,1) = user.log(l,find(strcmp(user.log_descr,'block')));    % block
    beh.dat(l,2) = user.log(l,find(strcmp(user.log_descr,'game')));    % game
    beh.dat(l,3) = user.log(l,find(strcmp(user.log_descr,'trial')));    % trial
    
    beh.dat(l,4) = 3-user.log(l,find(strcmp(user.log_descr,'termCond'))); % termination condition: 2=short
    
    % choice in curr trial:     1: left, 2: right
    if ~isnan(user.log(l,find(strcmp(user.log_descr,'response (1:right)')))) && isnan(user.log(l-1,find(strcmp(user.log_descr,'response (1:right)'))))
        beh.dat(l,5) = 3 - user.log(l,find(strcmp(user.log_descr,'response (1:right)')));
    end
    
    % if choice was very early (<200ms) in trial: mark previous as 3
    if ~isnan(beh.dat(l,5)) && user.log(l,find(strcmp(user.log_descr,'RT'))) < 200
        beh.dat(l-1,5) = 3;
    end
    
    % chosen trial     1: left, 2 right
    if ~isnan(user.log(l,find(strcmp(user.log_descr,'response (1:right)')))) && isnan(beh.dat(l,5))
        beh.dat(l,6) = 3 - user.log(l,find(strcmp(user.log_descr,'response (1:right)')));
    end
    
    tmo_col_r = user.log(l,find(strcmp(user.log_descr,'col_right')));
    beh.dat(l,7) = user.log(l,17-tmo_col_r);    % curr ev left
    beh.dat(l,8) = user.log(l,14+tmo_col_r);    % curr ev right
    beh.dat(l,9) = user.log(l,15-tmo_col_r);    % tot ev left
    beh.dat(l,10) = user.log(l,12+tmo_col_r);    % tot ev right
    
    beh.dat(l,11) = beh.dat(l,7) - beh.dat(l,8);    % difference curr ev for left
    beh.dat(l,12) = beh.dat(l,9) - beh.dat(l,10);    % difference tot ev for left
    
    beh.dat(l,16) = user.log(l,find(strcmp(user.log_descr,'curr_cues_gold')));   % curr ev of yellow
end

beh.dat(:,13) = abs(beh.dat(:,11));
beh.dat(:,14) = abs(beh.dat(:,12));

% distance to choice trial
for l = 1:size(user.log,1) % line in logfile
    idx = find(beh.dat(:,2)==beh.dat(l,2) & beh.dat(:,1)==beh.dat(l,1));
    idx_c = find(~isnan(beh.dat(idx,find(strcmp(beh.descr,'choiceTrial'))))) + idx(1) -1;
    try
        if idx_c(end) - l > 0
            beh.dat(l,15) = idx_c(end) - l;
        end
    end
end

%% save
save([meg_dir int2str(subject) '_beh.mat'],'beh');
fprintf('\ndone.\n')