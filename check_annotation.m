%clear all;clc;
Folder = 'E:\Thesis\Firmware\Data\Mat_num';
cd(Folder);
addpath('E:\Thesis\Firmware');
extract = dir('*nm.mat');
extract = {extract.name}';
%%
for i_i = 1:length(extract)
name = extract{i_i};
name = name(1:end-6);
name_save = strcat(name,'.mat');
%% Load data nummeric
[m_RESP,m_PPG,m_ECG,m_starttime] = load_ECG(name);
[n_fs,n_SpO2,n_PULSE,n_RESP,n_starttime] = load_num(name);
%% Compare time start and scale signal
% data in m file is 125 sample/second
% data in n file is 1 sample/minute
addpath('E:\Thesis\Firmware');
run('convertTime');
%% save workspace
cd('E:\Thesis\Firmware\Data\Signal')
try
    cd('E:\Thesis\Firmware\Data\Signal');
%     if (isempty(n_PPG)==0)&& (isempty(n_RESP)==0)
         save(name_save,'n_fs','n_PULSE','n_RESP','n_SpO2','m_ECG','m_PPG','m_RESP');
%     else
%         save(name_save,'n_fs','n_PULSE','n_RESP','n_SpO2','m_ECG');
%     end
catch
    disp(name);
end
end


