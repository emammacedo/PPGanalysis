function [ECG, PPG] = import_data (data, ts)

%Recebe como argumento o dataset e o período de amostragem, selecionado 
%as partes dos sinais de ECG e PPG para o estado normal e de stress. 
%
%   Input: 
%       data - dataset
%       ts - período de amostragem
%   
%   Output: 
%       ECG - struct com dois fields - N (normal) e S (stress); cada field 
%   é uma célula com dimensões [nº indíviduos x 1] cujos elementos são os 
%   sinais de ECG
%       PPG - igual à anterior, mas apra o PPG

ECG.N = {}; ECG.S = {};
PPG.N = {}; PPG.S = {};

for i = 1:length(data.database)
    if isempty(data.database{i,1}) == 0
        
        time_aux = [data.database{i,1}.Events.taskEvents.Duration];
        
        t_n_i = floor(time_aux(2)/ts);
        t_n_f = floor(time_aux(3)/ts);
        
        t_s_i = floor(time_aux(4)/ts);
        t_s_f = floor(time_aux(5)/ts);
        
        ecg_N = data.database{i,1}.ECG(t_n_i:t_n_f,1);
        ecg_S = data.database{i,1}.ECG(t_s_i:t_s_f,1);
        
        ppg_N = data.database{i,1}.PPG(t_n_i:t_n_f,1);
        ppg_S = data.database{i,1}.PPG(t_s_i:t_s_f,1);
        
        ECG.N = [ECG.N; ecg_N];
        ECG.S = [ECG.S; ecg_S];
        
        PPG.N = [PPG.N; ppg_N];
        PPG.S = [PPG.S; ppg_S];
    end
end
end
