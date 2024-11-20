function [ID debug] = getIDdlg()

prompt = {'Subject ID','debug mode?'};
dlg_title = 'Treasure Hunt';
num_lines = 1;
def = {'','0'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

ID = str2num(answer{1});
debug = str2num(answer{2});

end