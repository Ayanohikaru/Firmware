function m_ECG = load_ECG(name)

%% Setup
Folder_edf = 'E:\Thesis\Firmware\Data\EDF';
Folder_mat = 'E:\Thesis\Firmware\Data\Mat_ecg';
Folder_header = 'E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\PRE_GENERATED RECORD';

% Name of record - Load data
name_mat = strcat(name,'m.mat');
name_edf = strcat(name,'.edf');

[struct,val_ECG]=edfread(nameECG_edf);
%% Load header
addpath(Folder_header);
name_info = strcat(name,'m.hea');
infoName = strcat(name,'m.info');
m_infoFid = fopen(m_infoName, 'rt');
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
 m_heaFid = fopen(nameECG_info, 'rt');
    m_header = textscan(fgetl(m_heaFid), '%s %f %f %d %s %s','Delimiter',' ');  %get first line from header
    for n = 1:size(val_ECG,1)
        m_signal = textscan(fgetl(m_heaFid), '%s %s %s %d %d %d %d %d %s','Delimiter',' ');
        n_sigCheck = m_signal{9};
        n_sigCheck = n_sigCheck{1};
        switch n_sigCheck
            case 'II'
                n_ECG = val_ECG(n,:);
                n_ECG(n_ECG==-32768) = NaN;
                n_ECG = (n_ECG - m_base(n)) ./ m_gain(n);
            case 'PPG'
                n_PPG = val_ECG(n,:);
                n_PPG(n_PPG==-32768) = NaN;
                n_PPG = (n_ECG - m_base(n)) ./ m_gain(n);
        end
        %% Check if n_PULSE exist
        if (exist('n_PPG','var')==1)
            disp(name);
        end
    end
    fclose('all');
    
%% Scale timeline
n_starttime = struct.startitme;
m_starttime =
end