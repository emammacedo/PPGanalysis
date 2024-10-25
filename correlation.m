function c_matrix  = correlation(ECG_pt,PPG_proc)

%Calcula a correlação entre as métricas do ECG e PPG
%
%   Input: 
%       ECG_pt - struct com o sinal ECG e métricas
%       PPG_proc - struct com o sinal PPG e métricas
%
%   Output: 
%       c_matrix - tabela com os valores de correlação para cada métrica
%       para cada ponto de referência do PPG

corr_m = [];
names = ["N","S"];

for p = 1:6 % 6 parameters
    for m = 5:11 % 7 metrics in columns 5 to 11
        for i = 1:length(names)
            type = names(i);
            for s = 1:size(ECG_pt.(type),1)
                a = corrcoef(ECG_pt.(type){s,m},PPG_proc.(type){s,m} (p,:));
                corr_s_m(s+(i-1)*10,m) = a(1,2);
            end
        end
        corr_m(p,m-4) = [mean(corr_s_m(:,m))];
    end
end
media = median(corr_m,2);
desvio = std(corr_m,[],2);

c_matrix = array2table([corr_m, media, desvio],'RowNames',{'PPG onset','PPG 20','PPG deriv','PPG 50', 'PPG 80','PPG peak'},  'VariableNames', {'MEAN','SDNN','SDSD','RMSSD','NN50','PNN50','RaLH','mean metrics','std metrics'});

end
