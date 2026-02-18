% function extractVOI(SPM_dir,ROI,ROI_size,eoi)
%
% function is used to extract a timeseries of a ROI (mask or MNI
% coordinates) from a SPM first-level GLM.
%
% @SPM_dir: single-subject SPM dir
% @ROI: either mask file (image file) or vector with MNI-coordinates
% @ROI_size: size of sphere if ROI is MNI coordinate
% @eoi: index for effect of interest (default: last contrast)
%
% Tobias HAuser, 02.12.2015
%
function extractVOI(SPM_dir,ROI,ROI_size,eoi)

voi = [];
currFol = pwd;

if ~nargin
    SPM_dir = [spm_select(1,'dir','select single-subject SPM-dir') '\'];
end

if nargin < 2 || isempty(ROI)
    inp = input('if using MNI coordinates please enter them as vector ([X Y Z]; otherwise: n):','s');
    if ~isempty(str2num(inp))
        ROI = str2num(inp);
        ROI_size = input('size of sphere in mm: ');
        voi.name = [inp '_' int2str(ROI_size)];
    else
        ROI = spm_select(1,'image','select mask image');
        ROI_size = [];
        [~,voi.name] = fileparts(ROI);
    end
else
    if nargin<3 || isempty(ROI_size)
        ROI_size = [];
        [~,voi.name] = fileparts(ROI);
    else
        voi.name = [num2str(ROI) '_' int2str(ROI_size)];
    end
end


%% load spm to get details
load([SPM_dir '\spm.mat']);
runs = length(SPM.Sess);
if nargin < 4 || isempty(eoi)
    eoi = length(SPM.xCon);
end
if ~strcmp(SPM.xCon(eoi).name,'eoi') && ~strcmp(SPM.xCon(eoi).name,'effect of interest')
    error(['effect of interest (contrast nr ' int2str(eoi) ' is not labeled as "effect of interest".'])
end

%% initialize spm
% spm('defaults', 'fmri');
% spm_jobman('initcfg');

%% run VOI generation
for run=1:runs
    fprintf(['running session ' int2str(run) '...'])
    spmmat = [SPM_dir 'SPM.mat'];
    clear voibatch
    voibatch{1}.spm.util.voi.spmmat = {spmmat};
    voibatch{1}.spm.util.voi.adjust = eoi;                                % contrast number of "effect of interest"
    voibatch{1}.spm.util.voi.session = run;                               % session/run number
    voibatch{1}.spm.util.voi.name = voi.name;
    if isempty(ROI_size)
        voibatch{1}.spm.util.voi.roi{1}.mask.image = {ROI};
        voibatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
    else
        voibatch{1}.spm.util.voi.roi{1}.sphere.centre = ROI;
        voibatch{1}.spm.util.voi.roi{1}.sphere.radius = ROI_size;
        voibatch{1}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
    end
    voibatch{1}.spm.util.voi.expression = 'i1';
    spm_jobman('run',voibatch(1));
    fprintf(' done.\n')
end

%% move VOIs
out_dir = [SPM_dir 'VOI\'];
mkdir(out_dir);
try
    movefile([SPM_dir 'VOI*'],out_dir);
catch
    warning(['not able to move Files']);
end

%% clean up
cd(currFol)

display('all done.')
