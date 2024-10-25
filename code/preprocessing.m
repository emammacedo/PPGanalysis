function signal_proc = preprocessing(signal,signal_type,fs)

%Efetua o preprocessamento do sinal
%
%   Input: 
%       signal - struct com os sinais ECG ou PPG
%       signal_type - 'e' para ECG; 'p' para PPG
%       fs - frequência de amostragem
% 
%   Output: 
%       ECG - struct com dois fields - N (normal) e S (stress); cada field 
%   é uma célula com dimensões [nº indíviduos x 1] cujos elementos são os 
%   sinais de ECG já processados
%       PPG - igual à anterior, mas para o PPG

signal_proc = signal;

for i = 1:2
    
    if i == 1
        aux = "N";
    else i == 2
        aux = "S";
    end
    
    for j = 1:length(signal.(aux))
        
        %Baseline removal
        timeWindow = 2;
        N = timeWindow/(1/fs);
        b = (1/N)*ones(1, N);
        a = 1;
        signal_aux = filtfilt (b, a, signal.(aux) {j} );
        
        %Noise elimination
        if signal_type == 'e'
            wc = 30;
        elseif signal_type == 'p'
            wc = 18;
        end
        
        fc = wc/(0.5*fs);
        order = 8;
        [b, a] = butter(order, fc);
        %signal_aux = filter (b, a, signal_aux);
        signal_aux = filtfilt (b, a, signal_aux);
        
        signal_proc.(aux) {j} = signal_aux;
        
%         figure()
%         plot(1:length(signal_aux), signal_aux)
%         xlim([100,100000])
%         if signal_type == 'e'
%             title('ECG' + aux);
%         elseif signal_type == 'p'
%             title('PPG' + aux);
%         end
        
    end
end

% aux = "N";
% 
% for j = 1:length(signal.(aux))
%     
%     %Baseline removal
%     timeWindow = 2;
%     N = timeWindow/(1/fs);
%     b = (1/N)*ones(1, N);
%     a = 1;
%     signal_aux = filtfilt (b, a, signal.(aux) {j} );
%     
%     %Noise elimination
%     if signal_type == 'e'
%         wc = 30;
%     elseif signal_type == 'p'
%         wc = 18;
%     end
%     
%     fc = wc/(0.5*fs);
%     order = 8;
%     [b, a] = butter(order, fc);
%     signal_aux = filter (b, a, signal_aux);
%     
%     signal_proc.(aux) {j} = signal_aux;
%     
%     figure()
%     plot(1:length(signal_aux), signal_aux)
%     xlim([100,100000])
% end

end
