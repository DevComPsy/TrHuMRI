function [ID pract] = getPractDlg()

prompt = {'Subject ID','Practice num'};
dlg_title = 'Treasure Hunt';
num_lines = 1;
def = {'','0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

ID = str2num(answer{1});
pract = str2num(answer{2});

end