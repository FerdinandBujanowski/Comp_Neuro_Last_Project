clear
tic
warning("off")

t_max = 1000 ;
dt = 0.5 ;
I_FF = 1.1667 ;
rho_EI = 5 ;
T = (0:dt:t_max-dt);

% no spike case
M = [];
M = RNN_PARAMETERS(M, I_FF, rho_EI, t_max , dt);
M = RNN_INITIALIZATION(M, true);
M = RNN_SIMULATION(M, false);
M = RNN_ANALYSIS(M);
M = RNN_GRAPHIC_PARAMETERS(M);

% M = RNN_GRAPHICS(M);
% M = RNN_DISPLAY(M);

% spike case
SPIKED = [] ;
SPIKED = RNN_PARAMETERS(SPIKED, I_FF, rho_EI, t_max, dt);
SPIKED = RNN_INITIALIZATION(SPIKED, true);
SPIKED = RNN_SIMULATION(SPIKED, true);
SPIKED = RNN_ANALYSIS(SPIKED);

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


% estimated for extra spike case
SPIKED.f_est_E = SPIKED.f_est(SPIKED.N_E,:);
SPIKED.f_est_E_mean_time = mean(SPIKED.f_est_E, 1);
min_f_est_E_spike = min(SPIKED.f_est_E_mean_time);
max_f_est_E_spike = max(SPIKED.f_est_E_mean_time);

SPIKED.f_est_I = SPIKED.f_est(SPIKED.N_I,:);
SPIKED.f_est_I_mean_time = mean(SPIKED.f_est_I, 1);
min_f_est_I_spike = min(SPIKED.f_est_I_mean_time);
max_f_est_I_spike = max(SPIKED.f_est_I_mean_time);

min_f_total_spike = min([min_f_est_E_spike min_f_est_I_spike]);
max_f_total_spike = max([max_f_est_E_spike max_f_est_I_spike]);

Fig_No = 0;
Total_Color = [0.5 0.5 0.5];

% plot mean population frequencies -----
Fig_No = Fig_No + 1;
figure(Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
title('Mean Est Freq of Exc/Inh Neurons'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
% plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
plot(M.T,M.f_est_E_mean_time,'Color', M.Ampa_Color,'LineWidth',M.LineWidth, 'Display','E_{No-Spike}')
plot(M.T,M.f_est_I_mean_time,'Color',M.GabaA_Color,'LineWidth',M.LineWidth, 'Display','I_{No-Spike}')

plot(M.T,SPIKED.f_est_E_mean_time,'Color', M.FF_Color,'LineWidth',M.LineWidth, 'Display','E_{Spike}')
plot(M.T,SPIKED.f_est_I_mean_time,'Color',M.L_Color,'LineWidth',M.LineWidth ,'Display','I_{Spike}')
axis([min(M.T) max(M.T) min_f_total max_f_total])
set(gca,'FontSize',M.FontSize)
legend('show')


% try drawing values
% set(gca,'YDir','normal')


% spike vs no spike currents -----
    Fig_No = Fig_No + 1;
    figure(Fig_No); clf; hold on; box on; set(gcf,'color', 'w');
    title('Total Current Comparison'); xlabel('Time (ms)'); ylabel('Total Current (amp)');
    plot([0 t_max],[0 0],['k' ':'],'LineWidth', 3) 
    
    h_Total_No_Spike = plot(T, mean(M.I_Total, 1),'Color', [0.3 0.7 0.2] ,'LineWidth', 3,'Display','I_{No-Spike}');
    h_Total_Spike = plot(T, mean(SPIKED.I_Total ,1 ),'Color',Total_Color,'LineWidth', 3,'Display','I_{Spike}');

    % if M.I_min~=M.I_max; axis([min(M.T) max(M.T) M.I_min M.I_max]); end
    set(gca,'FontSize',20)
    legend('show',[h_Total_No_Spike h_Total_Spike])

% established frequency 
    Fig_No = Fig_No + 1;
    figure(Fig_No); clf; hold on; box on; set(gcf,'color', 'w');
    title('Mean Est Frequency of all Neurons'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
    plot([0 t_max],[0 0],'k:','LineWidth', 3)
    F_est_No_Spike = plot(T, mean(M.f_est, 1) ,'Color', [0.3 0.7 0.2] ,'LineWidth', 2,'DisplayName','F_{No_{Spike}}');
    F_est_Spike = plot(T, mean(SPIKED.f_est, 1)  ,'Color',Total_Color,'LineWidth', 2,'DisplayName','F_{Spike}');
    
    set(gca,'FontSize',20) ;
    legend('show',[F_est_No_Spike F_est_Spike])



    % abs difference between them over time
    Fig_No = Fig_No + 1;
    figure(Fig_No); clf; hold on; box on; set(gcf,'color', 'w');
    title('Absolute difference between frequencies over time'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
    plot([0 t_max],[0 0],'k:','LineWidth', 3)
    Difference = plot(T,abs(mean(M.f_est, 1)  - mean(SPIKED.f_est, 1) ) ,'Color', [0.3 0.7 0.2]);
    set(gca,'FontSize',20) ;
    % legend('show',[Difference])


toc