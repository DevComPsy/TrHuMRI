%% scripts to analyse behavior - current majority
% Based on April Nadescha Trudel 2022
% information search analyses
clear; clc
beep off

datadir = 'D:\Observational Study\Information_gathering-main\Analysis\small_beh\';
addpath(genpath('D:\BE Code\gen_funct-master'));
alldata = dir([datadir, '*.mat']);
alldatalist = {alldata.name}';

numsubs = size(alldatalist,1);
subIDall = str2double(strtok(alldatalist, '_'));

s = struct();


for isub=1:numsubs
    
    load([datadir, alldatalist{isub}])
    s.sub{isub} = beh;

end


% ------------------------------------------------------------------------------------------------------------------
%% 1. behavioural analysis: GLM, descriptives

for isub = 1:length(subIDall)
 
    %% mat file:
    subid = subIDall(isub);
    dat = s.sub{isub};
    pmat = [];
    pmat.mat    = dat.dat;
    pmat.names  = dat.descr';
    
    % -------------------------------------------------
    %% 1. continue/ stop LogReg
    % 1. get continue/stop variable:
    % -> use dist2ch as index ---  this means I only use the relevant trials up
    % until and include the choice = not post-choice
    dist2ch         = get_from_mat(pmat,'distance2choice');
    
    % dep variable:
    cont_ch    = NaN(1,length(dist2ch));
    % search:
    cont_ch(find(dist2ch>0)) = 1;
    % stop:
    cont_ch(find(dist2ch==1)+1) = 0;
    cont_ch = cont_ch';
    % relevant choices?
    chidx   = find(isnan(cont_ch)==0); % choice idx!
    
    trial        = get_from_mat(pmat,'trial');
    termination         = get_from_mat(pmat,'termination');

    % current majority evidence
    totevleft = get_from_mat(pmat,'totEvLeft');
    totevright = get_from_mat(pmat,'totEvRight');
    totevmajority = nan(size(totevright)); totevminority = nan(size(totevright));

    totevmajority(totevleft>=totevright) =  totevleft(totevleft>=totevright);
    totevmajority(totevleft<totevright) =  totevright(totevleft<totevright);
    totevminority(totevleft<=totevright) =  totevleft(totevleft<=totevright);
    totevminority(totevleft>totevright) =  totevright(totevleft>totevright);
    totev = totevmajority - totevminority;

    totevminus      = lagmatrix(totev,1);
    firstdraw_idx = find(trial==1);
    totevminus(firstdraw_idx,:) = nan;
    
   
    deltaev =  totev - totevminus;

    chosen = get_from_mat(pmat,'choiceTrial');
    block = get_from_mat(pmat,'block');
    game = get_from_mat(pmat,'game');

    % ---- regressors for analysis
    allvar  = [totevminus(chidx) deltaev(chidx) trial(chidx) termination(chidx)];

    %% beh GLM --------------------------------------------------------------------------------
    
    regs_z = nannormalise([allvar]);

    %flip continue/stop
    cont_ch = cont_ch-1;
    cont_ch(find(cont_ch==-1)) = 1;

        
    %% save:
    allbeta.subid = subid;
    allbeta.regs = allvar;
    allbeta.regs_z = regs_z;
    allbeta.cont_ch = cont_ch(chidx);

    % save output
    betasub{isub}      = allbeta;


end




%% GLMM
regs_all = []; regs_all_noz = [];
N_pmat = size(betasub{1}.regs,2);
N_betas = size(regs_z,2)+1;

for s = 1:length(betasub)
    thisregs = [betasub{s}.cont_ch, betasub{s}.regs_z];
    thisregs(:,N_pmat+2) = repmat(betasub{s}.subid, [1,size(thisregs,1)]);
    regs_all = [regs_all; thisregs];
    thisregs_noz = [betasub{s}.cont_ch, betasub{s}.regs];
    thisregs_noz(:,N_pmat+2) = repmat(betasub{s}.subid, [1,size(thisregs_noz,1)]);
    regs_all_noz = [regs_all_noz; thisregs_noz];
end


regs_all_tab = splitvars(table(regs_all));
regs_all_tab.Properties.VariableNames = {'cont_ch', 'totevminus', 'deltaev', 'trial', 'termination', 'userID'};
regs_all_tab_noz = splitvars(table(regs_all_noz));
regs_all_tab_noz.Properties.VariableNames = {'cont_ch', 'totevminus', 'deltaev', 'trial', 'termination', 'userID'};

restoredefaultpath

pcont_mmdl = fitglme(regs_all_tab, 'cont_ch ~ 1 + totevminus + deltaev + trial + termination + trial:termination + totevminus:termination + deltaev:termination + (totevminus + deltaev + trial + termination + trial:termination + totevminus:termination + deltaev:termination | userID)', 'Distribution', 'binomial','Link','logit')



% plot
%addpath(genpath('C:\Users\mdelrio\Documents\MATLAB\4magda_fromNadescha\MEG'));

[B,BNames,stats]= fixedEffects(pcont_mmdl);

stats_toplot = [stats(4:5,:); stats(2:3,:)];

varnames = {'trial', 'horizon', 'totevminus', 'deltaev'}

N = size(varnames,2);

figure
hold on
scatter([1:4], stats_toplot.Estimate(1:4), [], 'k',  'filled')
e = errorbar([1:4], stats_toplot.Estimate(1:4), stats_toplot.SE(1:4), 'vertical', 'LineStyle', 'none', 'Color', 'k')
e.CapSize = 0;
e.LineWidth = 1;
% ylim([0, 2.5])
xlim([0.5,4.5])
set(gcf,'color','w'); set(gca,'XTick',1:4,'XTickLabel', varnames,'FontSize',14);





