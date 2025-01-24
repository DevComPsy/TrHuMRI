function [trials, games] = aggregateBEH(ID,data_dir)

% general settings
% data_dir = ['E:\TrHu\data\BEH\' int2str(ID) '\'];
  

list = dir([data_dir '*_' int2str(ID) '*_4_log.mat']);
if length(list) > 1
    warning('more than one logfile - taking the first')
elseif isempty(list)
    try
       data_dir = ['D:\DATA\TreasureHuntClin\data\' int2str(ID) '\BEH\TrHu\']; 
       list = dir([data_dir '*_' int2str(ID) '_log.mat']);
    catch
    error('no logfile found')
    end
end
load([data_dir list(1).name]);

% check version
if ~strcmp(params.task.taskversion,'v2.0')
    error('wrong task version for this analysis script')
end

%% instantiate trials struct
clear trials
trials.descr.type = {'early term','late term'};
trials.descr.trial = {'trial_num','new_ev_chosen','new_ev_unchosen','new_ev_diff','cur_totev_chosen','cur_totev_unchosen','cur_totev','cur_totev_diff','first_ev_chosen','first_ev_unchosen',...
                    'first_ev_diff','ev_chosen_t-1','ev_unchosen_t-1','diff_ev_chosen_t-1','ev_chosen_t-2','ev_unchosen_t-2','diff_ev_chosen_t-2','ev_chosen_t-3','ev_unchosen_t-3','diff_ev_chosen_t-3',...
                    'ev_chosen_t-4','ev_unchosen_t-4','diff_ev_chosen_t-4','correct_chosen','term_cond','chosen','postDecision','nondec_game'};
% trials.descr.slider = {'referring trial','slider value'};

% run through trials
t = 1;
s = 1;
for tt = 1:size(user.log,1)
    trials.trial(t,1:length(trials.descr.trial)) = nan;
    
    tmp_last_tt = find(user.log(:,1)==user.log(tt,1) & user.log(:,2)==user.log(tt,2) & ~isnan(user.log(:,9)),1,'first');  % last trial of game (ignore the ones after decision)
    if isempty(tmp_last_tt) % non decision trial
        tmp_last_tt = find(user.log(:,1)==user.log(tt,1) & user.log(:,2)==user.log(tt,2),1,'last');
    end
    tmp_first_tt = find(user.log(:,1)==user.log(tt,1) & user.log(:,2)==user.log(tt,2),1,'first');  % first trial of game
    
        % determine trial type
        if user.log(tt,find(strcmp(user.log_descr,'termCond'))) == 1       % early term: 1?
            trials.type(t) = 1;
        elseif user.log(tt,find(strcmp(user.log_descr,'termCond'))) == 2   % late term: 2?
            trials.type(t) = 2;
        end
        
        % fill in data
        if tt == tmp_first_tt
            tmp_first_t = t;                                                % first trial of game
        end
        trials.trial(t,1) = user.log(tt,3);                                 % trial number
        
        if user.log(tmp_last_tt,11) == 1                                    % fill in if color 1 was chosen
            trials.trial(t,2) = user.log(tt,15);                            % curr evidence of chosen color
            trials.trial(t,3) = user.log(tt,16);                            % curr evidence of unchosen color
            trials.trial(t,5) = user.log(tt,13);                            % current total evidence for chosen color
            trials.trial(t,6) = user.log(tt,14);                            % current total evidence for unchosen color
        elseif user.log(tmp_last_tt,11) == 2                                % fill in if color 2 was chosen
            trials.trial(t,2) = user.log(tt,16);                            % curr evidence of chosen color
            trials.trial(t,3) = user.log(tt,15);                            % curr evidence of unchosen color
            trials.trial(t,5) = user.log(tt,14);                            % current total evidence for chosen color
            trials.trial(t,6) = user.log(tt,13);                            % current total evidence for unchosen color
        elseif isnan(user.log(tmp_last_tt,11))          % when no-decide, then assume the better to be chosen
            [~,tmp_i] = max([user.log(tmp_last_tt,13), user.log(tmp_last_tt,14)]);
            if tmp_i == 1
                trials.trial(t,2) = user.log(tt,15);                            % curr evidence of chosen color
                trials.trial(t,3) = user.log(tt,16);                            % curr evidence of unchosen color
                trials.trial(t,5) = user.log(tt,13);                            % current total evidence for chosen color
                trials.trial(t,6) = user.log(tt,14);                            % current total evidence for unchosen color
            else
                trials.trial(t,2) = user.log(tt,16);                            % curr evidence of chosen color
                trials.trial(t,3) = user.log(tt,15);                            % curr evidence of unchosen color
                trials.trial(t,5) = user.log(tt,14);                            % current total evidence for chosen color
                trials.trial(t,6) = user.log(tt,13);                            % current total evidence for unchosen color
            end
        else
            error('not yet defined')
        end
        
        trials.trial(t,4) = trials.trial(t,2) - trials.trial(t,3);          % curr evidence difference
        if sum(trials.trial(tmp_first_t:t,2)) ~= trials.trial(t,5) || sum(trials.trial(tmp_first_t:t,3)) ~= trials.trial(t,6)
            error('total evidence is wrong!')
        end
        trials.trial(t,7) = trials.trial(t,5) + trials.trial(t,6);          % current overall evidence
        trials.trial(t,8) = trials.trial(t,5) - trials.trial(t,6);          % current overall evidence difference
        trials.trial(t,9) = trials.trial(tmp_first_t,2);                    % first ev of chosen color
        trials.trial(t,10) = trials.trial(tmp_first_t,3);                   % first ev of unchosen color
        trials.trial(t,11) = trials.trial(t,9) - trials.trial(t,10);        % difference of first ev
        
        if trials.trial(t,1) == 1
            trials.trial(t,12:14) = nan;
        else
            trials.trial(t,12) = trials.trial(t-1,2);                       % ev chosen at t-1
            trials.trial(t,13) = trials.trial(t-1,3);                       % ev unchosen at t-1
            trials.trial(t,14) = trials.trial(t,12) - trials.trial(t,13);   % diff ev t-1
        end
        
        if trials.trial(t,1) <= 2
            trials.trial(t,15:17) = nan;
        else
            trials.trial(t,15) = trials.trial(t-2,2);                       % ev chosen at t-2
            trials.trial(t,16) = trials.trial(t-2,3);                       % ev unchosen at t-2
            trials.trial(t,17) = trials.trial(t,15) - trials.trial(t,16);   % diff ev t-2
        end
        
        if trials.trial(t,1) <= 3
            trials.trial(t,18:20) = nan;
        else
            trials.trial(t,18) = trials.trial(t-3,2);                       % ev chosen at t-3
            trials.trial(t,19) = trials.trial(t-3,3);                       % ev unchosen at t-3
            trials.trial(t,20) = trials.trial(t,18) - trials.trial(t,19);   % diff ev t-3
        end
        
        if trials.trial(t,1) <= 4
            trials.trial(t,21:23) = nan;
        else
            trials.trial(t,21) = trials.trial(t-4,2);                       % ev chosen at t-4
            trials.trial(t,22) = trials.trial(t-4,3);                       % ev unchosen at t-4
            trials.trial(t,23) = trials.trial(t,21) - trials.trial(t,22);   % diff ev t-3
        end
        
        if tt == tmp_last_tt                                                % determine whether correct/better object was chosen
            if trials.trial(t,8) > 0
                trials.trial(tmp_first_t:t,24)  = 1;                    % correct chosen = 1
            elseif trials.trial(t,8) == 0
                trials.trial(tmp_first_t:t,24)  = nan;                  % equal occurance = nan
            elseif trials.trial(t,8) < 0
                trials.trial(tmp_first_t:t,24)  = 2;                    % incorrect chosen = 2
            else
                trials.trial(tmp_first_t:t,24)  = 3;                    % no decision
            end
        end
        
        % add conditions: term 25
        if trials.type(t) == 1                    % early term=1; late term=2
            trials.trial(t,25) = 1;
        else
           trials.trial(t,25) = 2;
        end
        
        % chosen at this trial?
        if ~isnan(user.log(tt,11))
            trials.trial(t,26) = 1;                                     % 1=chosen, 0=unchosen
        else
            trials.trial(t,26) = 0;
        end
        
        % post decision trial  
        if trials.trial(t,1) > 1 && trials.trial(t-1,26)
            trials.trial(t,27) = 1;
        else
            trials.trial(t,27) = 0;
        end
%         if tmp_last_tt < tt                 % post decision trial                                        
%             trials.trial(t,27) = 1;         % 1: post decision, 0: pre decision
%         else
%             trials.trial(t,27) = 0;
%         end
        
        % non-decision game
        tmp_idx = find(user.log(:,1)==user.log(tt,1) & user.log(:,2)==user.log(tt,2));
        if any(~isnan(user.log(tmp_idx,11)))
            trials.trial(t,28) = 0;   % whether this is a non-decision game
        else
            trials.trial(t,28) = 1;
        end
            
        
        % % slider
        % if ~isnan(user.log(tt,17))
        %     trials.slider(s,1) = t;
        %     trials.slider(s,2) = user.log(tt,20);
        %     s = s+1;
        % end
        
        t = t+1;
end


%% instantiate games
clear games
games.descr.type = {'early term','late term'};
games.descr.game = {'trial_chosen','tot_ev_chosen','tot_ev_unchosen','last_ev_chosen','last_ev_unchosen','tot_ev_diff','last_ev_diff','first_ev_chosen','first_ev_unchosen','first_ev_diff',...
                    'chosen best','avg_ev_chosen','avg_ev_unchosen','avg_ev_diff','avg_delta_chosen','avg_delta_unchosen','avg_delta_diff','total_ev','term_cond','nonDescGame'};
% games.descr.slider = {'referring trial','slider value','slider condition (1:buttonpress)','ev diff'};

% run through games
s = 1;
gs = [find(diff(user.log(:,3))<0); size(user.log,1)];

for g = 1:length(gs)
    games.game(g,1:length(games.descr.game)) = nan;
    
    % determine decision trial (if there is)
    if isnan(user.log(gs(g),11))    % no decision: take last trial
        tmp_gsg = gs(g);
    else
        tmp_gsg = gs(g)-user.log(gs(g),3)+find(~isnan(user.log(gs(g)-user.log(gs(g),3)+1:gs(g),11)),1,'first');
    end
    
    % determine trial type
    if user.log(tmp_gsg,find(strcmp(user.log_descr,'termCond'))) == 1      % early term: 1
        games.type(g) = 1;
    elseif user.log(tmp_gsg,find(strcmp(user.log_descr,'termCond'))) == 2  % late term: 2
        games.type(g) = 2;
    end
    
    if isnan(user.log(tmp_gsg,11))                     % non decision trial
        games.game(g,20) = 1;                       % 0: decision made, 1: no decision made
        games.game(g,1) = user.log(tmp_gsg,3);
    else
        games.game(g,20) = 0;
        games.game(g,1) = user.log(tmp_gsg,3);    % trial chosen
    end
    
    % first trial
    tmp_first_t = find(user.log(:,1) == user.log(tmp_gsg,1) & user.log(:,2) == user.log(tmp_gsg,2),1,'first');
    if user.log(tmp_first_t,3) ~= 1
        error('first trial does not match')
    end
    
    % fill in data
    if user.log(tmp_gsg,11) == 1                                              % color 1 chosen
        games.game(g,2) = user.log(tmp_gsg,13);                               % total chosen ev
        games.game(g,3) = user.log(tmp_gsg,14);                               % total unchosen ev
        games.game(g,4) = user.log(tmp_gsg,15);                               % last ev chosen
        games.game(g,5) = user.log(tmp_gsg,16);                               % last ev unchosen
        games.game(g,8) = user.log(tmp_first_t,15);                         % first ev chosen
        games.game(g,9) = user.log(tmp_first_t,16);                         % first ev unchosen
        games.game(g,15) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence for chosen
        games.game(g,16) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence for unchosen
        games.game(g,17) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15) - user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence difference
        
    elseif user.log(tmp_gsg,11) == 2                                          % color 2 chosen
        games.game(g,2) = user.log(tmp_gsg,14);                               % total chosen ev
        games.game(g,3) = user.log(tmp_gsg,13);                               % total unchosen ev
        games.game(g,4) = user.log(tmp_gsg,16);                               % last ev chosen
        games.game(g,5) = user.log(tmp_gsg,15);                               % last ev unchosen
        games.game(g,8) = user.log(tmp_first_t,16);                         % first ev chosen
        games.game(g,9) = user.log(tmp_first_t,15);                         % first ev unchosen
        games.game(g,15) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence for chosen
        games.game(g,16) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence for unchosen
        games.game(g,17) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16) - user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence difference
        
    elseif isnan(user.log(tmp_gsg,11))    % no decision trials
        [~,tmp_i] = max([user.log(tmp_gsg,13), user.log(tmp_gsg,14)]);
        if tmp_i == 1
            games.game(g,2) = user.log(tmp_gsg,13);                               % total chosen ev
            games.game(g,3) = user.log(tmp_gsg,14);                               % total unchosen ev
            games.game(g,4) = user.log(tmp_gsg,15);                               % last ev chosen
            games.game(g,5) = user.log(tmp_gsg,16);                               % last ev unchosen
            games.game(g,8) = user.log(tmp_first_t,15);                         % first ev chosen
            games.game(g,9) = user.log(tmp_first_t,16);                         % first ev unchosen
            games.game(g,15) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence for chosen
            games.game(g,16) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence for chosen
            games.game(g,17) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15) - user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence difference
        else
            games.game(g,2) = user.log(tmp_gsg,14);                               % total chosen ev
            games.game(g,3) = user.log(tmp_gsg,13);                               % total unchosen ev
            games.game(g,4) = user.log(tmp_gsg,16);                               % last ev chosen
            games.game(g,5) = user.log(tmp_gsg,15);                               % last ev unchosen
            games.game(g,8) = user.log(tmp_first_t,16);                         % first ev chosen
            games.game(g,9) = user.log(tmp_first_t,15);                         % first ev unchosen
            games.game(g,15) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16)))); % average (absolute) change (delta) in evidence for chosen
            games.game(g,16) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence for chosen
            games.game(g,17) = mean(abs(diff(user.log(tmp_first_t:tmp_gsg,16) - user.log(tmp_first_t:tmp_gsg,15)))); % average (absolute) change (delta) in evidence difference
            end 
    else
        error('unknown response')
    end
    
    games.game(g,6) = games.game(g,2) - games.game(g,3);                    % total ev difference
    games.game(g,7) = games.game(g,4) - games.game(g,5);                    % last ev difference
    games.game(g,10) = games.game(g,8) - games.game(g,9);                   % first ev difference
    
    if games.game(g,20) == 1
         games.game(g,11) = 3;                                             % no choice = 3
    elseif games.game(g,6) > 0
        games.game(g,11) = 1;                                               % best stimulus chosen = 1
    elseif games.game(g,6) < 0
        games.game(g,11) = 2;                                               % incorrect chosen = 2
    else
        games.game(g,11) = nan;                                             % both equally good = nan
    end
    
    games.game(g,12) = games.game(g,2)/games.game(g,1);                     % average evidence chosen
    games.game(g,13) = games.game(g,3)/games.game(g,1);                     % average evidence unchosen
    games.game(g,14) = games.game(g,12) - games.game(g,13);                 % average evidence difference
    games.game(g,18) = games.game(g,2) + games.game(g,3);
    
    % trial conditions
    if games.type(g) == 1
        games.game(g,19) = 1;                                               % early term = 1, late term = 2
    else
        games.game(g,19) = 2;
    end
        
    % % slider
    % if any(~isnan(user.log(tmp_first_t:gs(g),17)))
    %     tmp_idx = find(~isnan(user.log(tmp_first_t:gs(g),17)));
    %     for i = 1:length(tmp_idx)
    %         games.slider(s,1) = g;
    %         games.slider(s,2) = user.log(tmp_first_t+tmp_idx(i)-1,20);
    %         games.slider(s,3) = user.log(tmp_first_t+tmp_idx(i)-1,17);     % slider condition
    %         games.slider(s,4) = abs(diff(user.log(tmp_first_t+tmp_idx(i)-1,13:14)));   % ev difference
    %         s = s+1;
    %     end
    % end
end

%% Save
save([data_dir int2str(ID) '_games.mat'],'games');
save([data_dir int2str(ID) '_trials.mat'],'trials');
fprintf('\ndone.\n')
    
end