%clear all;clc;
Folder = 'C:\Users\Ayanohikaru\Desktop\a\Mat_data';
cd(Folder);
extract = dir('*nm.mat');
extract = {extract.name}';
extract = extract(3:end);
%%
for i_i = 1:length(extract)
    clearvars n_PULSE n_SpO2 n_RESP name_mat nameECG_mat
    name = extract{i_i};
    name = name(1:end-6);
    %% Load data nummeric
    cd(Folder);
    name_mat = strcat(name,'nm.mat');
    nameECG_edf = strcat(name,'.edf');
    load(name_mat,'val');val_numeric = val;
    cd('C:\Users\Ayanohikaru\Desktop\a\EDF');
    [~,val_ECG]=edfread(nameECG_edf);
    %% Load header
    %%cd('E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\INFO');
    addpath('E:\MIMIC II WAVEFORM DATABASE\RAW MIMIC II DATABASE\PRE_GENERATED RECORD');
    name_info = strcat(name,'nm.hea');
    nameECG_info = strcat(name,'m.hea');
    %% Load each data in numeric file
    m_heaFid = fopen(name_info, 'rt')
    m_header = textscan(fgetl(m_heaFid), '%s %f %f %d %s %s','Delimiter',' ');  %get first line from header
    for n = 1:size(val_numeric,1)
        m_signal = textscan(fgetl(m_heaFid), '%s %s %s %d %d %d %d %d %s','Delimiter',' ');
        n_sigCheck = m_signal{9}
        n_sigCheck = n_sigCheck{1}
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
    %% Load gain base
    m_infoName = strcat(name,'m.info');
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
    %% Load ECG & PPG
    m_heaFid = fopen(nameECG_info, 'rt')
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
                n_ECG = n_ECG(1,1:length_data);
            case 'PPG'
                n_PPG = val_ECG(n,:);
                n_PPG(n_PPG==-32768) = NaN;
                n_PPG = (n_ECG - m_base(n)) ./ m_gain(n);
                n_PPG = n_PPG(1,1:length_data);
        end
        %% Check if n_PULSE exist
        if (exist('n_PPG','var')==1)
            disp(name);
        end
    end
    fclose('all');
    
    %% save workspace
    try
        cd('C:\Users\Ayanohikaru\Desktop\a\Numeric');
        if (exist('n_PPG','var')==1)
            save(name_mat,'n_PULSE','n_RESP','n_SpO2','n_ECG','n_PPG');
        else
            save(name_mat,'n_PULSE','n_RESP','n_SpO2','n_ECG');
        end
    catch
        disp(name);
    end
end


