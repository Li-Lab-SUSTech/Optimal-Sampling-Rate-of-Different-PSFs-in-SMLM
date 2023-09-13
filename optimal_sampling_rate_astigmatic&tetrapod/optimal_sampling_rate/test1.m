%%Please remember to rename the folder name "data/psf" after the program
%%automatically saves the data, if you want to save these data
%% Generate a PSF (zenike coefficients can be modified in psf_generate.m) 
%CASE 1 Astigmatic PSF (80)
%CASE 2 Tetrapod PSF
[parameters] = setting_parameters();
psftype = input('Confirm PSF type:');
[data_raw, pupil] = psf_generate(psftype,parameters);
parameters.ps_max = 250;
parameters.bg = 20;   %background noise
parameters.rd = 2;    %readout noise
ps = [30,40,50,60,80,100,120,150,200,250];
Nphs = [2000,4000,6000,20000];
%% Compute CRLB at different pixel size
iter1 = 1;
for j = 1:4
    parameters.Nphotons = Nphs(j);
    iter = 1;
    for i = 1 : 10
        ps1 = ps(i);
          [x_crlb(iter),xy_crlb(iter),z_crlb(iter),crlb(iter),crlb_at_z(:,:,iter)] = compute_CRLB(data_raw,ps1,parameters); %airy tetrapod astigmatic simulation
        iter = iter + 1;
    end
    if j == 1
        crlb_100 = crlb_at_z(:,:,6);    %100nm results
        crlbatz = squeeze(sqrt(crlb_at_z(1,:,:).^2+crlb_at_z(2,:,:).^2+crlb_at_z(3,:,:).^2)); 
    end
    %% Drawing curve
    [f] = curve_drawing(x_crlb');  %x_crlb versus pixel size
        a = f.a;               
        b = f.b;
        c = f.c;
        d = f.d;
        e = f.e;
    [f1] = curve_drawing(xy_crlb');  %xy_crlb versus pixel size
        a1 = f1.a;
        b1 = f1.b;
        c1 = f1.c;
        d1 = f1.d;
        e1 = f1.e;
    [f2] = curve_drawing(z_crlb');  %z_crlb versus pixel size
        a2 = f2.a;
        b2 = f2.b;
        c2 = f2.c;
        d2 = f2.d;
        e2 = f2.e;
    [f3] = curve_drawing(crlb');  %xyz_crlb versus pixel size
        a3 = f3.a;
        b3 = f3.b;
        c3 = f3.c;
        d3 = f3.d;
        e3 = f3.e;
    x1 = 30 : 1 : parameters.ps_max;
    for iter2 = 1:221
        crlb_x_revised(iter1,iter2) = a*x1(iter2)^(-2)+b*x1(iter2)^(-1)+c*x1(iter2)^2+d*x1(iter2)+e;
        crlb_xy_revised(iter1,iter2) = a1*x1(iter2)^(-2)+b1*x1(iter2)^(-1)+c1*x1(iter2)^2+d1*x1(iter2)+e1;
        crlb_z_revised(iter1,iter2) = a2*x1(iter2)^(-2)+b2*x1(iter2)^(-1)+c2*x1(iter2)^2+d2*x1(iter2)+e2;
        crlb_revised(iter1,iter2) = a3*x1(iter2)^(-2)+b3*x1(iter2)^(-1)+c3*x1(iter2)^2+d3*x1(iter2)+e3;
    end
%     ps_optimal_x(iter1) = x1(find(crlb_x_revised==min(crlb_x_revised)));
%     ps_optimal_xy(iter1) = x1(find(crlb_xy_revised==min(crlb_xy_revised)));
%     ps_optimal_z(iter1) = x1(find(crlb_z_revised==min(crlb_z_revised)));
%     ps_optimal(iter1) = x1(find(crlb_revised==min(crlb_revised)));
%     crlbmin(iter1)=min(crlb_revised);
    iter1 = iter1 + 1;
end
save('optimal_sampling_rate\data\psf\crlb_revised.mat',"crlb_revised");
save('optimal_sampling_rate\data\psf\crlb_z_revised.mat',"crlb_z_revised");
save('optimal_sampling_rate\data\psf\crlb_xy_revised.mat',"crlb_xy_revised");
save('optimal_sampling_rate\data\psf\crlbatz.mat',"crlbatz");
save('optimal_sampling_rate\data\psf\crlbdh_100.mat',"crlb_100");
draw(parameters,ps,crlb_100,crlbatz,crlb_revised,crlb_xy_revised,crlb_z_revised);