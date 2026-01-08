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
M.I_FF_mean_all = mean(M.I_FF_mean);

M.I_L_mean = mean(M.I_L,1);
M.I_L_mean_all = mean(M.I_L_mean);

M.I_Ampa_mean = mean(M.I_Ampa,1);
M.I_Ampa_mean_all = mean(M.I_Ampa_mean);

% M.I_Nmda_mean = mean(M.I_Nmda,1);

M.I_GabaA_mean = mean(M.I_GabaA,1);
M.I_GabaA_mean_all = mean(M.I_GabaA_mean);

% M.I_GabaB_mean = mean(M.I_GabaB,1);
M.I_Syn_mean = mean(M.I_Syn,1);
M.I_Syn_mean_all = mean(M.I_Syn_mean);

M.I_Total_mean = mean(M.I_Total,1);
M.I_Total_mean_all = mean(M.I_Total_mean);

M.I_max = 2.5*max(abs([mean(M.I_Ampa_mean) mean(M.I_GabaA_mean)]));
%M.I_max = 2.5*max(abs([mean(M.I_Ampa_mean) mean(M.I_GabaA_mean) mean(M.I_Nmda_mean) mean(M.I_GabaB_mean)]));
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