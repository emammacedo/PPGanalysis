function PPG_NN = ppg_nn(ECG_pt,PPG_proc,fs)

%Segmenta o sinal de PPG em intervalos NN de acordo com os 6 pontos de
%referência - PPGonset, PPG20, PPGderiv, PPG50, PPG80, PPGpeak
%
%   Input: 
%       ECG_peak - struct com os sinais ECG e respetivos intervalos NN
%       PPG_proc - struct com os sinais PPG e respetivas 1ª,2ª e 3ª
%       derivadas
%       fs - frequência de amostragem
% 
%   Output: 
%       PPG_NN - struct com dois fields - N (normal) e S (stress); cada field 
%   é uma célula com dimensões [nº indíviduos x 3] cujas colunas correspondem
%   a [sinal PPG, derivadas, matriz 6 x nº picos R, em que cada linha diz 
%   respeito a um dos pontos de referência 

PPG_NN = PPG_proc;
ts = 1/fs;

for i = 1:2
    
    if i == 1
        aux = "N";
    else i == 2
        aux = "S";
    end

    for j = 1:length(PPG_NN.(aux))
    matrix_int = zeros(6,length(ECG_pt.(aux){j,3}));

        for rr = 1:length(ECG_pt.(aux){j,2})
            if rr == 1
                idx_ini = 1;
                idx_fim = ECG_pt.(aux){j,2}(rr);             
            else
                idx_ini = ECG_pt.(aux){j,2}(rr-1);
                idx_fim = ECG_pt.(aux){j,2}(rr);
            end
            [~, matrix_int(6,rr)] = max(PPG_NN.(aux){j,1}(idx_ini:idx_fim));
            matrix_int(6,rr) = idx_ini-1+matrix_int(6,rr);
            idx_peak = matrix_int(6,rr);

            [~, matrix_int(1,rr)] = max(PPG_NN.(aux){j,2}(3,idx_ini:idx_peak));
            matrix_int(1,rr)= idx_ini-1+matrix_int(1,rr);
            idx_onset = matrix_int(1,rr);

            
            onset = PPG_NN.(aux){j,1}(matrix_int(1,rr));
            peak = PPG_NN.(aux){j,1}(matrix_int(6,rr));

            interval = peak-onset;
            [~, matrix_int(3,rr)] = max(PPG_NN.(aux){j,2}(1,idx_onset:idx_peak));
            [~, matrix_int(2,rr)] = min(abs(PPG_NN.(aux){j,1}(idx_onset:idx_peak) - (onset+interval*0.2)));
            [~, matrix_int(4,rr)] = min(abs(PPG_NN.(aux){j,1}(idx_onset:idx_peak) - (onset+interval*0.5)));
            [~, matrix_int(5,rr)] = min(abs(PPG_NN.(aux){j,1}(idx_onset:idx_peak) - (onset+interval*0.8)));
            % matrix_int(2,rr) = find(PPG_NN.(aux){j,1}(idx_ini:idx_fim)==onset+interval*0.2);
            % matrix_int(4,rr) = find(PPG_NN.(aux){j,1}(idx_ini:idx_fim)==onset+interval*0.5);
            % matrix_int(5,rr) = find(PPG_NN.(aux){j,1}(idx_ini:idx_fim)==onset+interval*0.8);
            matrix_int(3,rr)= idx_onset-1+matrix_int(3,rr);
            matrix_int(2,rr) = idx_onset-1+matrix_int(2,rr);
            matrix_int(4,rr) = idx_onset-1+matrix_int(4,rr);
            matrix_int(5,rr) = idx_onset-1+matrix_int(5,rr);
            matrix_int(:,rr) = matrix_int(:,rr)*ts;
        end
        PPG_NN.(aux){j,3} = matrix_int;
    end

    
end



end
