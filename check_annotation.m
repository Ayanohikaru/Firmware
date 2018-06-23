%clear all;clc;
Folder = 'E:\Thesis\Firmware\Data\Mat_num';
cd(Folder);
addpath('E:\Thesis\Firmware');
extract = dir('*nm.mat');
extract = {extract.name}';
%%
%for i_i = 1:length(extract)
i_i = 1;
name = extract{i_i};
name = name(1:end-6);
name_save = strcat(name,'.mat');
%% Load data nummeric
run(load_num);
run(load_ECG);
%% save workspace
try
    cd('E:\Thesis\Firmware\Data\Signal');
    if (exist('n_PPG','var')==1)
        save(name_save,'n_PULSE','n_RESP','n_SpO2','n_ECG','n_PPG');
    else
        save(name_save,'n_PULSE','n_RESP','n_SpO2','n_ECG');
    end
catch
    disp(name);
end
%end


