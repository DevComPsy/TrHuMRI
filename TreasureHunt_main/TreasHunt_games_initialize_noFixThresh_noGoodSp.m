function TreasHunt_games_initialize_noFixThresh_noGoodSp()
% make a comment
global params user

% reset randomness starting point
% s = RandStream('mt19937ar','seed',sum(100*clock));
% RandStream.setGlobalStream(s);
% rng('shuffle')

user.conditions = [];

%% aggregated trajectories
% load traj
tmp = load([params.general.wd_seqs params.general.wd_exp_file]);
%tmp = load("/Users/lucyk/Library/Mobile Documents/com~apple~CloudDocs/Hiwi/compPsy/task_v08_MEGEEG/traj/07-Apr-2015_seqs_1.mat")
seq1 = nan(80,8,2);
seq2 = nan(80,14,2);
for g = 1:40
    for gg = 1:2
        seq1((gg-1)*40+g,1:length(tmp.seqs(g,gg).ev),:) = tmp.seqs(g,gg).ev;
        seq2((gg-1)*40+g,1:length(tmp.seqs(g,gg+2).ev),:) = tmp.seqs(g,gg+2).ev;
    end
end
% shuffle seqs
seq1 = seq1(randperm(80),:,:);
seq2 = seq2(randperm(80),:,:);
clear seqs tmp


% combine traj with different conditions
% dims: Goodaction, termination, trajs,col1:2
clc
seqs = nan(2,2,params.task.exp.n_games,14,2);
tmp_col = [ones(1,params.task.exp.n_games/2) zeros(1,params.task.exp.n_games/2)];
cols = nan(2,2,params.task.exp.n_games);
tmp_side = [ones(1,params.task.exp.n_games/2) zeros(1,params.task.exp.n_games/2)];
side = nan(2,2,params.task.exp.n_games);
tmp_sldR = [zeros(1,round(params.task.exp.n_games*(1-params.task.exp.p_rating_resp))) ...
    ones(1,round(params.task.exp.n_games*params.task.exp.p_rating_resp))];
tmp_sldT = [zeros(1,round(params.task.exp.n_games*(1-params.task.exp.p_rating_term))) ...
    ones(1,round(params.task.exp.n_games*params.task.exp.p_rating_term))];
sldr = nan(2,2,params.task.exp.n_games);

for i = 1:size(seqs,1)  % goods
    for ii = 1:size(seqs,2) % termination
        if ii == 1
            if i == 1
                seqs(i,ii,:,1:size(seq1,2),:) = seq1(1:params.task.exp.n_games,:,:);
            elseif i == 2
                seqs(i,ii,:,1:size(seq1,2),:) = seq1(params.task.exp.n_games+1:2*params.task.exp.n_games,:,:);
            else
                error('dumm')
            end
        elseif ii == 2
            if i == 1
                seqs(i,ii,:,1:14,:) = seq2(1:params.task.exp.n_games,:,:);
            elseif i == 2
                seqs(i,ii,:,1:14,:) = seq2(params.task.exp.n_games+1:2*params.task.exp.n_games,:,:);
            else
                error('dumm')
            end
        else
            error('dummdumm')
        end
            cols(i,ii,:) = tmp_col(randperm(params.task.exp.n_games));
            side(i,ii,:) = tmp_side(randperm(params.task.exp.n_games));
            sldr(i,ii,:) = tmp_sldT(randperm(length(tmp_sldT)));
            sldr_resp(i,ii,:) = tmp_sldR(randperm(length(tmp_sldR)));
%             mean(cols(i,ii,iii,:))
    end
end


%% distribute manually and then randomize
conds = [1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3; ...
         1:4; 2:4 1; 3:4 1:2; 4 1:3];
conds = conds(randperm(size(conds,1)),:);
for b = 1:4
    for i = 1:4
        if numel(find(conds(:,b)==i)) ~= 40/4
            warning(['not evenly distributed: ' int2str(b) ' ' int2str(i)])
        end
    end
end

%% fill in conditions
% dims: GoodsAction, Cost, trajs
for b = 1:params.task.exp.n_blocks
    for g = 1:params.task.exp.n_games
        switch conds(g,b)
            case 1
                user.conditions.block(b).GoodsAction(g) = 1;
                user.conditions.block(b).ThreshCond(g) = 1;
                user.conditions.block(b).term_cond(g) = 1;
                user.conditions.block(b).game(g).n_cues = squeeze(seqs(1,1,g,:,:));
                seqs(1,1,g,:,:) = nan;
                user.conditions.block(b).game(g).cols = cols(1,1,g);
                cols(1,1,g) = nan;
                user.conditions.block(b).respColSide(g) = side(1,1,g);
                side(1,1,g) = nan;
                user.conditions.block(b).slider_term(g) = sldr(1,1,g);
                sldr(1,1,g) = nan;
                user.conditions.block(b).slider_resp(g) = sldr_resp(1,1,g);
                sldr_resp(1,1,g) = nan;
                
            case 2
                user.conditions.block(b).GoodsAction(g) = 1;
                user.conditions.block(b).ThreshCond(g) = 1;
                user.conditions.block(b).term_cond(g) = 1;
                user.conditions.block(b).game(g).n_cues = squeeze(seqs(2,1,g,:,:));
                seqs(2,1,g,:,:) = nan;
                user.conditions.block(b).game(g).cols = cols(2,1,g);
                cols(2,1,g) = nan;
                user.conditions.block(b).respColSide(g) = side(2,1,g);
                side(2,1,g) = nan;
                user.conditions.block(b).slider_term(g) = sldr(2,1,g);
                sldr(2,1,g) = nan;
                user.conditions.block(b).slider_resp(g) = sldr_resp(2,1,g);
                sldr_resp(2,1,g) = nan;
                
            case 3
                user.conditions.block(b).GoodsAction(g) = 1;
                user.conditions.block(b).ThreshCond(g) = 1;
                user.conditions.block(b).term_cond(g) = 2;
                user.conditions.block(b).game(g).n_cues = squeeze(seqs(1,2,g,:,:));
                seqs(1,2,g,:,:) = nan;
                user.conditions.block(b).game(g).cols = cols(1,2,g);
                cols(1,2,g) = nan;
                user.conditions.block(b).respColSide(g) = side(1,2,g);
                side(1,2,g) = nan;
                user.conditions.block(b).slider_term(g) = sldr(1,2,g);
                sldr(1,2,g) = nan;
                user.conditions.block(b).slider_resp(g) = sldr_resp(1,2,g);
                sldr_resp(1,2,g) = nan;
                
            case 4
                user.conditions.block(b).GoodsAction(g) = 1;
                user.conditions.block(b).ThreshCond(g) = 1;
                user.conditions.block(b).term_cond(g) = 2;
                user.conditions.block(b).game(g).n_cues = squeeze(seqs(2,2,g,:,:));
                seqs(2,2,g,:,:) = nan;
                user.conditions.block(b).game(g).cols = cols(2,2,g);
                cols(2,2,g) = nan;
                user.conditions.block(b).respColSide(g) = side(2,2,g);
                side(2,2,g) = nan;
                user.conditions.block(b).slider_term(g) = sldr(2,2,g);
                sldr(2,2,g) = nan;
                user.conditions.block(b).slider_resp(g) = sldr_resp(2,2,g);
                sldr_resp(2,2,g) = nan;
                
                
            otherwise
                error('unknown condition')
        end
    end
end
                
                
                
find(~isnan(seqs))
find(~isnan(cols))
find(~isnan(side))
find(~isnan(sldr))

%% randomize within block (so far first seq is always the same, etc)
for b = 1:params.task.exp.n_blocks
    g_ran = randperm(params.task.exp.n_games);
    user.conditions.block(b).GoodsAction = user.conditions.block(b).GoodsAction(g_ran);
    user.conditions.block(b).ThreshCond = user.conditions.block(b).ThreshCond(g_ran);
    user.conditions.block(b).term_cond = user.conditions.block(b).term_cond(g_ran);
    user.conditions.block(b).game = user.conditions.block(b).game(g_ran);
    user.conditions.block(b).respColSide = user.conditions.block(b).respColSide(g_ran);
    user.conditions.block(b).slider_term = user.conditions.block(b).slider_term(g_ran);
    user.conditions.block(b).slider_resp = user.conditions.block(b).slider_resp(g_ran);
end

%% sanity check
%         || numel(find(user.conditions.block(b).respColSide==1))~=params.task.exp.n_games/2 ...
% distribution across blocks
for b = 1:params.task.exp.n_blocks
    if numel(find(user.conditions.block(b).ThreshCond==1))~=params.task.exp.n_games ...
        || numel(find(user.conditions.block(b).term_cond==2))~=params.task.exp.n_games/2 ...
        warning('something does not match')
    else
        display('fine so far...')
    end
end



% sequence with both response sides?
assoc = nan(params.task.exp.n_games,params.task.exp.n_blocks);
uPS = nan(params.task.exp.n_games,params.task.exp.n_blocks);
sld = nan(params.task.exp.n_games,params.task.exp.n_blocks);
for gg = 1:params.task.exp.n_games
    for b = 1:params.task.exp.n_blocks
        if user.conditions.block(b).respColSide(gg) == 1 && user.conditions.block(b).game(gg).cols == 1
            assoc(gg,b) = 1;
        elseif user.conditions.block(b).respColSide(gg) == 1 && user.conditions.block(b).game(gg).cols == 0
            assoc(gg,b) = 2;
        elseif user.conditions.block(b).respColSide(gg) == 0 && user.conditions.block(b).game(gg).cols == 1
            assoc(gg,b) = 3;
        elseif user.conditions.block(b).respColSide(gg) == 0 && user.conditions.block(b).game(gg).cols == 0
            assoc(gg,b) = 4;
        end
        if user.conditions.block(b).slider_resp(gg) == 1 && user.conditions.block(b).ThreshCond(gg) == 1
            sldr(gg,b) = 1;
        elseif user.conditions.block(b).slider_resp(gg) == 0 && user.conditions.block(b).ThreshCond(gg) == 1
            sldr(gg,b) = 3;
        end
        if user.conditions.block(b).slider_term(gg) == 1 && user.conditions.block(b).ThreshCond(gg) == 1
            sldt(gg,b) = 1;
        elseif user.conditions.block(b).slider_term(gg) == 0 && user.conditions.block(b).ThreshCond(gg) == 1
            sldt(gg,b) = 3;
        end
    end
    oner(gg) = numel(find(assoc(gg,:)==1));
    twoer(gg) = numel(find(assoc(gg,:)==2));
    threer(gg) = numel(find(assoc(gg,:)==3));
    fourer(gg) = numel(find(assoc(gg,:)==4));
end
fprintf(['left y, col y: ' int2str(sum(oner)) '\n'])
fprintf(['left y, col b: ' int2str(sum(twoer)) '\n'])
fprintf(['left b, col y: ' int2str(sum(threer)) '\n'])
fprintf(['left b, col b: ' int2str(sum(fourer)) '\n'])


% how often is slider associated with and without threshold?
fprintf(['slider resp presented n_{games}: ' int2str(numel(find(sldr==1))) ', not presented: ' int2str(numel(find(sldr==3))) '\n'])
fprintf(['slider term presented n_{games}: ' int2str(numel(find(sldt==1))) ', not presented: ' int2str(numel(find(sldt==3))) '\n'])



%% integrate colors into evidence shown by flipping the matrix
for b = 1:params.task.exp.n_blocks
    for s = 1:params.task.exp.n_games
        if user.conditions.block(b).game(s).cols == 1
            user.conditions.block(b).game(s).n_cues = fliplr(user.conditions.block(b).game(s).n_cues);
            user.conditions.block(b).game(s).cols = [];     % not needed anymore
            user.conditions.block(b).game(s).corr_col = 2;
        else
            user.conditions.block(b).game(s).cols = [];
            user.conditions.block(b).game(s).corr_col = 1;
        end
    end
    if ~isempty(find(~isempty([user.conditions.block(b).game(:).cols])))
        error('color assignment not successful')
    end
end

%% integrate termination of trial
for b = 1:params.task.exp.n_blocks
    for g = 1:params.task.exp.n_games
        user.conditions.block(b).termination(g) = max(find(~isnan(user.conditions.block(b).game(g).n_cues(:,1))));
    end
end
