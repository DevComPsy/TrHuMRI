% function TreasHunt_initialize(userID,debug)
%
% TreasureHunt function
% initializes the experiment and sets all the parameters. This is the
% central file where all adjustments should be made.
% creates the global structure 'params'
%
% @debug: determine whether in debug mode (1; default: 0)
%
% TH, 09.14/11.14/12.14
%
function TreasHunt_initialize(userID,debug)
if ~nargin
    debug = 0;
    userID = 999;
end

clear params
global params;

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
% RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

%% general parameters
params.general.wd                   = pwd;
params.general.wd_seqs              = [pwd '\traj\'];    % directory of evidence sequences
params.general.wd_exp_file          = '07-Apr-2015_seqs_1.mat'; 
params.general.date                 = clock;
params.general.matlab               = version;
[~, tmp]        = system('hostname');
params.general.computer = cellstr(tmp);
params.general.res_dir              = [pwd '\logs\'];

params.general.display.mode         = 1;            % 1: full screen; 2: dual screen
% params.general.display.resolution   = 3;            % 3: 1024*768
params.general.display.bg_col       = [213  213  213 ];    %matched for luminance
params.general.display.fg_col       = [0 0 0]; %[1 1 1];
params.general.display.nbuffers     = 5;            % number of offscreen buffers
params.general.display.text_col     = [0 0 0];
params.general.keyboard.quelength   = 100;          % maximum number of key events recorded between calls to READKEYS
params.general.keyboard.resolution  = 1;            % time resolution in ms
params.general.keyboard.mode        = 'exclusive';  % 'exclusive': only cogent can access keyboard - needed for good timing

params.general.text.font            = 'Helvetica';
params.general.text.font_size       = 20;
params.general.text.color           = params.general.display.fg_col;

%defined in set up keyboard
% params.general.keys.l               = 28; % 2;%97;%          % left arrow
% params.general.keys.r               = 31; % 18;%98;%        % right arrow
% params.general.keys.confirm         = 71;           % space bar

params.general.eyelink              = 0;

%% task parameters
params.task.taskversion             = 'v2.0';
params.task.taskversion_date        = [2024 10 14];
params.task.author                  = 'TUH';
params.task.modifier                = 'AM - KK - LK';

params.task.exp.n_blocks            = 4;
params.task.exp.n_games             = 40;
params.task.exp.n_trials            = 120;

params.task.exp.GoodsAction         = 0;            % games in goods and action space
params.task.exp.noTreshCond         = 0;            % games whit fixed trial length where no threshold should appear
% params.task.exp.noThres_resp_dur    = 3000;        % time to respond when they have to
params.task.exp.term                = 1;            % different termination conditions enabled
params.task.exp.confidence          = 0;            % confindence ratings enabled/disabled
params.task.exp.p_rating_resp       = 1/4;          % how often a confidence rating will appear
params.task.exp.p_rating_term       = 1/4;          % how often a confidence rating will appear

%% game parameters
params.task.game.dur_instr          = 15;         % instruction screen in ms
params.task.game.dur_pre_instr      = 15;         % fixation cross before instruction
% params.task.game.dur_response       = 500;

%% trial parameters
params.task.trial.dur_stimulus      = 10;         % in ms
% params.task.trial.dur_isi           = 500;

%% map parameters
params.map.posXY                    = [params.screen.xCenter params.screen.yCenter];      % center of map (?)
params.map.sizeXY                   = [120 100];    % size of map
params.map.borderSize               = 4;           % size of border in px
params.map.col                      = [0  0  0 ];      % border color
params.map.bg_col                   = [213 213 213];    % grey, matched for luminance 87.0509
params.map.n_cues                   = 120;          % number of singular areas that are contained in map
params.map.cue_col                  = [1 1 1];      % color of the cue

%% termination details

params.task.term_cols                = [121 255 82;...          % green
                                      255 132 255];           % pink    matched for luminance
if rem(userID,2)    % uneven participants
    params.task.term_cols = flipud(params.task.term_cols);
end
params.task.termXY                   = params.map.posXY;
params.task.term_map_size            = [360 140];
params.task.term_thickness           = 20;
params.task.term_dur                 = 1000;                        % termination screen
params.task.Jitter = CreateJitter(3,params.map.n_cues, [2, 5]);
                
%% cue colors
params.colSp.cueCols                = [255 229 37;...    % gold 86.9286
                                        70  243 255];    % blue zircon, matched for luminance  87.0345
params.colSp.noActCueCols           = [255  248  184 ;...  % unsaturated gold
                                        215  252  255 ];   % unsaturated blue zircone
params.colSp.terminationCol         = [255  184  224 ];     % pink: matched with bg_col 213 ...

%% response details
% bimanual condition (action space)
params.resp.biman(1).posXY          = [params.screen.xCenter+120 params.screen.yCenter];%[200 -220];  % position of the first response option in the bimanual condition
params.resp.biman(1).sizeXY         = [75 75];%[100 100];
params.resp.biman(1).button         = params.general.keys.r;

params.resp.biman(2).posXY          = [params.screen.xCenter-120 params.screen.yCenter];%[-200 -220];  % position of the first response option in the bimanual condition
params.resp.biman(2).sizeXY         = [75 75];%[100 100];
params.resp.biman(2).button         = params.general.keys.l;

% unimanual condition (cue space)
% params.resp.uniman.posXY            = [params.resp.biman(1).posXY; params.resp.biman(2).posXY];%[0 -220];
% params.resp.uniman.sizeXY           = [75 75];%[100 100];
% params.resp.uniman.col              = [160  160  160 ];%[60  251  30 ]; % green              %[0  134  255 ];    % blue
% params.resp.uniman.col_noThresh     = [220  255  213 ];  % green           %[175  215  255 ];
% params.resp.uniman.button           = [params.general.keys.r, params.general.keys.l];

%% confidence rating
params.slider.line_col              = [.5 .5 .5];
params.slider.indicator_col         = [1 1 0];
params.slider.waittime              = 0;
params.slider.resptime              = 3500;
params.slider.startloc              = (randi(21,ceil(params.task.exp.n_blocks*params.task.exp.n_games*(params.task.exp.p_rating_resp+params.task.exp.p_rating_term)),1)+39)/100; % randomly between .4 and .6
params.slider.pixperkey             = 4;
params.slider.question              = 'How confident are you now?';

%% outcome presentation
% params.outcome.posXY                = [0 0];
% params.outcome.sizeXY               = [400 20];
% params.outcome.sizeCurrX            = 10;
% params.outcome.bgCol                = [175  175  175 ];  % gray
% params.outcome.prevCol              = [0  0  0 ];      % black
% params.outcome.currCol              = [0  255  0 ];    % 
params.outcome.winBorderCol         = [255 228 0]; % yellowish
params.outcome.lossBorderCol         = [255 0 0];%[255  90  23 ];    % redish
% params.outcome.startPosX            = 0;

params.outcome.posXY                = [params.screen.xCenter-180 params.screen.yCenter+110];             % X: startpoint of bar (not center); Y: center of bar
params.outcome.maxX                 = params.screen.xCenter+180;                  % maximal point that bar can reach
params.outcome.barSizeY             = 12;
params.outcome.lossBorderX          = params.screen.xCenter-150;
params.outcome.winBorderX           = params.screen.xCenter+150;
params.outcome.barCol               = [0 0 255];    % color of the evidence bar
params.outcome.winCol               = [0 216 255];  % indicates the current win
params.outcome.lossCol              = [0 0 100];    % indicates the current loss

params.outcome.lossBorderSize       = [5 15];
params.outcome.winBorderSize        = [5 15];
params.outcome.n_steps              = 41;                       % number of steps for the whole oucome bar
params.outcome.dur                  = 1000;
params.outcome.dur_fixation         = 500;
params.outcome.poundPerWin          = 1;                        % money every time gold/red is hit
params.outcome.outcomeSteps         = [-2 -1 2];                % changes in steps for wrong/undecided/correct

%% output triggers
params.trigger.scanport             = 888;
params.trigger.nulltime             = 10;   % 10 ms

params.trigger.null                 = 0;
params.trigger.tr_offset            = 1;

params.trigger.tr_blockstart        = 2;
params.trigger.tr_gameInstrTerm1    = 3;
params.trigger.tr_gameInstrTerm2    = 4;
params.trigger.tr_fixation          = 5;

params.trigger.tr_cueTerm1          = 100;  % 101-114
params.trigger.tr_cueTerm2          = 120;  % 121-134
params.trigger.tr_cueTerm1Selected  = 140;  % 141-154
params.trigger.tr_cueTerm2Selected  = 160;  % 161-174

params.trigger.tr_Termination       = 19;

params.trigger.tr_confidenceSlider  = 21;

params.trigger.tr_outcomeWin        = 22;
params.trigger.tr_outcomeLoss       = 23;
params.trigger.tr_outcomeND         = 24;

params.trigger.tr_BlockBreak        = 66;
params.trigger.tr_ExpStart          = 69;

params.trigger.tr_ExpEnd            = 96;

params.trigger.tr_blockNumPref      = 190;      % 190-194 = block numbers
params.trigger.tr_gameNumPref       = 200;      % 201-240

params.trigger.tr_l_buttonpress     = 31;
params.trigger.tr_r_buttonpress     = 32;


params.trigger.tr_dummies           = 6;


%% change parameters in debug mode
if debug
    params.general.display.mode         = 0;
    params.general.keyboard.mode        = 'nonexclusive';
end