function [n_fs,n_SpO2,n_PULSE,n_RESP,n_starttime] = load_num(name)
%% Setup
Folder = 'E:\Thesis\Firmware\Data\Mat_num';
Folder_header = 'E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\PRE_GENERATED RECORD';
cd(Folder);

% Name of record - Load data
val_numeric = [];
mat_num = strcat(name,'nm.mat');
load(mat_num); val_numeric = val;

%% Load info
cd(Folder_header);
name_info = strcat(name,'nm.info');
n_infoFid = fopen(name_info, 'rt');
[n_starttime] = textscan(fgetl(n_infoFid), '%s %s %s %s','Delimiter','[');
n_starttime = strcat('[',n_starttime{2});
n_starttime = n_starttime{1};
n_starttime = n_starttime(2:9);
fgetl(n_infoFid); %skip 3 line of info file
fgetl(n_infoFid);
[n_fs] = textscan(fgetl(n_infoFid), '%s %s %s %s %s %s %d %s','Delimiter',' ');
n_fs = n_fs{3};
n_fs = str2num(n_fs{1});
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