function M = RNN_INITIALIZATION(M)

    % General initializations -------
    M.ones_1_n = ones(1,M.n);
    M.rand_1_n = rand(1,M.n);
    M.zeros_n_n_t = zeros(M.n,M.n_t);
    M.zeros_n_n_n_t = zeros(M.n,M.n,M.n_t);
    M.zeros_n_E_n_n_t = zeros(M.n_E,M.n,M.n_t);
    M.zeros_n_I_n_n_t = zeros(M.n_I,M.n,M.n_t);
    M.ones_n_n = ones(M.n,M.n);
    M.rand_n_n = rand(M.n,M.n);
    M.randn_n_n = randn(M.n,M.n);

    M.V = M.zeros_n_n_t;
    M.V_0_min = M.V_0_mean - 1/4/sqrt(3) * M.V_0_std;
    M.V_0_max = M.V_0_mean + 1/4/sqrt(3) * M.V_0_std;
    M.V(:,1:M.syn_delay_Idx) = M.V_0_min + (M.V_0_max-M.V_0_min) * rand(M.n,M.syn_delay_Idx);
    M.is_AP = M.zeros_n_n_t;
    M.I_L = M.zeros_n_n_t;

    % Ampa currents -------
    M.I_Ampa = M.zeros_n_n_t;
    M.p_Ampa = M.zeros_n_E_n_n_t;
    M.p_Ampa_sum = M.zeros_n_n_t;

    % Nmda currents (duplicate of Ampa block) -------
    M.I_Nmda = M.zeros_n_n_t;
    M.p_Nmda = M.zeros_n_E_n_n_t;
    M.p_Nmda_sum = M.zeros_n_n_t;

    % GabaA currents -------
    M.I_GabaA = M.zeros_n_n_t;
    M.p_GabaA = M.zeros_n_I_n_n_t;
    M.p_GabaA_sum = M.zeros_n_n_t;

    % GabaB currents (duplicate of GabaA block) -------
    M.I_GabaB = M.zeros_n_n_t;
    M.p_GabaB = M.zeros_n_I_n_n_t;
    M.p_GabaB_sum = M.zeros_n_n_t;

    M.I_Syn = M.zeros_n_n_t;
    M.I_Total = M.zeros_n_n_t;

    M.I_FF_min = M.I_FF_mean - 1/4/sqrt(3) * M.I_FF_std;
    M.I_FF_max = M.I_FF_mean + 1/4/sqrt(3) * M.I_FF_std;
    M.I_FF = M.I_FF_min + (M.I_FF_max - M.I_FF_min) * M.rand_1_n';

    % Synaptic matrix initialization -------
    if M.is_w_distr_constant
        M.W = M.w_mean * M.ones_n_n;
    end
    if M.is_w_distr_uniform
        M.w_min = M.w_mean - 1/4/sqrt(3) * M.w_std;
        M.w_max = M.w_mean + 1/4/sqrt(3) * M.w_std;
        M.W = M.w_min + (M.w_max - M.w_min) * M.rand_n_n;
    end
    if M.is_w_distr_normal
        M.W = M.w_mean + M.w_std * M.randn_n_n;
        M.W(M.W<0) = 0; % no negative weight
    end
    M.W = M.W - diag(diag(M.W)); % no autapse
    A = M.rand_n_n < M.p_C; % create the  sparsness (adjacency) matrix 
    M.W = A .* M.W; % Apply sparsness
    M.W(M.N_I,M.N_I) = M.w_II_Scaling*M.W(M.N_I,M.N_I);
    M.W(M.N_I,M.N_E) = M.w_IE_Scaling*M.W(M.N_I,M.N_E);

    % initialize HA weights
    M.W(M.N_HA, M.N_HA) = M.W(M.N_HA, M.N_HA) + A(M.N_HA, M.N_HA) * (M.w_HA - M.w_mean);

    % make HA weights symmetric
    if M.symmetric_HA_weights
        M.W(M.N_HA, M.N_HA) = max(M.W(M.N_HA, M.N_HA), M.W(M.N_HA, M.N_HA).');
    end

    M.W_E = M.W(M.N_E,M.N);
    M.W_I = M.W(M.N_I,M.N);
    
    % initialize HA phasic current stimulations
    flag_ON = and(M.T >= M.d_period, M.T < M.d_period + M.d_On);
    M.I_On_T = flag_ON * M.I_On;
    flag_OFF = and(M.T >= 2 * M.d_period + M.d_On, M.T < 2 * M.d_period + M.d_On + M.d_Off);
    M.I_Off_T = flag_OFF * M.I_Off;

    % E/I balance -------
    
    M.fact_Ampa = M.dp_Ampa * M.tau_Ampa * (M.V_Ampa - M.V_M);
    M.fact_Nmda = M.dp_Nmda * M.tau_Nmda * (M.V_Nmda - M.V_M) * M.x_Nmda_M;
    M.fact_GabaA = M.dp_GabaA * M.tau_GabaA * (M.V_M - M.V_GabaA);
    M.fact_GabaB = M.dp_GabaB * M.tau_GabaB * (M.V_M - M.V_GabaB);

    M.g_Ampa = M.g_Rec; % maximal conductance (mS.cm-2)
    M.g_Nmda = M.g_Rec*M.rho_slow*M.fact_Ampa/M.fact_Nmda; % maximal conductance (mS.cm-2)    
    M.g_GabaA = M.g_Rec*M.rho_EI*M.p_E/M.p_I*M.fact_Ampa/M.fact_GabaA; % maximal conductance (mS.cm-2)   
    M.g_GabaB = M.g_Rec*M.rho_EI*M.rho_slow*M.p_E/M.p_I*M.fact_Ampa/M.fact_GabaB; % maximal conductance (mS.cm-2)   
   