clear
tic
warning("off")

% init I_FF and rho_EI arrays
n_values = 10;
I_FF_min = 1; I_FF_max = 2.5;
rho_EI_min = 0.1; rho_EI_max = 5;
I_FF_values = linspace(I_FF_min, I_FF_max, n_values); % 1.0000    1.1667    1.3333    1.5000    1.6667    1.8333    2.0000    2.1667    2.3333    2.5000
rho_EI_values = linspace(rho_EI_min, rho_EI_max,n_values); % 0.1000    0.6444    1.1889    1.7333    2.2778    2.8222    3.3667    3.9111    4.4556    5.0000

disp(I_FF_values)
disp(rho_EI_values)

parfor k1 = 1:n_values
    for k2 = 1:n_values
        I_FF = I_FF_values(k1);
        rho_EI = rho_EI_values(k2);
        disp(I_FF + ", " + rho_EI)

        M = [];
        M = RNN_PARAMETERS(M, I_FF, rho_EI, 1000, 0.5);
        M = RNN_INITIALIZATION(M);
        M = RNN_SIMULATION(M);
        M = RNN_ANALYSIS(M);

        % Save scalar observables into MapStruct object
        MapStruct{k1}{k2}.V_mean = M.V_mean;
        MapStruct{k1}{k2}.f_mean = M.f_mean;
        MapStruct{k1}{k2}.CV_mean = M.CV_mean;
        MapStruct{k1}{k2}.rho_synchr = M.rho_synchr;

        MapStruct{k1}{k2}.I_FF_mean = M.I_FF_mean_all;
        MapStruct{k1}{k2}.I_L_mean = M.I_L_mean_all;
        MapStruct{k1}{k2}.I_Ampa_mean = M.I_Ampa_mean_all;
        MapStruct{k1}{k2}.I_GabaA_mean = M.I_GabaA_mean_all;
        MapStruct{k1}{k2}.I_Syn_mean = M.I_Syn_mean_all;
        MapStruct{k1}{k2}.I_Total_mean = M.I_Total_mean_all;
    end
end

for k1 = 1:n_values
    for k2 = 1:n_values
        % 'Offline' transfer to MapArray
        MapArr.V_mean(k1, k2) = MapStruct{k1}{k2}.V_mean;
        MapArr.f_mean(k1, k2) = MapStruct{k1}{k2}.f_mean;
        MapArr.CV_mean(k1, k2) = MapStruct{k1}{k2}.CV_mean;
        MapArr.rho_synchr(k1, k2) = MapStruct{k1}{k2}.rho_synchr;

        MapArr.I_FF_mean(k1, k2) = MapStruct{k1}{k2}.I_FF_mean;
        MapArr.I_L_mean(k1, k2) = MapStruct{k1}{k2}.I_L_mean;
        MapArr.I_Ampa_mean(k1, k2) = MapStruct{k1}{k2}.I_Ampa_mean;
        MapArr.I_GabaA_mean(k1, k2) = MapStruct{k1}{k2}.I_GabaA_mean;
        MapArr.I_Syn_mean(k1, k2) = MapStruct{k1}{k2}.I_Syn_mean;
        MapArr.I_Total_mean(k1, k2) = MapStruct{k1}{k2}.I_Total_mean;
    end
end

% try drawing values
set(gca,'YDir','normal')
Fig_No = 0;

% V_mean
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean Voltage (mV)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.V_mean); shading flat; colorbar

% f_mean
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean spiking frequency'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.f_mean); shading flat; colorbar

% CV_mean
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Irregularity'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.CV_mean); shading flat; colorbar

% rho_synchr
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Network Synchrony'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.rho_synchr); shading flat; colorbar

% I_FF
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean Feed Forward current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_FF_mean); shading flat; colorbar

% I_L
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean Leak current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_L_mean); shading flat; colorbar

% I_Ampa
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean Ampa current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_Ampa_mean); shading flat; colorbar

% I_GabaA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean GabaA current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_GabaA_mean); shading flat; colorbar

% I_Syn
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean synaptic current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_Syn_mean); shading flat; colorbar

% I_Total
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('Mean Total current (µAcm-2)'); ylabel('I_{FF} (mV)'); xlabel('rho_{EI} (u.a.)');
imagesc([rho_EI_min rho_EI_max], [I_FF_min I_FF_max], MapArr.I_Total_mean); shading flat; colorbar

toc