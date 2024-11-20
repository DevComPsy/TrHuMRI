close all
clear all


SubjectID = input('Enter the Subject Number (3 digits): ');

while ~(isnumeric(SubjectID) && length(SubjectID)~=3)
    disp('Invalid input. Please enter a 3-digit number.');
    SubjectID = input('Enter the Subject Number (3 digits): ');

end
    SubjectID = sprintf('%03d', SubjectID);

disp(['Subject number entered: ', SubjectID]);
% addpath(genpath('C:\home\Neuroflux'))
% Run all function next to each other

while ~isempty(input('Press Enter to continue...', 's'))
end
disp('Continuing...');

% information_gathering(SubjectID,1);
% while ~isempty(input('Press Enter to continue...', 's'))
% end
% disp('Continuing...');

% information_gathering(SubjectID,2);
% while ~isempty(input('Press Enter to continue...', 's'))
% end
% disp('Continuing...');

% 
% information_gathering(SubjectID,3);
% while ~isempty(input('Press Enter to continue...', 's'))
% end
% disp('Continuing...');
information_gathering(SubjectID,4);
while ~isempty(input('Press Enter to continue...', 's'))
end
disp('Continuing...');