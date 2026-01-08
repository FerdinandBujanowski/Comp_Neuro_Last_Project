clear
tic
warning("off")

M = [];
M = RNN_PARAMETERS(M, 2, 0, 1, 0.6158);
M = RNN_INITIALIZATION(M);
M = RNN_SIMULATION(M);
M = RNN_ANALYSIS(M);
M = RNN_GRAPHIC_PARAMETERS(M);
M = RNN_GRAPHICS(M);
M = RNN_DISPLAY(M);

disp(M.f_Sp_HA < (M.f_Sp_non_HA + 2.5))
disp(M.f_P_HA > (M.f_Sp_HA + 5))

% Estimated firing frequency over time of HA / non-HA neurons
M.f_est_HA = M.f_est(M.N_HA,:);
M.f_est_HA_mean_time = mean(M.f_est_HA, 1);
min_f_est_HA = min(M.f_est_HA_mean_time);
max_f_est_HA = max(M.f_est_HA_mean_time);

M.f_est_nonHA = M.f_est(M.N_non_HA,:);
M.f_est_nonHA_mean_time = mean(M.f_est_nonHA, 1);
min_f_est_nonHA = min(M.f_est_nonHA_mean_time);
max_f_est_nonHA = max(M.f_est_nonHA_mean_time);

min_f_total = min([min_f_est_HA min_f_est_nonHA]);
max_f_total = max([max_f_est_HA max_f_est_nonHA]);

% plot mean population frequencies -----
M.Fig_No = M.Fig_No + 1;
figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
title('Mean Est Freq of HA/nonHA Neurons'); xlabel('time (ms)'); ylabel('frequency (Hz)');
% plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
plot(M.T,M.f_est_HA_mean_time,'Color', [1. 0. 0.],'LineWidth',M.LineWidth)
plot(M.T,M.f_est_nonHA_mean_time,'Color', [0. 1. 0.],'LineWidth',M.LineWidth)
axis([min(M.T) max(M.T) min_f_total max_f_total])
set(gca,'FontSize',M.FontSize)

toc