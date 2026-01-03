clear
tic
warning("off")

n_values = 20;
rho_slow_min = 0.1; rho_slow_max = 5;
rho_slow_values = linspace(rho_slow_min, rho_slow_max, n_values);
disp(rho_slow_values) 
% 0.1000 0.3579 0.6158 0.8737 1.1316 1.3895 1.6474 1.9053 2.1632 2.4211 2.6789 2.9368 3.1947 3.4526 3.7105 3.9684 4.2263 4.4842 4.7421 5.0000

parfor k = 1:n_values
    rho_slow = rho_slow_values(k);

    M = [];
    M = RNN_PARAMETERS(M, 0, 1, 0, 1, rho_slow);
    M = RNN_INITIALIZATION(M);
    M = RNN_SIMULATION(M);
    M = RNN_ANALYSIS(M);

    MapStruct{k}.CV = M.CV_mean;
    MapStruct{k}.rho_synchr = M.rho_synchr;
end

for k = 1:n_values
    MapArr.CV(k) = MapStruct{k}.CV;
    MapArr.rho_synchr(k) = MapStruct{k}.rho_synchr;
end

disp(MapArr.CV)
disp(MapArr.rho_synchr)

toc