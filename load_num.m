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
fclose(n_heaFid);
%% Load info
name_info = strcat(name,'nm.info');
n_infoFid = fopen(name_info, 'rt');
fgetl(n_infoFid); fgetl(n_infoFid); %skip 3 line of info file
fgetl(n_infoFid);
fgetl(n_infoFid);
fgetl(n_infoFid); %skip signal header string
%read signal list into workspace
for i = 1:size(val_numeric,1)
    [n_row(i), n_signal(i), n_gain(i), n_base(i), n_units(i)]=strread(fgetl(n_infoFid),'%d%s%f%f%s','delimiter','\t');
end
fclose(n_infoFid);
for n = 1:size(val_numeric,1)
    n_sigCheck = n_signal{n};
    switch n_sigCheck
        case 'SpO2'
            n_SpO2 = val_numeric(n,:);
            n_SpO2(n_SpO2==-32768) = NaN;
            n_SpO2 = (n_SpO2 - n_base(n)) ./ n_gain(n);
        case 'HR'
            n_HR = val_numeric(n,:);
            n_HR(n_HR==-32768) = NaN;
            n_HR = (n_HR - n_base(n)) ./ n_gain(n);
        case 'PULSE'
            n_PULSE = val_numeric(n,:);
            n_PULSE(n_PULSE==-32768) = NaN;
            n_PULSE = (n_PULSE - n_base(n)) ./ n_gain(n);
        case 'RESP'
            n_RESP = val_numeric(n,:);
            n_RESP(n_RESP==-32768) = NaN;
            n_RESP = (n_RESP - n_base(n)) ./ n_gain(n);
    end
    %% Check if n_PULSE exist
    if (exist('n_PULSE','var')==0)
        n_PULSE = n_HR;
    end
end
fclose('all');
%mSecStart = datestr(datenum(n_starttime),'DD:HH:MM:SS');
end