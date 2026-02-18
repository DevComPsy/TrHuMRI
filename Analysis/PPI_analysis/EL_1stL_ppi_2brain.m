function mri = EL_1stL_ppi_2brain(mri,analysis_num,voi1,voi2)


%% additional paths
addpath('D:\myDocuments\work\Projects\Tasks\EffortLearning\analysis\BEH\mainstudy\');
addpath('D:\myDocuments\work\Projects\Tasks\EffortLearning\modelling\v02\');

%% general setup
mri.res_dir(1) = 'C';
ppi_dir = [mri.res_dir 'MRI\1stL\' analysis_num '_ppi_' voi1 '_' voi2 '\' int2str(mri.ID) '\'];
spm_dir = [mri.res_dir 'MRI\1stL\' analysis_num '\' int2str(mri.ID) '\'];
mkdir(ppi_dir);


%% Start SPM
spm('defaults', 'fmri');
spm_jobman('initcfg');

%% get info from org SPM
load([spm_dir 'SPM.mat']);
% n=1; clear regn regi 
% for u = 1:length(SPM.Sess(1).U)
%     for u2 = 1:length(SPM.Sess(1).U(u).name)-1  % ignore names of main effects
%         regn{n} = SPM.Sess(1).U(u).P(u2).name;
%         regi(n,:) = [u u2+1];   % add 1 as these are PMs
%         n = n+1;
%     end
% end
% eff = regi(find(strcmp(regn,coi)),:);

%% create PPI data for each session
clear matlabbatch
for n = 1:length(SPM.Sess)
    matlabbatch{n}.spm.stats.ppi.spmmat = {[spm_dir 'SPM.mat']};
    matlabbatch{n}.spm.stats.ppi.type.phipi.voi = {[spm_dir 'VOI\VOI_' voi1 '_' int2str(n) '.mat']
        [spm_dir 'VOI\VOI_' voi2 '_' int2str(n) '.mat']};
    matlabbatch{n}.spm.stats.ppi.name = [analysis_num '_' voi1 '_' voi2 '_' int2str(n)];
    matlabbatch{n}.spm.stats.ppi.disp = 1;
end

%% run and copy file
for i = 1:length(matlabbatch);
    spm_jobman('run',matlabbatch(i));    
    movefile([spm_dir 'PPI_' matlabbatch{i}.spm.stats.ppi.name '.mat'],ppi_dir);
    PPI{i} = load([ppi_dir 'PPI_' matlabbatch{i}.spm.stats.ppi.name '.mat']);
end

%% set up proper PPI-GLM
matlabbatch2{1}.spm.stats.fmri_spec.dir =  {ppi_dir};
matlabbatch2{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch2{1}.spm.stats.fmri_spec.timing.RT = PPI{1}.PPI.RT;
matlabbatch2{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch2{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for s = 1:length(SPM.Sess)
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).scans = cellstr(mri.epis{s}(:));
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(1).name = ['PPI_' matlabbatch{s}.spm.stats.ppi.name '_Interaction'];       
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(1).val = PPI{s}.PPI.ppi';
    
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(2).name = ['PPI_' voi1];
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(2).val = PPI{s}.PPI.Y';
    
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(3).name = ['PPI_' voi2];
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).regress(3).val = PPI{s}.PPI.P';
    
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).multi = {''};
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).multi_reg = {mri.physio.mul_reg_fl{s}};
    matlabbatch2{1}.spm.stats.fmri_spec.sess(s).hpf = 128;

end


matlabbatch2{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch2{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch2{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch2{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch2{1}.spm.stats.fmri_spec.mthresh = 0.2;%0.8;
matlabbatch2{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch2{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

%% estimate parameters
matlabbatch2{2}.spm.stats.fmri_est.spmmat = {[ppi_dir '\SPM.mat']};
matlabbatch2{2}.spm.stats.fmri_est.method.Classical = 1;

%% contrast definition
for b = 1:mri.nblocks
    nui_r(b) = size(mri.physio.mul_reg{b},2);
end

matlabbatch2{3}.stats{1}.con.spmmat = {[ppi_dir '\SPM.mat']};
n=1; %1
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.name = 'Interaction';
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.convec = [1 0 0 zeros(1,nui_r(1)) 1 0 0 zeros(1,nui_r(2)) 1 0 0 zeros(1,nui_r(3)) 1 0 0 zeros(1,nui_r(4))];
n=n+1; %2
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.name = '-Interaction';
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.convec = [-1 0 0 zeros(1,nui_r(1)) -1 0 0 zeros(1,nui_r(2)) -1 0 0 zeros(1,nui_r(3)) -1 0 0 zeros(1,nui_r(4))];
n=n+1; %2
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.name = 'voi1';
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.convec = [0 1 0 zeros(1,nui_r(1)) 0 1 0 zeros(1,nui_r(2)) 0 1 0 zeros(1,nui_r(3)) 0 1 0 zeros(1,nui_r(4))];
n=n+1; %2
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.name = 'voi2';
matlabbatch2{3}.stats{1}.con.consess{n}.tcon.convec = [0 0 1 zeros(1,nui_r(1)) 0 0 1 zeros(1,nui_r(2)) 0 0 1 zeros(1,nui_r(3)) 0 0 1 zeros(1,nui_r(4))];




%% run batches
for i = 1:length(matlabbatch2);
    spm_jobman('run',matlabbatch2(i));
end

%% clean up
mri = mri_set_history(mri,['PPI analysis No. ' analysis_num ': ' voi1 ', ' voi2]);
disp('all done.')