function signal_proc = pan_tompkins(signal,fs)

%Implementa o algoritmo de Pan-Tompkins para identificação de picos R;
%calcula, ainda, os intervalos NN e os batimentos por minuto.
%
%   Input: 
%       signal - struct com o sinal ECG
%       fs - frequência de amostragem
% 
%   Output: 
%       signal_proc - struct com dois fields - N (normal) e S (stress). Cada field 
%   é uma célula com dimensões [nº indíviduos x 4] com colunas:
%           [sinal ECG, índice picos R, intervalos NN, batimentos/minuto]

signal_proc = signal;

for i = 1:2
    
    if i == 1
        aux = "N";
    else i == 2
        aux = "S";
    end
    
    for j = 1:length(signal.(aux))
    
        % (1) Low pass filter with wc=25/30 --> already done in the
        % preprocessing

        % (2) High-pass filter
        wc = 5;
        fc = wc/(0.5*fs);
        order = 4;
        [b, a] = butter(order, fc, 'High');
        e2 = filtfilt (b, a, signal.(aux) {j});
        
        % (3) Differentiation + (4) Potentiation
        e3 = diff(e2);
        e4 = e3.^2;
        
        %(5) Moving average 
        timeWindow = 0.1; 
        N = timeWindow/(1/fs);
        b = (1/N)*ones (1, N);
        a = 1;
        e5 = filtfilt (b, a, e4);
        
        signal_proc.(aux) {j} = e5;
        
        %% R peaks detetion
        
        threshold = 0.7*mean(e5);
        
        rpeaks = zeros(length(e5),1);
        
        for i = 2:length(e5)-1
            if e5(i)>threshold && e5(i-1)<=threshold
                rpeaks(i) = 1;
            elseif e5(i)>threshold && e5(i+1)<threshold
                rpeaks(i) = -1;
            elseif e5(i)>threshold && e5(i-1)>threshold
                rpeaks(i) = 2;
            end
        end
        
        peaks_ind = find(rpeaks == 1);
        
        %Rule from physiological data
        peaks_ind_time = peaks_ind*(1/fs);
        
        to_eliminate = [];
        for i = 2:length(peaks_ind)
            if peaks_ind_time(i) - peaks_ind_time(i-1) < 0.3
                to_eliminate = [to_eliminate i];
            end
        end
        peaks_ind (to_eliminate) = [];
        
        signal_proc.(aux) {j,2} = peaks_ind;
               
        %% RR calculation
        
        RR = diff(peaks_ind)*(1/fs);
        
%         figure()
%         time = peaks_ind(2:end)*(1/fs);
%         plot(time ,RR,'-bo'); xlim([peaks_ind(2)*(1/fs) peaks_ind(100)*(1/fs)])
%         xlabel('Time(seconds)'); ylabel('RR intervals');
%         title('RR intervals');
        
        signal_proc.(aux) {j,3} = RR;

        %% Average Heart Rate
        
        beats_per_minute = round(length(peaks_ind)/(length(e5)*(1/fs)/60));
        signal_proc.(aux) {j,4} = beats_per_minute;

    end

end
