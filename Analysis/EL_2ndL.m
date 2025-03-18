function EL_2ndL(analysis_num)
% 
if isinteger(analysis_num) || isnumeric(analysis_num)
    analysis_num = num2str(analysis_num,'%02d');
end

%%


l1_dir = 'D:\InformationGatheringMRI\derivatives\';

files1 = dir(l1_dir);

% Filter out items that are not directories and ensure names start with 'sub-' followed by digits only
isDir = [files1.isdir];
names = {files1(isDir).name};
matches = regexp(names, '^sub-\d+$', 'match');

bool = cellfun(@(x) ~isempty(x), matches);

% Filter the original list to keep only participant folders with 'sub-###' format
files = files1(isDir);
files = files(bool);
sl = [];

for s = 1:length(files)
    %subject loop begins
    % subject = str2double(regexp(files(i).name, '\d+', 'match'));
  
     %make sure we're in correct subject's func folder
    sl{s} = [l1_dir files(s).name  '\1stL\' analysis_num  ];
end

sl(21) = [];

 res_dir = ['D:\InformationGatheringMRI\derivatives\Analysis\2ndL\' analysis_num '\'];
mkdir(res_dir)

% %% get sl
% list = dir([l1_dir '1*']);
% for s = 1:length(list)
%     sl(s) = str2num(list(s).name);
% end


%% load one subject & get cons
load([sl{1} '\SPM.mat'])
con_names = {SPM.xCon(:).name};

%% get filenames and check con names
fprintf('checking cons for consistency')
for s = 1:length(sl)
    for c = 1:length(con_names)
        if ~strcmp(con_names{c},SPM.xCon(c).name)
            error(['subject ' int2str(sl(s)) ': contrast ' int2str(c) ': names do not match (' con_names{c} ' vs  ' SPM.xCon(c).name])
        end
        con_fls{c,s} =strcat(string(sl(s)), '\', SPM.xCon(c).Vcon.fname, ',1');
    end
end

%% SPM batch
spm('defaults', 'fmri');
spm_jobman('initcfg');

for c = 1:size(con_fls,1)
    clear matlabbatch
    
    if ~isempty(strfind(con_names{c},'*'))  % replace '8' because it doescnt work for dirs
        con_names{c}(strfind(con_names{c},'*')) = '_';
    end
    
    tmp_dir = [res_dir con_names{c} '\'];
    mkdir(tmp_dir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {tmp_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(con_fls(c,:)');
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    %% estimate parameters
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[tmp_dir '\SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    %% define contrasts
    matlabbatch{3}.stats{1}.con.spmmat = {[tmp_dir '\SPM.mat']};
    matlabbatch{3}.stats{1}.con.consess{1}.tcon.name = con_names{c};
    matlabbatch{3}.stats{1}.con.consess{1}.tcon.convec = [1];
    matlabbatch{3}.stats{1}.con.consess{2}.tcon.name = ['-' con_names{c}];
    matlabbatch{3}.stats{1}.con.consess{2}.tcon.convec = [-1];
    
    %% results
%     matlabbatch{4}.spm.stats.results.spmmat = {[tmp_dir '\SPM.mat']};
%     matlabbatch{4}.spm.stats.results.conspec(1).titlestr = con_names{c};
%     matlabbatch{4}.spm.stats.results.conspec(1).contrasts = Inf;
%     matlabbatch{4}.spm.stats.results.conspec(1).threshdesc = 'FWE';
%     matlabbatch{4}.spm.stats.results.conspec(1).thresh = 0.05;
%     matlabbatch{4}.spm.stats.results.conspec(1).extent = 0;
%     matlabbatch{4}.spm.stats.results.conspec(1).mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
%     matlabbatch{4}.spm.stats.results.units = 1;
%     matlabbatch{4}.spm.stats.results.print = true;
    
    
    %% run batches
    for i = 1:length(matlabbatch)
        spm_jobman('run',matlabbatch(i));
    end
end