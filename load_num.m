function [n_SpO2,n_PULSE,n_RESP] = load_num(name)
%% Setup
Folder = 'E:\Thesis\Firmware\Data\Mat_num';
cd(Folder);

% Name of record - Load data
mat_num = strcat(name,'nm.mat');
load(name_mat,'val_numeric');

%% Load header
name_info = strcat(name,'nm.hea');
m_heaFid = fopen(name_info, 'rt');
m_header = textscan(fgetl(m_heaFid), '%s %f %f %d %s %s','Delimiter',' ');  %get first line from header
m_starttime = m_header{6};
m_starttime = m_starttime{1};
for n = 1:size(val_numeric,1)
    m_signal = textscan(fgetl(m_heaFid), '%s %s %s %d %d %d %d %d %s','Delimiter',' ');
    n_sigCheck = m_signal{9};
    n_sigCheck = n_sigCheck{1};
    switch n_sigCheck
        case 'SpO2'
            n_SpO2 = val_numeric(n,:);
            n_SpO2(n_SpO2==-32768) = NaN;
            n_SpO2 = n_SpO2./10;
        case 'HR'
            n_HR = val_numeric(n,:);
            n_HR(n_HR==-32768) = NaN;
            n_HR = n_HR./10;
        case 'PULSE'
            n_PULSE = val_numeric(n,:);
            n_PULSE(n_PULSE==-32768) = NaN;
            n_PULSE = n_PULSE./10;
        case 'RESP'
            n_RESP = val_numeric(n,:);
            n_RESP(n_RESP==-32768) = NaN;
            n_RESP = n_RESP./10;
    end
    %% Check if n_PULSE exist
    if (exist('n_PULSE','var')==0)
        n_PULSE = n_HR;
    end
end
fclose('all');
%% Scale timeline
n_starttime =
end