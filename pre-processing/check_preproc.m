% This tool shows the warped T1, the warped EPI, the warped smoothed EPI and the T1
% Template and sets the mapping_gl to histeq so that T1 has more contrast
% and it activates reorient to get a wireframe
%
% written by Steffen Bollmann, adapted by Tobias Hauser,
% 08.08.2013;23/08/18
%
function check_preproc(struct,epi_dir)

pathToTemplates = [spm('dir') '\canonical\'];




    %get image-paths
    
    % canonicalT1 reference
    images(1,:) = {[pathToTemplates,'single_subj_T1.nii']};
    
    % normalized structural
    try
        images(2,:) = {struct};
    catch
        images(2,:) = {spm_select(1,'image','select normalised structural file')};
    end
    
    
    % normalized EPI
    try
        if ~strcmp(epi_dir(end),'/') && ~strcmp(epi_dir(end),'\')
            epi_dir = [epi_dir '\'];
        end
        list = dir([epi_dir 'w*']);
        epi = [epi_dir list(randi(floor(length(list)/2))).name];
        images(3,:) = {epi};
    catch
        images(3,:) = {spm_select(1,'image','select normalised EPI file')};
    end
    
    
    

    %call SPM checkreg
    spm_check_registration(char(images));
    
    %show wireframe by opening reorient
    spm_orthviews('reorient','context_init',1);
    
    %set global mapping to histeq to see more details in T1
%     spm_orthviews('context_menu','mapping_gl','histeq');
    
     
end
