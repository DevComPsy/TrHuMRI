function mri = TrHu_1stL_single_trial2(mri)

analysis_num = 'cues_single_trial';
mri.epi_params.orth = 0;

%% additional paths
addpath(genpath('D:\BE Code\gen_funct-master'));
addpath(genpath('D:\Observational Study\Information_gathering-main\MRI-master'))

%% general setup
res_dir = ['D:\Observational Study\Information_gathering-main\Analysis\new\1stL\' analysis_num '\' num2str(mri.ID) '\'];
if ~exist(res_dir,'dir'), mkdir(res_dir); end

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

    %zscore delta_ev
    beh.beh_regs(m).deltaev = zscore(beh.beh_regs(m).deltaev);

    %make first regressor of points 0 if all correct points
    if unique(beh.beh_regs(m).points) == 2
        beh.beh_regs(m).points(1) = 0;
    end 
end 

if strcmp(mri.ID, '122')
   ons.beh(2).cue_pres(200) = [];
end

if strcmp(mri.ID, '114')
   idx = 2;

    ons.beh(idx) = [];
    scans(idx) = [];
    path_to_move_params(idx) = [];
end

if strcmp(mri.ID, '118')
   idx = 1:3;

    ons.beh = ons.beh(idx);
    scans =  scans(idx);
    path_to_move_params = path_to_move_params(idx);
end

if strcmp(mri.ID, '120')
   idx = 2:4;

    ons.beh = ons.beh(idx);
    scans =  scans(idx);
    path_to_move_params = path_to_move_params(idx);
end


%% spm glm specification
matlabbatch = {}; % ensure clean
matlabbatch{1}.spm.stats.fmri_spec.dir =  {res_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = mri.epi_params.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% loop through runs
for b=1:3%mri.nblocks
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).scans = cellstr(scans{b}); 
    n = 1;
    for t = 1:length(ons.beh(b).cue_pres)
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).name = ['cues' int2str(b) '_t' int2str(t)];
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).onset = ons.beh(b).cue_pres(t);
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(b).cond(n).tmod = 0;
        n = n+1;
    end

    % movement / physio regressors
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).multi_reg =  path_to_move_params{b};
    matlabbatch{1}.spm.stats.fmri_spec.sess(b).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% estimation batch
matlabbatch{2}.spm.stats.fmri_est.spmmat = {[fullfile(res_dir, 'SPM.mat')]};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% RUN SPECIFICATION + ESTIMATION (batches 1 and 2)
spm_jobman('run', matlabbatch(1:2));

%% --- Load the estimated SPM and build contrasts ---
load(fullfile(res_dir,'SPM.mat')); % requires the estimation to have been run

% find cue regressors by name 
cue_idx = find(contains(SPM.xX.name, 'cues'));
if isempty(cue_idx)
    % try a second pattern if necessary
    cue_idx = find(contains(SPM.xX.name, 'cues') | contains(SPM.xX.name,'cues_t'));
end

if isempty(cue_idx)
    error('No cue regressors found in SPM.xX.name. Run disp(SPM.xX.name) for debugging.');
end

% build an average contrast over all cue regressors
convec = zeros(1, size(SPM.xX.X, 2));
convec(cue_idx) = 1 / numel(cue_idx);

% build contrast batch
matlabbatch = {}; % reset so we only run contrast job next
matlabbatch{1}.stats{1}.con.spmmat = {[fullfile(res_dir,'SPM.mat')]};

matlabbatch{1}.stats{1}.con.consess{1}.tcon.name = 'cues_all_trials';
matlabbatch{1}.stats{1}.con.consess{1}.tcon.convec = convec;
matlabbatch{1}.stats{1}.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{1}.stats{1}.con.consess{2}.tcon.name = '-cues_all_trials';
matlabbatch{1}.stats{1}.con.consess{2}.tcon.convec = -convec;
matlabbatch{1}.stats{1}.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{1}.stats{1}.con.delete = 0;

%% RUN CONTRASTS
spm_jobman('run', matlabbatch);

%mri = mri_set_history(mri,['1stL GLM, analysis No. ' analysis_num]);
end
