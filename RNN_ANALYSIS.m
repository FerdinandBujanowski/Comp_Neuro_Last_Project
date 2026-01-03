function M = RNN_ANALYSIS(M)

M.t_0_analysis = M.t_max/2;
M.k_0_analysis = round(M.t_0_analysis/M.dt);
M.K_analysis = M.k_0_analysis:M.n_t;

% frequencies, irregularity, currents -----

for k = 1:M.n
    M.t_AP_display{k} = find(M.is_AP(k,:))*M.dt;
    M.neuron_AP_display{k} = k * ones(size(M.t_AP_display{k}));
    M.t_AP{k} = find(M.is_AP(k,M.K_analysis))*M.dt;
    M.ISI{k} = diff(M.t_AP{k});
    M.f(k) = 1e3/mean(M.ISI{k});
    M.CV(k) = std(M.ISI{k})/mean(M.ISI{k});
end

M.f_E = M.f(M.N_E);
M.f_I = M.f(M.N_I);
M.CV_E = M.CV(M.N_E);
M.CV_I = M.CV(M.N_I);

M.f_nonNull_nonNan = M.f(~isnan(M.f)&M.f~=0);
M.CV_nonNull_nonNan = M.CV(~isnan(M.CV)&M.CV~=0);
M.f_E_nonNull_nonNan = M.f_E(~isnan(M.f_E)&M.f_E~=0);
M.CV_E_nonNull_nonNan = M.CV_E(~isnan(M.CV_E)&M.CV_E~=0);
M.f_I_nonNull_nonNan = M.f_I(~isnan(M.f_I)&M.f_I~=0);
M.CV_I_nonNull_nonNan = M.CV_I(~isnan(M.CV_I)&M.CV_I~=0);

M.f_mean = mean(M.f_nonNull_nonNan);
M.CV_mean = mean(M.CV_nonNull_nonNan);
M.f_E_mean = mean(M.f_E_nonNull_nonNan);
M.CV_E_mean = mean(M.CV_E_nonNull_nonNan);
M.f_I_mean = mean(M.f_I_nonNull_nonNan);
M.CV_I_mean = mean(M.CV_I_nonNull_nonNan);

M.V_mean = mean(M.V(:));
M.I_FF_mean = mean(M.I_FF,1);
M.I_L_mean = mean(M.I_L,1);
M.I_Ampa_mean = mean(M.I_Ampa,1);
M.I_Nmda_mean = mean(M.I_Nmda,1);
M.I_GabaA_mean = mean(M.I_GabaA,1);
M.I_GabaB_mean = mean(M.I_GabaB,1);
M.I_Syn_mean = mean(M.I_Syn,1);
M.I_Total_mean = mean(M.I_Total,1);

M.I_max = 2.5*max(abs([mean(M.I_Ampa_mean)  mean(M.I_Nmda_mean) mean(M.I_GabaA_mean) mean(M.I_GabaB_mean)]));
M.I_min = -M.I_max;
M.I_Ampa_min = min(M.I_Ampa(:));
M.I_Ampa_max = max(M.I_Ampa(:));

% synchrony -----

M.tau_ker = 20; % ms
M.n_ker = round(5*M.tau_ker/M.dt);
M.exp_ker = exp(-(0:M.dt:(M.n_ker-1)*M.dt)/M.tau_ker); M.exp_ker = M.exp_ker/sum(M.exp_ker); M.exp_ker = M.exp_ker * 1e3 / M.dt; % Hz
M.f_est = conv2(M.is_AP,M.exp_ker,'same');
M.f_est_mean_nrns = mean(M.f_est,2);
M.f_est_mean_time = mean(M.f_est,1);

% paiwise neurons' Pearson correlations

M.f_std = std(M.f_est,0,2);
M.n_Cov_subset = 500;
M.N_subset = 1:M.n_Cov_subset;
m.f_min_cov = 1; % Hz
k_Cov = 0;
M.f_Cov = [];
for i = 1:M.n_Cov_subset-1
    for j = i+1:M.n_Cov_subset
        if M.f_est_mean_nrns(i) > m.f_min_cov & M.f_est_mean_nrns(j) > m.f_min_cov
            k_Cov = k_Cov + 1;
            cov_i_j = cov(M.f_est(i,:),M.f_est(j,:));
            M.f_Cov(k_Cov) = cov_i_j(1,2)/M.f_std(i)/M.f_std(j);
        end
    end
end

% global synchrony

M.R_synchr_mean = mean(M.f_Cov); % mean of synchrony based on Pearson's correlations
M.R_synchr_std = std(M.f_Cov); % std of synchrony based on Pearson's correlations
M.rho_synchr = sqrt(var(mean(M.f_est,1))/mean(var(M.f_est,1))); % synchrony based on common variance

M.f_Cov_mean = mean(M.f_Cov);
M.f_Cov_std = std(M.f_Cov);

% Estimated HA / non-HA frequencies --------------------------------------
M.spikes_Sp = zeros(M.n, 1);
M.spikes_P = zeros(M.n, 1);
M.spikes_Off = zeros(M.n, 1);

start_Sp = (0.5*M.d_period);
end_Sp = M.d_period;
start_P = (M.d_On+1.5*M.d_period);
end_P = (M.d_On+2*M.d_period);
start_Off = (M.d_On+M.d_Off+2.5*M.d_period);
end_Off = (M.d_On+M.d_Off+3*M.d_period);

% disp(start_Sp + ", " + end_Sp)
% disp(start_P + ", " + end_P)
% disp(start_Off + ", " + end_Off)

% indices of non-silent neurons during each phase
i_Sp = ones(M.n) * -1;
i_P = ones(M.n) * -1;
i_Off = ones(M.n) * -1;

for k = 1:M.n
    M.spikes_Sp(k) = sum(and(M.t_AP_display{k} >= start_Sp, M.t_AP_display{k} < end_Sp));
    if M.spikes_Sp(k) > 0
        i_Sp(k) = k;
    end
    M.spikes_P(k) = sum(and(M.t_AP_display{k} >= start_P, M.t_AP_display{k} < end_P));
    if M.spikes_P(k) > 0
        i_P(k) = k;
    end
    M.spikes_Off(k) = sum(and(M.t_AP_display{k} >= start_Off, M.t_AP_display{k} < end_Off));
    if M.spikes_Off(k) > 0
        i_Off(k) = k;
    end
end

M.f_Sp_HA = mean(M.spikes_Sp(intersect(M.N_HA, i_Sp))/(0.5*M.d_period/1000));
M.f_Sp_non_HA = mean(M.spikes_Sp(intersect(M.N_non_HA, i_Sp))/(0.5*M.d_period/1000));
M.f_P_HA = mean(M.spikes_P(intersect(M.N_HA, i_P))/(0.5*M.d_period/1000));
M.f_P_non_HA = mean(M.spikes_P(intersect(M.N_non_HA, i_P))/(0.5*M.d_period/1000));
M.f_Off_HA = mean(M.spikes_Off(intersect(M.N_HA, i_Off))/(0.5*M.d_period/1000));
M.f_Off_non_HA = mean(M.spikes_Off(intersect(M.N_non_HA, i_Off))/(0.5*M.d_period/1000));

M.silent_Sp = 1 - (length(intersect(M.N_HA, i_Sp))/M.n_HA);
M.silent_P = 1 - (length(intersect(M.N_HA, i_P))/M.n_HA);