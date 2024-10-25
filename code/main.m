clc, clear all, close all;

%% Dataset selection

data = load('database_ProfPaulo.mat');
fs = 500;

[ECG, PPG] = import_data (data, (1/fs));

% figure()
% plot(1:length(PPG.N{1,1}), PPG.N{1,1})
% xlim([100,2000])

%% Pre-processing of data

ECG_proc = preprocessing(ECG,'e',fs);
PPG_proc = preprocessing(PPG,'p',fs);

%% Segmentation - ECG

ECG_pt = pan_tompkins(ECG_proc,fs);

%% Segmentation - PPG

%calculation of 3rd derivative of PPG
names = ["N","S"];
for i = 1:length(names)
   type = names(i);
   
   for j = 1:length(PPG_proc.(type))
       
       len = length(PPG_proc.(type){j})
       clear PPG_derivatives;
       PPG_derivatives(1,:) = (nd5p(PPG_proc.(type){j},1,len)); 
       
       wnd = round((31.3/1000)*fs);
       b = ones(1,wnd)/wnd;
       
       for i=2:3
           PPG_derivatives(i,:) = (nd5p(PPG_derivatives(i-1,:),1,len)); 
           PPG_derivatives(i,:) = filtfilt(b,1,PPG_derivatives(i,:));
       end
       
       PPG_proc.(type){j,2} = PPG_derivatives;
       % PPG_proc --> N/S --> cell with columns {PPG signal; derivatives 
       %(each line corresponds to one of the derivates)}

   end
end

PPG_proc = ppg_nn(ECG_pt,PPG_proc,fs);

%% Metrics calculation 

ECG_pt = metrics(ECG_pt,'e');
PPG_proc = metrics(PPG_proc,'p');

%% Correlation between NN from ECG and PPGA

corr_matrix= correlation(ECG_pt,PPG_proc);

%% Boxplot

line = 2; %PPG deriv
ecg_n = []; ecg_s = [];
ppg_n = []; ppg_s = [];
metrics_names = {'Mean','SDNN','SDSD','RMSSD','NN50','PNN50','RaLH'};

for m = 1:7 %number of metrics
    ecg_n = []; ecg_s = [];
    ppg_n = []; ppg_s = [];
    
    for i = 1:10
        ecg_n = [ecg_n, ECG_pt.N{i,m+4}(1,:)];
        ecg_s = [ecg_s, ECG_pt.S{i,m+4}(1,:)];
        ppg_n = [ppg_n, PPG_proc.N{i,m+4}(line,:)];
        ppg_s = [ppg_s, PPG_proc.S{i,m+4}(line,:)];
    end
    
    if length(ecg_n) > length(ecg_s)
        max = length(ecg_n);
        ecg_s(end+1:max) = NaN;
        ppg_s(end+1:max) = NaN;
    elseif length(ecg_n) < length(ecg_s)
        max = length(ecg_s);
        ecg_n(end+1:max) = NaN;
        ppg_n(end+1:max) = NaN;
    end
    
    figure()
    boxplot([ppg_n',ecg_n', ppg_s',ecg_s'], 'Labels', {'PPG Normal', 'ECG Normal', 'PPG Sress','ECG Stress'});
    title(metrics_names{m});
    
end

