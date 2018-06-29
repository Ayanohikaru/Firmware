function [m_RESP,m_PPG,m_ECG,m_starttime] = load_ECG(name)
%% Setup
Folder_edf = 'E:\Thesis\Firmware\Data\EDF';
Folder_mat = 'E:\Thesis\Firmware\Data\Mat_ecg';
Folder_header = 'E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\PRE_GENERATED RECORD';
addpath('E:\Thesis\Firmware');
cd(Folder_edf);
% Name of record - Load data
name_mat = strcat(name,'m.mat');
name_edf = strcat(name,'.edf');
[struct,val_ECG]=edfread(name_edf);
m_starttime = struct.starttime;
m_starttime = strcat(m_starttime(1:2),':',m_starttime(4:5),':',m_starttime(7:8));
%% Load header
cd(Folder_header);
%name_info = strcat(name,'m.hea');
infoName = strcat(name,'m.info');
m_infoFid = fopen(infoName, 'rt');
fgetl(m_infoFid); fgetl(m_infoFid); %skip 3 line of info file
fgetl(m_infoFid);
fgetl(m_infoFid);
fgetl(m_infoFid); %skip signal header string
%read signal list into workspace
for i = 1:size(val_ECG,1)
    [m_row(i), m_signal(i), m_gain(i), m_base(i), m_units(i)]=strread(fgetl(m_infoFid),'%d%s%f%f%s','delimiter','\t');
end
fclose(m_infoFid);
%% Load data ECG & PPG
m_RESP = [];
m_PPG = [];
% m_heaFid = fopen(name_info, 'rt');
% m_header = textscan(fgetl(m_heaFid), '%s %f %f %d %s %s','Delimiter',' ');  %get first line from header
for n = 1:size(val_ECG,1)
    m_sigCheck = m_signal{n};
    switch m_sigCheck
        case 'II'
            m_ECG = val_ECG(n,:);
            m_ECG(m_ECG==-32768) = NaN;
            m_ECG = (m_ECG - m_base(n)) ./ m_gain(n);
        case 'PPG'
            m_PPG = val_ECG(n,:);
            m_PPG(m_PPG==-32768) = NaN;
            m_PPG = (m_PPG - m_base(n)) ./ m_gain(n);
        case 'RESP'
            m_RESP = val_ECG(n,:);
            m_RESP(m_RESP==-32768) = NaN;
            m_RESP = (m_RESP - m_base(n)) ./ m_gain(n);
    end
end
fclose('all');
%% Scale timeline
%mSecStart = datestr(datenum(m_starttime),'DD:HH:MM:SS');
end