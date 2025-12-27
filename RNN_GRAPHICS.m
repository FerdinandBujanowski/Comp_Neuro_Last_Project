function M = RNN_GRAPHICS(M)

    M.Fig_No = 0;

    % spikes all neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color','w'); colormap(M.Color_MAP);
    for k = 1:M.n
        scatter(M.t_AP_display{k},M.neuron_AP_display{k},M.MarkerSize,M.neuron_AP_display{k},"filled");
    end
    title('spikes'); xlabel('time (ms)'); ylabel('# neuron');
    axis([min(M.T) max(M.T) 1 M.n]);
    set(gca,'FontSize',M.FontSize)

    % estimated frequency all neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('estimated frequency'); xlabel('time (ms)'); ylabel('# neuron');
    imagesc(M.T,M.N,M.f_est); shading flat; colormap(M.Color_MAP); colorbar
   % axis([min(M.T) max(M.T) 1 M.n]); caxis([M.V_R M.V_S])
    set(gca,'FontSize',M.FontSize);

    % mean frequency across neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('mean frequency across neurons'); xlabel('time (ms)'); ylabel('f (Hz)');
    plot([0 M.t_max],[M.V_S M.V_S],[M.V_Color ':'],'LineWidth',M.LineWidth)
    plot(M.T,M.f_est_mean_time,M.V_Color,'LineWidth',M.LineWidth)
    axis([min(M.T) max(M.T) 0 M.f_max])
    set(gca,'FontSize',M.FontSize)

    % potential all neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('voltage'); xlabel('time (ms)'); ylabel('# neuron');
    imagesc(M.T,M.N,M.V); shading flat; colormap(M.Color_MAP); colorbar
    axis([min(M.T) max(M.T) 1 M.n]); caxis([M.V_R M.V_S])
    set(gca,'FontSize',M.FontSize);

    % potential exemple Exc neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('potential of individual neurons'); xlabel('time (ms)'); ylabel('V (mV)');
    h_exemple = [];
    for k_exemple = 1:M.n_exemple
        plot([0 M.t_max],[M.V_S M.V_S]+k_exemple*M.DV_exemple,[M.V_Color ':'],'LineWidth',M.LineWidth_thin)
        V_show = find(M.V(k_exemple,:)<M.V_S);
        h_tmp = plot(M.T(V_show),M.V(k_exemple,V_show)+k_exemple*M.DV_exemple,'Color',M.Color_MAP(round(1+(M.n_MAP-1)*k_exemple/M.n_exemple),:),'LineWidth',M.LineWidth,'Display',['nrn #' num2str(k_exemple)]);
        h_exemple = [h_exemple h_tmp];
    end
    axis off %([min(M.T) max(M.T) M.V_min M.V_max])
    set(gca,'FontSize',M.FontSize)

    % mean currents across neurons -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('mean currents across neurons'); xlabel('time (ms)'); ylabel('µA.cm^{-2}');
    plot([0 M.t_max],[0 0],'k:','LineWidth',M.LineWidth)
    h_FF = plot(M.T,0*M.T-M.I_FF_mean,'Color',M.FF_Color,'LineWidth',M.LineWidth,'Display','-I_{FF}');
    h_L = plot(M.T,M.I_L_mean,'Color',M.L_Color,'LineWidth',M.LineWidth,'Display','I_{L}');
    h_Ampa = plot(M.T,M.I_Ampa_mean,'Color',M.Ampa_Color,'LineWidth',M.LineWidth,'Display','I_{Ampa}');
    h_Nmda = plot(M.T,M.I_Nmda_mean,'Color',M.Nmda_Color,'LineWidth',M.LineWidth,'Display','I_{Ampa}');
    % h_Ampa_minus = plot(M.T,-M.I_Ampa_mean,[M.Ampa_Color ':'],'LineWidth',M.LineWidth,'Display','-I_{Ampa}');
    % h_Nmda_minus = plot(M.T,-M.I_Nmda_mean,'Color',M.Nmda_Color,'LineWidth',M.LineWidth,'Display','-I_{Nmda}');
    h_GabaA = plot(M.T,M.I_GabaA_mean,'Color',M.GabaA_Color,'LineWidth',M.LineWidth,'Display','I_{GabaA}');
    h_GabaB = plot(M.T,M.I_GabaB_mean,'Color',M.GabaB_Color,'LineWidth',M.LineWidth,'Display','I_{GabaB}');
    h_Syn = plot(M.T,M.I_Syn_mean,'Color',M.Syn_Color,'LineWidth',M.LineWidth,'Display','I_{Synaptic}');
    h_Total = plot(M.T,M.I_Total_mean,'Color',M.Total_Color,'LineWidth',M.LineWidth,'Display','I_{Total}');
    if M.I_min~=M.I_max; axis([min(M.T) max(M.T) M.I_min M.I_max]); end
    set(gca,'FontSize',M.FontSize)
    %legend('show',[h_FF h_L h_Ampa h_Ampa_minus h_Nmda h_Nmda_minus h_GabaA h_GabaB h_Syn h_Total])
    legend('show',[h_FF h_L h_Ampa h_Nmda h_GabaA h_GabaB h_Syn h_Total])

    % neuron Pearson's correlations -----

    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    Cov_Max = 1.5*max(abs(M.f_Cov));
    Cov_Edges = [-Cov_Max:Cov_Max/50:Cov_Max];
    n_Edges = length(Cov_Edges);
    Cov_Centers = (Cov_Edges(2:n_Edges)+Cov_Edges(1:n_Edges-1))/2;
    pdf_f_Cov = histcounts(M.f_Cov,Cov_Edges,'Normalization','probability');
    pdf_f_Cov_max = max(pdf_f_Cov);
    bar(Cov_Centers,pdf_f_Cov,'FaceColor','k','EdgeColor','k')
    axis([-Cov_Max Cov_Max 0 1.25*pdf_f_Cov_max]);
    set(gca,'FontSize',M.FontSize)
    title(['firing rate corr. /mu : ' num2str(M.R_synchr_mean) ' / \sigma : ' num2str(M.R_synchr_std)]); xlabel('rate correlation'); ylabel('pdf');

    % synaptic matrix -----
    M.Fig_No = M.Fig_No + 1;
    figure(M.Fig_No); clf; hold on; box on; set(gcf,'color',M.BackGround_Color);
    title('weights'); xlabel('# postsynaptic neuron'); ylabel('# presynaptic neuron');
    imagesc(M.N,M.N,M.W); shading flat; colormap(M.Color_MAP); colorbar
    axis([1 M.n 1 M.n]); axis square
    set(gca,'FontSize',M.FontSize);    