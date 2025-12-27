function M = RNN_GRAPHIC_PARAMETERS(M)

M.LineWidth_thin = 1;
M.LineWidth = 3;
M.FontSize = 20;
M.MarkerSize = 25;
M.V_min = M.V_L-10; % (mV)
M.V_max = M.V_P+10; % (mV)
M.p_max = 0.25; % (au)
M.f_max = 50; % (Hz)
M.BackGround_Color = 'w'; M.V_Color = 'k';
M.f_Color = 'k';
M.FF_Color = [0.25 0.5 0.5];
M.L_Color = [0.5 0.25 0.25];
M.Ampa_Color = [0.5 1 1];
M.Nmda_Color = [0 1 0.5];
M.GabaA_Color = [1 0.5 0];
M.GabaB_Color = [1 0 0.5];
M.Total_Color = [0.5 0.5 0.5];
M.Syn_Color = [0 0 0];
M.n_MAP = M.n; M.Color_MAP = turbo(M.n_MAP); M.BW_MAP = gray(M.n_MAP);
M.n_exemple = 10;
M.DV_exemple = 10;