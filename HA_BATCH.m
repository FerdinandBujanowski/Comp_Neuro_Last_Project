clear
tic
warning("off")

% init arrays
n_values = 5;
n_HA_min = 2; n_HA_max = 400;
n_HA_values = linspace(n_HA_min, n_HA_max, n_values);
w_HA_min = 0; w_HA_max = 5;
w_HA_values = linspace(w_HA_min, w_HA_max, n_values);

parfor k1 = 1:n_values
    for k2 = 1:n_values
        n_HA = round(n_HA_values(k1));
        w_HA = w_HA_values(k2);
        disp(n_HA + ", " + w_HA)

        M = [];
        M = RNN_PARAMETERS(M, n_HA, w_HA);
        M = RNN_INITIALIZATION(M);
        M = RNN_SIMULATION(M);
        M = RNN_ANALYSIS(M);
        % M = RNN_GRAPHIC_PARAMETERS(M);
        % M = RNN_GRAPHICS(M);
        % M = RNN_DISPLAY(M);

        % Save scalar observables into MapStruct object
        MapStruct{k1}{k2}.f_Sp_HA = M.f_Sp_HA;
        MapStruct{k1}{k2}.f_Sp_non_HA = M.f_Sp_non_HA;
        MapStruct{k1}{k2}.f_P_HA = M.f_P_HA;
        MapStruct{k1}{k2}.f_P_non_HA = M.f_P_non_HA;
        MapStruct{k1}{k2}.f_Off_HA = M.f_Off_HA;
        MapStruct{k1}{k2}.f_Off_non_HA = M.f_Off_non_HA;

    end
end

% offline loop transfer to MapArray
for k1 = 1:n_values
    for k2 = 1:n_values
        MapArr.f_Sp_HA(k1, k2) = MapStruct{k1}{k2}.f_Sp_HA;
        MapArr.f_Sp_non_HA(k1, k2) = MapStruct{k1}{k2}.f_Sp_non_HA;
        MapArr.f_P_HA(k1, k2) = MapStruct{k1}{k2}.f_P_HA;
        MapArr.f_P_non_HA(k1, k2) = MapStruct{k1}{k2}.f_P_non_HA;
        MapArr.f_Off_HA(k1, k2) = MapStruct{k1}{k2}.f_Off_HA;
        MapArr.f_Off_non_HA(k1, k2) = MapStruct{k1}{k2}.f_Off_non_HA;

        % frequency comparisons
        MapArr.f_Sp_diff(k1, k2) = MapArr.f_Sp_HA(k1, k2) < (MapArr.f_Sp_non_HA(k1, k2) - 2.5);
        MapArr.f_P_distinct(k1, k2) = MapArr.f_P_HA(k1, k2) > (MapArr.f_Sp_HA(k1, k2) + 5);
    end
end

% draw maps
set(gca,'YDir','normal')
Fig_No = 0;

% f_Sp_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('HA Sp frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_Sp_HA); shading flat; colorbar

% f_Sp_non_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('non HA Sp frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_Sp_non_HA); shading flat; colorbar

% f_P_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('HA P frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_P_HA); shading flat; colorbar

% f_P_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('non HA P frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_P_non_HA); shading flat; colorbar

% f_Off_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('HA Off frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_Off_HA); shading flat; colorbar

% f_Off_non_HA
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('non HA Off frequency'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_Off_non_HA); shading flat; colorbar

% f_Sp_HA < f_Sp_non_HA + 2.5
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('f_{Sp} < f_{Sp,nonHA} + 2.5Hz'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_Sp_diff); shading flat; colorbar

% f_P_HA < f_Sp_HA + 5
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on;
title('f_{P} > f_{Sp} + 5Hz'); ylabel('n_{HA}'); xlabel('w_{HA} (u.a.)');
imagesc([w_HA_min w_HA_max], [n_HA_min n_HA_max], MapArr.f_P_distinct); shading flat; colorbar

% disp("All done")