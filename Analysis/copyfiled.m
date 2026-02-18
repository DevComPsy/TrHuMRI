path = 'D:\InformationGatheringMRI\derivatives'
destinationDir = 'E:\Physio_regressors';     % <-- replace with your actual path
sourceParentDir = 'D:\InformationGatheringMRI\derivatives'; % <-- replace with your actual path

allItems = dir([path,'/sub-*'])
allFolders = allItems([allItems.isdir]); % Only keep directories

% Remove '.' and '..'
allFolders = allFolders(~ismember({allFolders.name}, {'.', '..'}));

% Loop through each folder
for i = 1:length(allFolders)
    folderName = allFolders(i).name;
    fullFolderPath = fullfile(sourceParentDir, folderName);
    
    % Define source physio path
    physioSource = fullfile(fullFolderPath, 'physio');
    
    % Check if physio folder exists
    if exist(physioSource, 'dir')
        % Define destination path (e.g., /destination/folderName/physio)
        destPath = fullfile(destinationDir, folderName, 'physio');
        
        % Create destination folder if it doesn't exist
        if ~exist(destPath, 'dir')
            mkdir(destPath);
        end
        
        % Copy the physio folder
        copyfile(physioSource, destPath);

        fprintf('Copied physio from %s to %s\n', physioSource, destPath);
    else
        fprintf('No physio folder found in %s\n', fullFolderPath);
    end
end