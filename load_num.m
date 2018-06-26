function [n_fs,n_SpO2,n_PULSE,n_RESP,n_starttime] = load_num(name)
%% Setup
Folder = 'E:\Thesis\Firmware\Data\Mat_num';
Folder_header = 'E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\PRE_GENERATED RECORD';
cd(Folder);

% Name of record - Load data
val_numeric = [];
mat_num = strcat(name,'nm.mat');
load(mat_num); val_numeric = val;

%% Load header
cd(Folder_header);
name_info = strcat(name,'nm.hea');
n_heaFid = fopen(name_info, 'rt');
n_header = textscan(fgetl(n_heaFid), '%s %f %f %d %s %s','Delimiter',' ');  %get first line from header
n_starttime = n_header{6};
n_starttime = n_starttime{1};
n_fs = n_header{3};
for n = 1:size(val_numeric,1)
    n_signal = textscan(fgetl(n_heaFid), '%s %s %s %d %d %d %d %d %s','Delimiter',' ');
    n_sigCheck = n_signal{9};
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
%mSecStart = datestr(datenum(n_starttime),'DD:HH:MM:SS');
end