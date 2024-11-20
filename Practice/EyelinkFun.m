% function na = EyelinkFun(varargin)
%
% either emulates Eyelink or directly forwards information to eyetracker
%
% TH 10.14
%
function na = EyelinkFun(varargin)

global params

if params.general.eyelink
    
    na = Eyelink(varargin{1},varargin{2});
    
else

    if strcmp(varargin(1),'Openfile')
        save([varargin{2} '.edf'])
    end

    na = 0;

end