% Filter signal
cd('E:\Thesis\Firmware\Data\Signal');
addpath('E:\Thesis\Firmware\');
extract = dir();
extract = {extract.name}';
extract = extract(3:end);
for i_i = 1:length(extract)
    clearvars RR_NM RR_MM RR_AS asth_locNM asth_locMM asth_locAS
    cd('E:\Thesis\Firmware\Data\Signal');
    name = extract{i_i};
    load(name);
    name = name(1:end-4);
    name_mat = strcat(name,'.mat');
    %% Chia window
    % Number of sample in a window of 1 min of numeric file
    num_samp_1min = 60/(1/n_fs);
    %%
    %% Seperate ECG
    n_rsECG = reshape(m_ECG,7500,[])'; % m?i d�ng l� 1 window 1 ph�t
    %% Find annotation
    bs_PULSE = find(n_PULSE<10);
    bs_RESP = find(n_RESP<2);
    bs_SpO2 = find(n_SpO2<10);
    %
    bs_signal = unique([bs_PULSE bs_RESP bs_SpO2]);
    n_PULSE(bs_signal)=NaN;
    n_RESP(bs_signal)=NaN;
    n_SpO2(bs_signal)=NaN;
    
    %% EXA
    %% Mild/moderate : pulse [100-120], O2 [90-95]
%     asth_locNM = find((n_SpO2 >=95 & n_RESP < 21));
%     asth_locMM = find((n_SpO2 >=90 & n_SpO2 <=95 & n_RESP > 20 & n_RESP < 30 & n_PULSE <120 & n_PULSE >100));
%     % severe : pulse [100-120], O2 [90-95]
%     asth_locAS = find((n_SpO2 <90 & n_RESP > 30 & n_PULSE >= 120));
     asth_locNM = find((n_SpO2 >=95 & n_PULSE <110));
%ACUTE SEVERE
%MILD/ MODERATE
        asth_locMM = find((n_SpO2 >=92 & n_SpO2 <=95 & n_RESP > 20 & n_RESP <=25 & n_PULSE <110));
%ACUTE SEVERE
        asth_locAS = find((n_SpO2 >=92 & n_SpO2 <=95 & n_RESP > 25 & n_PULSE >= 110));
    %% Sample with numeric signal larger than windown
    asth_locAS = unique(round(asth_locAS./num_samp_1min));
    asth_locNM = unique(round(asth_locNM./num_samp_1min));
    asth_locMM = unique(round(asth_locMM./num_samp_1min));
    
    % location array for ECG
    n_loc = [1:size(n_rsECG,1)];
    remove_MM = setdiff(n_loc,asth_locMM); % tim nh?ng index c?a ast m� ECG kh�ng c�
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
            [time_loc,ECG_loc,R_value] = ECG_detection(m_fs,m_IIs,m_t0s);
        catch
           disp(strcat(name,'_',num2str(i)));
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
            [time_loc,R_loc,R_value] = ECG_detection(m_fs,m_IIs,m_t0s);
            close all;
        catch
            %disp(strcat(name,'_',num2str(i)));
        end
        EpeakTime = [];
        EpeakTime = time_loc;    %convert R location to actual time in seconds
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
            [time_loc,R_loc,R_value] = ECG_detection(m_fs,m_IIs,m_t0s);
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
    % Save result
    % save workspace
    try
        cd('E:\Thesis\Firmware\Data\Window_Exa');
        save(name_mat,'asth_locAS','asth_locMM','asth_locNM');
    catch
        disp(name);
    end
    result(i_i,1)= i_i;
    result(i_i,2)= length(asth_locNM);
    result(i_i,3)= length(asth_locMM);
    result(i_i,4)= length(asth_locAS);
end