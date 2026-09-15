function mri = TrHu_1stL_bigModel_withNewHorizon(mri)
% big model controlling for collapsing boundaries (new horizon)

analysis_num = 'big_model_with_new_horizon';

mri.epi_params.orth = 0;

%% general setup
res_dir = ['D:\Observational Study\Information_gathering-main\Analysis\new\1stL\' analysis_num '\' num2str(mri.ID) '\'];
mkdir(res_dir);
%general functions
addpath(genpath('D:\BE Code\gen_funct-master'));
%MRI toolbox
addpath(genpath('D:\Observational Study\Information_gathering-main\MRI-master'))
%% aggregate beh data
ons =  load(['D:\Observational Study\Information_gathering-main\Analysis\BEH\' num2str(mri.ID) '\' num2str(mri.ID) 'onsets_struct.mat']);
beh =  load(['D:\Observational Study\Information_gathering-main\Analysis\BEH\' num2str(mri.ID) '\' num2str(mri.ID) 'beh_regs.mat']);

if strcmp(mri.ID, '102')
   mri.nblocks =3;
end


for m = 1:mri.nblocks
    scans{m,1} = ['D:\Observational Study\Information_gathering-main\Analysis\sub-' num2str(mri.ID) '\func\' mri.epi_dirs{m}];

    %replace NaNs with mean of deltaEV
    beh.beh_regs(m).deltaev(isnan(beh.beh_regs(m).deltaev))= mean(beh.beh_regs(m).deltaev(~isnan(beh.beh_regs(m).deltaev)));

    %replace NaNs with mean of totevminus
    beh.beh_regs(m).totevminus(isnan(beh.beh_regs(m).totevminus))= mean(beh.beh_regs(m).totevminus(~isnan(beh.beh_regs(m).totevminus)));

    % get paths to movement regressors
    path_to_move_params{m} =  {['D:\Observational Study\Information_gathering-main\Analysis\Physio_regressors\sub-' num2str(mri.ID)...
        '\physio\multiple_regressors_new-run' num2str(m) '.txt']};

    %remove nans from points
    beh.beh_regs(m).points(isnan(beh.beh_regs(m).points)) = [];

    % zscore prob_choice
    beh.beh_regs(m).prob_choice = nanzscore(beh.beh_regs(m).prob_choice);
    %replace NaNs in prob_choice with minimum z-score
    beh.beh_regs(m).prob_choice(isnan(beh.beh_regs(m).prob_choice)) = min(beh.beh_regs(m).prob_choice, [], "omitmissing");
  
    %make first regressor of points 0 if all correct points
    if unique(beh.beh_regs(m).points) == 2

        beh.beh_regs(m).points(1) = 0;
    end 
end 

if strcmp(mri.ID, '122')
   ons.beh(2).cue_pres(200) = [];
end

%% spm glm
matlabbatch{1}.spm.stats.fmri_spec.dir =  {res_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = mri.epi_params.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% loop through runs
for b=1:mri.nblocks
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).scans = cellstr(scans{b}); %scans{b}; 
    
    n=1;
    % cues
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).name = 'cues';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).onset = ons.beh(b).cue_pres;
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).tmod = 0;
    %delta ev
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(1).name = 'daEV';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(1).param = zscore(beh.beh_regs(b).deltaev);
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(1).poly = 1;     
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).orth = mri.epi_params.orth;
    %trial number
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(2).name = 'new_horizon';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(2).param = zscore(beh.beh_regs(b).new_horizon);
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(2).poly = 1;     
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).orth = mri.epi_params.orth;
    %total ev minus
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(3).name = 'totevminus';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(3).param = zscore(beh.beh_regs(b).totevminus);
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(3).poly = 1;     
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).orth = mri.epi_params.orth;
    %total ev (current)
    % matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).name = 'totev';
    % matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).param = zscore(beh.beh_regs(b).totev);
    % matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).poly = 1;     
    % matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).orth = mri.epi_params.orth;
    % horizon
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).name = 'horizon';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).param = zscore(beh.beh_regs(b).horizon);
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).pmod(4).poly = 1;     
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).orth = mri.epi_params.orth;
   
    n=n+1;
    % outcome
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).name = 'outcome';
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).onset = ons.beh(b).outcome;
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).tmod = 0;

    % further settings (movement and physiological parameters)
    %if num2str(mri.ID) ~= 108 & b ~= 4 %skip 108 block 4
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).multi_reg =  path_to_move_params{b};
       % matlabbatch{1}.spm.stats.fmri_spec.sess(b).multi_reg = {};  % TODO
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).hpf = 128;
    %end 
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;%0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% estimate parameters
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[res_dir 'SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% contrast definition
roi = 6;   % regressors of interest

%obtain number of nuisance regressors (physiological)
    for b = 1:mri.nblocks
         n_phys_regressors = width(readtable(char(path_to_move_params{b})));
         nui_r(b) = n_phys_regressors;
    end
%else 
  %  nui_r(b) = 0;
%end 

n=1;
cons(n).name = 'cues';
cons(n).regr = [1];

n=n+1;
cons(n).name = 'daEV';
cons(n).regr = [0 1];

n=n+1;
cons(n).name = 'new_horizon';
cons(n).regr = [0 0 1];

n=n+1;
cons(n).name = 'totevminus';
cons(n).regr = [0 0 0 1];


n=n+1;
cons(n).name = 'horizon';
cons(n).regr = [0 0 0 0 1];

n=n+1;
cons(n).name = 'outcome';
cons(n).regr = [0 0 0 0 0 1];

matlabbatch{3}.stats{1}.con.spmmat = {[res_dir 'SPM.mat']};

for n = 1:length(cons)
    matlabbatch{3}.stats{1}.con.consess{n*2-1}.tcon.name = cons(n).name;
    r = zeros(1,roi); r(1:length(cons(n).regr)) = cons(n).regr;

    if strcmp(mri.ID, '102')
       matlabbatch{3}.stats{1}.con.consess{n*2-1}.tcon.convec = [r zeros(1,nui_r(1)) r zeros(1,nui_r(2)) r zeros(1,nui_r(3))];
    else
        matlabbatch{3}.stats{1}.con.consess{n*2-1}.tcon.convec = [r zeros(1,nui_r(1)) r zeros(1,nui_r(2)) r zeros(1,nui_r(3)) r zeros(1,nui_r(4))];
    end
    
    matlabbatch{3}.stats{1}.con.consess{n*2}.tcon.name = ['-' matlabbatch{3}.stats{1}.con.consess{n*2-1}.tcon.name];
    matlabbatch{3}.stats{1}.con.consess{n*2}.tcon.convec = matlabbatch{3}.stats{1}.con.consess{n*2-1}.tcon.convec .*-1;
end

%% run batches
for i = 1:length(matlabbatch)
    spm_jobman('run',matlabbatch(i));    
end
