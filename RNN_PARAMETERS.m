function M = RNN_PARAMETERS(M, param_n_HA, param_w_HA_scaler, symmetric_HA_weights)

% Time -------
M.d_On = 50; % duration of ON stimulation (ms)
M.d_Off = 50; % duration of OFF stimulation (ms)
M.d_period = 200; % (ms)

M.t_max = 3 * M.d_period + M.d_On + M.d_Off; % max simulation time (ms)
M.dt = 0.25; % time step (ms)
M.dt = 0.5; % time step (ms)
M.T = (0:M.dt:M.t_max-M.dt); % time array (ms)
M.n_t = length(M.T); % # of time steps

% Network structure -------
M.n = 500; % # of neurons
M.p_E = 0.8; % fraction of excitatory neurons
M.p_I = 1 - M.p_E;  % fraction of inhibitory neurons
M.n_E = round(M.p_E * M.n); % # of excitatory neurons
M.n_I = M.n - M.n_E; % # of inhibitory neurons
M.N = 1:M.n; % vector of all neuron's indices
M.N_E = 1:M.n_E; % vector of excitatory neuron's indices
M.N_I = M.n_E+1:M.n; % vector of inhibitory neuron's indices
M.Is_E = [ones(M.n_E,1); zeros(M.n_I,1)]; % who is excitatory
M.Is_I = [zeros(M.n_E,1); ones(M.n_I,1)]; % who is inhibitory

M.symmetric_HA_weights = symmetric_HA_weights;

% Synaptic transmission -------
M.syn_delay_ms = 1.5; % ms
M.syn_delay_Idx = round(M.syn_delay_ms/M.dt); % au
M.p_C = 0.1; % Sparsity

M.is_w_distr_constant = 0;
M.is_w_distr_uniform = 1;
M.is_w_distr_normal = 0;
M.w_mean = 0.01;
M.w_std_mean_factor = 5;
M.w_std = M.w_mean*M.w_std_mean_factor; % au

M.g_Rec = 2500/M.n; % mScm-2
M.g_Rec = 1000/M.n; % mScm-2

M.w_II_Scaling = 1;
M.w_IE_Scaling = 1;

M.rho_EI = 1; % EI balance scaling factor
M.rho_slow = 1; % EI balance scaling factor

% Excitability -------
M.C = 1; % membrane capacitance (µS.cm-2)
M.g_L = 0.05; % leak conductance (mS.cm-2)
M.V_L = -70; % leak reversal potential (mV)
M.V_S = -50; % spike threshold (mV)
M.V_R = -65; % repolarization potential (mV)
M.V_M = -55; % estimated mean potential (mV)
M.V_P = 20; % spike maximum potential (mV)
M.V_0_mean = M.V_M;
M.V_0_std = 0;

% External input -------
M.I_FF_mean = 1.05; % µAcm-2
M.I_FF_std = 0; % µAcm-2
M.I_On = 2 * M.I_FF_mean; % µAcm-2
M.I_Off = -2 * M.I_FF_mean; % µAcm-2

% Ampa channel receptors -------
M.tau_Ampa = 3; % time constant (ms)
M.dp_Ampa = 0.1; % increment (au)
M.V_Ampa = 0; % reversal potential (mV)

% Nmda channel receptors -------
M.tau_Nmda = 75; % time constant (ms)
M.dp_Nmda = 0.1; % increment (au)
M.V_Nmda = 0; % reversal potential (mV)
M.Mg = 0.28; % mM
M.x_Nmda_M = (1+M.Mg*exp(-0.062*M.V_M)).^(-1);

% GabaA channel receptors -------
M.tau_GabaA = 10; % time constant (ms)
M.dp_GabaA = 0.1; % increment (au)
M.V_GabaA = -60; % reversal potential (mV)

% GabaB channel receptors -------
M.tau_GabaB = 150; % time constant (ms)
M.dp_GabaB = 0.1; % increment (au)
M.V_GabaB = -90; % reversal potential (mV)

% Hebbian Assembly --------------
M.n_HA = param_n_HA;
M.w_HA = param_w_HA_scaler * M.w_mean;
M.N_HA = 1:M.n_HA;
M.N_non_HA = M.n_HA+1:M.n;