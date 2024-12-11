beh_dir = 'Z:\ARCHIVE\InformationGatheringMRI\sourcedata\RAW\beh';
physio_dir = 'D:\InformationGatheringMRI\sourcedata\RAW\physio';
output_dir = 'D:\InformationGatheringMRI\derivatives';
cd(beh_dir)
listsub = dir(beh_dir);
listsub = listsub(~ismember({listsub(:).name},{'.','..'}));
listoutput = dir(output_dir);
listoutput = listoutput([listoutput(:).isdir] & strncmp({listoutput(:).name}, 'sub-', 4));

% Beh
% for i = 2:length(listsub)
%     beh_dir_sub = [beh_dir '\' listsub(i).name];
%     cd(beh_dir_sub)
%     filename_target = dir('*block_4.mat');
%     filename = [filename_target.folder '\' filename_target.name];
%     load(filename,"user")
%     output_file = [output_dir '\sub-' num2str(user.ID) '\beh\'];
%     if ~exist("output_file",'dir')
%         mkdir(output_file)
%     end
% 
%     moveFile(beh_dir_sub, output_file, filename_target.name);
% 
% end
cd(physio_dir)
listsub = dir(physio_dir);
listsub = listsub(~ismember({listsub(:).name},{'.','..'}));

%physio
for i = length(listsub) -1
    physio_dir_sub = [physio_dir '\' listsub(i).name];
    cd(physio_dir_sub)
    filename_target = dir('*biopac.txt');
    user.ID = filename_target(1).folder(end-2:end);

    for j = 1:length(filename_target)
        filename = [filename_target(j).folder '\' filename_target(j).name];
        output_file = [output_dir '\sub-' num2str(user.ID) '\physio\'];

        if ~exist("output_file",'dir')
            mkdir(output_file)
        end

        moveFile(physio_dir_sub, output_file, filename_target(j).name);
    end
end


function moveFile(beh_dir, outputdir, filename)
% Define the full path for the source and destination
sourcePath = fullfile(beh_dir, filename);
destinationPath = fullfile(outputdir, filename);

% Check if the file exists in the behavior directory
if exist(sourcePath, 'file') == 2
    % Move the file to the output directory
    copyfile(sourcePath, destinationPath);
    fprintf('File "%s" has been moved from "%s" to "%s".\n', filename, beh_dir, outputdir);
else
    fprintf('File "%s" does not exist in "%s".\n', filename, beh_dir);
end
end