%% Filter signal
% cd('E:\Thesis\Firmware\Data\Signal');
% extract = dir();
% extract = {extract.name}';
% extract = extract(3:end);
% %for i_i = 1:length(extract)
%     clearvars RR_NM RR_MM RR_AS asth_locNM asth_locMM asth_locAS
%     cd('E:\Thesis\Firmware\Data\Signal');
%     name = extract{i_i};
%     load(name);
%     name = name(1:end-4);
%     name_mat = strcat(name,'.mat');

%% Seperate ECG
n_win = 125*(1/n_fs);
n_rsECG = reshape(m_ECG,n_win,[])';

%% Remove lost signal
nan_PULSE = isnan(n_PULSE);
nan_RESP = isnan(n_RESP);
nan_SpO2 = isnan(n_SpO2);
nan_PULSE = find(nan_PULSE==1);
nan_RESP = find(nan_RESP==1);
nan_SpO2 = find(nan_SpO2==1);

%% Find annotation
bs_PULSE = find(n_PULSE<10);
bs_RESP = find(n_RESP<2);
bs_SpO2 = find(n_SpO2<10);
%
bs_signal = unique([bs_PULSE bs_RESP bs_SpO2 nan_PULSE nan_RESP nan_SpO2]);
n_PULSE(bs_signal)=[];
n_RESP(bs_signal)=[];
n_SpO2(bs_signal)=[];
%% EXA
%% Mild/moderate : pulse [100-120], O2 [90-95]
asth_locNM = find((n_SpO2 >=95 & n_RESP < 21 & n_PULSE <100));
asth_locMM = find((n_SpO2 >=90 & n_SpO2 <=95 & n_RESP > 20 & n_RESP < 30 & n_PULSE <120 & n_PULSE >100));
% severe : pulse [100-120], O2 [90-95]
asth_locAS = find((n_SpO2 <90 & n_RESP > 30 & n_PULSE >= 120));

%% location array for ECG
n_loc = [1:size(n_rsECG,1)];
remove_MM = setdiff(n_loc,asth_locMM);
remove_NM = setdiff(n_loc,asth_locNM);
remove_AS = setdiff(n_loc,asth_locAS);
ecg_locNM = n_rsECG;
ecg_locNM(remove_NM,:) = [];
ecg_locMM = n_rsECG;
ecg_locMM(remove_MM,:) = [];
ecg_locAS = n_rsECG;
ecg_locAS(remove_AS,:) = [];
%% HRV extraction
cd('E:\Thesis\Firmware\Data\Window_Exa');
addpath('E:\Enlin\Thesis CD\Codes\ECG detection')
for i = 1:size(ecg_locNM,1)
    cd('E:\Thesis\Firmware\Data\Window_Exa\Normal');
    clearvars ERR
    textNameNM = strcat(name,'_','NM_W',num2str(i));
    m_IIs = ecg_locNM(i,:);
    m_fs = 125;
    m_t0s=[0.008:0.008:60];% 1 minute
    try
        [~,ECG_loc] = ECGpeak(m_t0s,m_IIs,m_fs,1,	(m_IIs));
    catch
        %disp(strcat(name,'_',num2str(i)));
    end
    EpeakTime = [];
    EpeakTime = m_t0s(ECG_loc);    %convert R location to actual time in seconds
    ERR = diff(EpeakTime);
    ERR = ERR(2:end);
    %RR_NM(i,:) = ERR;
    if isempty(ERR) == 0
        save(textNameNM,'ERR','-ascii');
    end
    %ECG_loc(ECG_loc==0)=[];
end
for i = 1:size(ecg_locMM,1)
    cd('E:\Thesis\Firmware\Data\Window_Exa\Mild');
    clearvars ERR
    textNameMM = strcat(name,'_','MM_W',num2str(i));
    m_IIs = ecg_locMM(i,:);
    m_fs = 125;
    m_t0s=[0.008:0.008:60];% 1 minute
    try
        [~,ECG_loc] = ECGpeak(m_t0s,m_IIs,m_fs,1,length(m_IIs));
    catch
        %disp(strcat(name,'_',num2str(i)));
    end
    EpeakTime = [];
    EpeakTime = m_t0s(ECG_loc);    %convert R location to actual time in seconds
    ERR = diff(EpeakTime);
    ERR = ERR(2:end);
    %RR_MM(i,:) = ERR;
    %ECG_loc(ECG_loc==0)=[];
    if isempty(ERR) == 0
        save(textNameMM,'ERR','-ascii');
    end
end
for i = 1:size(ecg_locAS,1)
    cd('E:\Thesis\Firmware\Data\Window_Exa\Severe');
    clearvars ERR
    textNameAS = strcat(name,'_','AS_W',num2str(i));
    m_IIs = ecg_locAS(i,:);
    m_fs = 125;
    m_t0s=[0.008:0.008:60];% 1 minute
    try
        [~,ECG_loc] = ECGpeak(m_t0s,m_IIs,m_fs,1,length(m_IIs));
    catch
        %disp(strcat(name,'_',num2str(i)));
    end
    EpeakTime = [];
    EpeakTime = m_t0s(ECG_loc);    %convert R location to actual time in seconds
    ERR = diff(EpeakTime);
    ERR = ERR(2:end);
    %RR_AS(i,:) = ERR;
    if isempty(ERR) == 0
        save(textNameAS,'ERR','-ascii');
    end
end
%% Save result
%% save workspace
try
    cd('E:\Thesis\Firmware\Data\Window_Exa');
    save(name_mat,'RR_NM','RR_MM','RR_AS');
catch
    disp(name);
end
%end