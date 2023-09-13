function draw(parameters,ps,crlb4pi_100,crlbatz,crlb_revised,crlb_xy_revised,crlb_z_revised)
    %%plot 4pi 100nm crlb at different z-depth
    start = parameters.zstart;
    step = 2*abs(parameters.zstart)/(parameters.Nmol-1);
    stop = -parameters.zstart-step;
    z = start:step:stop;

    figure1 = figure('Color',[1 1 1]);
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    plot(z,crlb4pi_100(1,:),'LineWidth',3.5,'Color',[0.247058824,0.168627451,0.42745098]);hold on
    plot(z,crlb4pi_100(2,:),'LineWidth',3.5,'Color',[0.941176471,0.392156863,0.28627451]);hold on
    plot(z,crlb4pi_100(3,:),'LineWidth',3.5,'Color',[1,0.666666667,0.196078431]);
    xlabel('z depth/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylabel('CRLB^{1/2}/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylim([0 16]);
    box(axes1,'on');
    hold(axes1,'off');
    set(axes1,'FontName','Arial','FontWeight','bold','FontSize',12);
    legend('CRLB^{1/2}_{x}','CRLB^{1/2}_{y}','CRLB^{1/2}_{z}','FontSize',10,'FontName','Arial','FontWeight','bold');


    %%plot 4pi crlb versus pixel size at different z-depth
    figure2 = figure('Color',[1 1 1]);
    axes2 = axes('Parent',figure2);
    hold(axes2,'on');
    plot(ps,crlbatz(1,:),'LineWidth',3.5,'Color',[0.247058824,0.168627451,0.42745098]); hold on
    plot(ps,crlbatz(14,:),'LineWidth',3.5,'Color',[0.941176471,0.392156863,0.28627451]); hold on
    plot(ps,crlbatz(26,:),'LineWidth',3.5,'Color',[1,0.666666667,0.196078431]); hold on
    plot(ps,crlbatz(39,:),'LineWidth',3.5,'Color',[0.188235294,0.592156863,0.643137255]); hold on
    plot(ps,crlbatz(51,:),'LineWidth',3.5,'Color',[0.019607843,0.31372549,0.356862745]);
    ylim([0 35]);
    xlim([40 240]);
    xlabel('pixel size/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylabel('CRLB^{1/2}_{3d}/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    box(axes2,'on');
    hold(axes2,'off');
    set(axes2,'FontName','Arial','FontWeight','bold','FontSize',12);
    legend('600nm','450nm','300nm','150nm','0nm','FontSize',10,'FontName','Arial','FontWeight','bold')


    %%plot 4pi crlb_3d versus pixel size under different photons
    ps1 = 30:1:250;
    figure3 = figure('Color',[1 1 1]);
    axes3 = axes('Parent',figure3);
    hold(axes3,'on');
    plot(ps1,crlb_revised(1,:),'LineWidth',3.5,'Color',[0.247058824,0.168627451,0.42745098]); hold on
    plot(ps1,crlb_revised(2,:),'LineWidth',3.5,'Color',[0.941176471,0.392156863,0.28627451]); hold on
    plot(ps1,crlb_revised(3,:),'LineWidth',3.5,'Color',[1,0.666666667,0.196078431]); hold on
    plot(ps1,crlb_revised(4,:),'LineWidth',3.5,'Color',[0.188235294,0.592156863,0.643137255]);
    ylim([0 15]);
    xlim([30 250]);
    xlabel('pixel size/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylabel('CRLB^{1/2}_{3d}/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    box(axes3,'on');
    hold(axes3,'off');
    set(axes3,'FontName','Arial','FontWeight','bold','FontSize',12);
    legend('1000','2000','3000','10000')


    %%plot 4pi crlb_lateral versus pixel size under different photons
    figure4 = figure('Color',[1 1 1]);
    axes4 = axes('Parent',figure4);
    hold(axes4,'on');
    plot(ps1,crlb_xy_revised(1,:),'LineWidth',3.5,'Color',[0.247058824,0.168627451,0.42745098]); hold on
    plot(ps1,crlb_xy_revised(2,:),'LineWidth',3.5,'Color',[0.941176471,0.392156863,0.28627451]); hold on
    plot(ps1,crlb_xy_revised(3,:),'LineWidth',3.5,'Color',[1,0.666666667,0.196078431]); hold on
    plot(ps1,crlb_xy_revised(4,:),'LineWidth',3.5,'Color',[0.188235294,0.592156863,0.643137255]);
    ylim([0 15]);
    xlim([30 250]);
    xlabel('pixel size/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylabel('CRLB^{1/2}_{lateral}/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    box(axes4,'on');
    hold(axes4,'off');
    set(axes4,'FontName','Arial','FontWeight','bold','FontSize',12);
    legend('1000','2000','3000','10000')


    %%plot 4pi crlb_axial versus pixel size under different photons
    figure5 = figure('Color',[1 1 1]);
    axes5 = axes('Parent',figure5);
    hold(axes5,'on');
    plot(ps1,crlb_z_revised(1,:),'LineWidth',3.5,'Color',[0.247058824,0.168627451,0.42745098]); hold on
    plot(ps1,crlb_z_revised(2,:),'LineWidth',3.5,'Color',[0.941176471,0.392156863,0.28627451]); hold on
    plot(ps1,crlb_z_revised(3,:),'LineWidth',3.5,'Color',[1,0.666666667,0.196078431]); hold on
    plot(ps1,crlb_z_revised(4,:),'LineWidth',3.5,'Color',[0.188235294,0.592156863,0.643137255]);
    ylim([0 4]);
    xlim([30 250]);
    xlabel('pixel size/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    ylabel('CRLB^{1/2}_{axial}/nm','FontSize',15,'FontName','Arial','FontWeight','bold');
    box(axes5,'on');
    hold(axes5,'off');
    set(axes5,'FontName','Arial','FontWeight','bold','FontSize',12);
    legend('1000','2000','3000','10000')
end

