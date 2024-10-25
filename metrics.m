function signal = metrics(signal,signal_type)

%Calcula as métricas em análise para os sinais de ECG e PPG
%
%   Input: 
%       signal - struct com o sinal ECG/PPG
%       signal_type - 'e' para ECG; 'p' para PPG
%
%   Output: 
%       signal - struct com dois fields - N (normal) e S (stress). Cada field 
%   é uma célula com dimensões [nº indíviduos x 11] com colunas:
%           para ECG: [sinal ECG, índice picos R, intervalos NN, batimentos/minuto,
%   mean, SDNN, SDSD, RMSSD, NN50,PN50,RaLH]
%           para PPG: [sinal PPG, derivadas, instantes picos R, intervalos NN,
%   mean, SDNN, SDSD, RMSSD, NN50,PN50,RaLH]

for i = 1:2
    
    if i == 1
        aux = "N";
    else i == 2
        aux = "S";
    end
    
    if signal_type == 'p'
        
        for j = 1:length(signal.(aux))
            t_fim_vec = 180:18:signal.(aux){j,3}(1,end);
            
            for k=1:6 %to save the NN intervals in the PPG struct
                signal.(aux){j,4}(k,:) = diff(signal.(aux){j,3}(k,:));
            end
           
            for jan = 1:length(t_fim_vec)
                t_fim = t_fim_vec(jan);
                t_ini = t_fim-180;
                [~, ind_min] = min(abs(signal.(aux){j,3}(1,:) - t_ini));
                [~, ind_max] = min(abs(signal.(aux){j,3}(1,:) - t_fim));
                
                for ref = 1:6
                    NN = diff(signal.(aux){j,3}(ref,ind_min:ind_max));
                    
                    %mean
                    MEAN = mean(NN);
                    %standard deviation
                    SDNN = std(NN);
                    SDSD = std(diff(NN));
                    
                    %RMSSD
                    SquaredDiffValues = diff(NN).^2;
                    RMSSD = sqrt(mean(SquaredDiffValues));
                    
                    NN50 = length(find(diff(NN)>0.05));
                    PNN50 = NN50/(length(NN)-1)*100;
                    
                    signal.(aux){j,5}(ref,jan) = MEAN;
                    signal.(aux){j,6}(ref,jan) = SDNN;
                    signal.(aux){j,7}(ref,jan) = SDSD;
                    signal.(aux){j,8}(ref,jan) = RMSSD;
                    signal.(aux){j,9}(ref,jan) = NN50;
                    signal.(aux){j,10}(ref,jan) = PNN50;
                    
                    [psd, f] = pburg(NN,4,500);
                    
%                     figure()
%                     plot(f, psd);
%                     xlabel('Frequency (Hz)');
%                     ylabel('Power Spectral Density');
%                     xlim([0 0.5])
                    
                    idx_LF = find(f >= 0.04 & f < 0.15);
                    LF = trapz(psd(idx_LF));
                    idx_HF = find(f >= 0.15 & f < 0.4);
                    HF = trapz(psd(idx_HF));
                    
                    RaLH = LF/HF;
                    
                    signal.(aux){j,11}(ref,jan) = RaLH;

                end
            end
        end
        
    elseif signal_type == 'e'
        
        for j = 1:length(signal.(aux)) %doente
            t_fim_vec = 180:18:(signal.(aux){j,2}(end,1)*0.002);
            
            for jan = 1:length(t_fim_vec)
                t_fim = t_fim_vec(jan);
                t_ini = t_fim-180;
                [~, ind_min] = min(abs(signal.(aux){j,2}(1:end-1)*0.002 - t_ini)); 
                [~, ind_max] = min(abs(signal.(aux){j,2}(1:end-1)*0.002 - t_fim));
                
                NN = signal.(aux){j,3}(ind_min:ind_max);
                
                %mean
                MEAN = mean(NN);
                %standard deviation
                SDNN = std(NN);
                SDSD = std(diff(NN));
                
                %RMSSD
                SquaredDiffValues = diff(NN).^2;
                RMSSD = sqrt(mean(SquaredDiffValues));
                
                NN50 = length(find(diff(NN)>0.05));
                PNN50 = NN50/(length(NN)-1)*100;
                
                signal.(aux){j,5}(jan) = MEAN;
                signal.(aux){j,6}(jan) = SDNN;
                signal.(aux){j,7}(jan) = SDSD;
                signal.(aux){j,8}(jan) = RMSSD;
                signal.(aux){j,9}(jan) = NN50;
                signal.(aux){j,10}(jan) = PNN50;
                
                %RaLH
                [psd, f] = pburg(NN,4,500);
                
%                 figure()
%                 plot(f, psd);
%                 xlabel('Frequency (Hz)');
%                 ylabel('Power Spectral Density');
%                 xlim([0 0.5])
                
                idx_LF = find(f >= 0.04 & f < 0.15);
                LF = trapz(psd(idx_LF));
                idx_HF = find(f >= 0.15 & f < 0.4);
                HF = trapz(psd(idx_HF));
                
                RaLH = LF/HF;
                
                signal.(aux){j,11}(jan) = RaLH;
                
            end 
        end
    end
end

end