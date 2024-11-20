% function TreasHunt_user_initialize(userID,debug)
%
% TreasureHunt function
% initializes the global structure 'user'
% this structure will contain the log, gris, etc.
%
% @userID: subject-specific code (int)
% @debug: determined whether this was done in debug mode
%
% TH, 09.14
%
function TreasHunt_user_initialize(userID,debug)

if nargin < 2
    debug = 0;
elseif ~nargin
    userID = 99999;
    debug = 1;
end

global params user;
global window

%% user details
user.ID                         = userID;
user.date                       = int64(dot(clock,[10^10,10^8,10^6,10^4,10^2,1]));  % YYYYMMDDHHMMSS date
user.log_descr                  = {'block','game','trial','deltaOutcome','t_termination','termCond','col_right',...
                                'response (1:right)','currOutcome','WinLoss','col_chosen','RT','tot_cues_gold','tot_cues_blue',...
                                'curr_cues_gold','curr_cues_blue','trial_beg','map_pres','cue_pres','cue_out','response','fixation2','outcome'};
user.debug                      = debug;
user.tmp.col                    = 1;

%% Initialise timestamps log
user.triggertime = []; %initialise vector for triggers
user.triggerno = [];
user.fixation_outcome = [];
user.response = [];
user.termination = [];
user.outcome = [];
user.cue_pres = [];
user.fixation1 = [];