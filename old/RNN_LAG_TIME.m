clear
tic
warning("off")

M = [];
M = RNN_PARAMETERS(M, 1.1667, 5, 500, 0.25);
M = RNN_INITIALIZATION(M);
M = RNN_SIMULATION(M);
M = RNN_ANALYSIS(M);
M = RNN_GRAPHIC_PARAMETERS(M);
% M = RNN_GRAPHICS(M);
M = RNN_DISPLAY(M);

% Average voltage over time of excitatory / inhibitory neurons
% M.V_E = M.V(M.N_E,:);
% M.V_E_mean_time = mean(M.V_E, 1);
% min_V_E = min(M.V_E_mean_time);
% max_V_E = max(M.V_E_mean_time);
% 
% M.V_I = M.V(M.N_I,:);
% M.V_I_mean_time = mean(M.V_I, 1);
% min_V_I = min(M.V_I_mean_time);
% max_V_I = max(M.V_I_mean_time);
% 
% min_total = min([min_V_E min_V_I]);
% max_total = max([max_V_E max_V_I]);

% Estimated firing frequency over time of excitatory / inhibitory neurons
M.f_est_E = M.f_est(M.N_E,:);
M.f_est_E_mean_time = mean(M.f_est_E, 1);
min_f_est_E = min(M.f_est_E_mean_time);
max_f_est_E = max(M.f_est_E_mean_time);

M.f_est_I = M.f_est(M.N_I,:);
M.f_est_I_mean_time = mean(M.f_est_I, 1);
min_f_est_I = min(M.f_est_I_mean_time);
max_f_est_I = max(M.f_est_I_mean_time);

min_f_total = min([min_f_est_E min_f_est_I]);
max_f_total = max([max_f_est_E max_f_est_I]);

% plot mean population voltages -----
% M.Fig_No = M.Fig_No + 1;
% figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
% title('Mean Voltage of Exc/Inh Neurons'); xlabel('time (ms)'); ylabel('V (mV)');
% % plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
% plot(M.T,M.V_I_mean_time,'Color',M.GabaA_Color,'LineWidth',M.LineWidth)
% plot(M.T,M.V_E_mean_time,'Color', M.Ampa_Color,'LineWidth',M.LineWidth)
% axis([min(M.T) max(M.T) min_total max_total])
% set(gca,'FontSize',M.FontSize)

M.Fig_No = 0; % comment out this one when uncommenting GRAPHICS script

% plot mean population frequencies -----
M.Fig_No = M.Fig_No + 1;
figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
title('Mean Est Freq of Exc/Inh Neurons'); xlabel('time (ms)'); ylabel('frequency (Hz)');
% plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
plot(M.T,M.f_est_E_mean_time,'Color', M.Ampa_Color,'LineWidth',M.LineWidth)
plot(M.T,M.f_est_I_mean_time,'Color',M.GabaA_Color,'LineWidth',M.LineWidth)
axis([min(M.T) max(M.T) min_f_total max_f_total])
set(gca,'FontSize',M.FontSize)

% find best fitting lag
delta_lag = 100;
% M.diff_averages = zeros(2*delta_lag+1, 1);
i = 1;
start_time = 1 + (30/M.dt);

for lag = -delta_lag:1:delta_lag
    f_E_lag = M.f_est_E_mean_time;
    f_I_lag = M.f_est_I_mean_time;

    if lag < 0
        f_E_lag = f_E_lag(start_time + abs(lag):M.n_t);
        f_I_lag = f_I_lag(start_time:M.n_t+lag);
    end
    if lag > 0
        f_E_lag = f_E_lag(start_time:M.n_t-lag);
        f_I_lag = f_I_lag(start_time + lag:M.n_t);
    end

    M.diff_averages(i) = mean(abs(f_E_lag(:) - f_I_lag(:)));
    M.lags(i) = lag;
    i = i+1;
end

disp(length(M.lags));

% plot lags -----
x_lag = M.lags(:) * M.dt;
M.Fig_No = M.Fig_No + 1;
figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
title('Difference between E/I firing frequencies'); xlabel('lag (ms)'); ylabel('mean absolute difference (Hz)');
% plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
% plot(M.T,M.V_I_mean_time,'Color',M.GabaA_Color,'LineWidth',M.LineWidth)
plot(M.lags,M.diff_averages,'Color', M.GabaA_Color,'LineWidth',M.LineWidth)
axis([min(x_lag) max(x_lag) min(M.diff_averages) max(M.diff_averages)])
set(gca,'FontSize',M.FontSize)

toc