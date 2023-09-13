function [x_crlb,xy_crlb,z_crlb,crlb,crlb_at_z] = compute_CRLB(data_raw,ps,parameters)
parameters. pixelSizeX = ps;                                        % nm, pixel size of the image
parameters. pixelSizeY = ps;                                        % nm, pixel size of the image
parameters.NX = floor(parameters.range / ps);
parameters.NY = floor(parameters.range / ps);
ps0 = parameters.pixelSizeX0;

data = zeros(parameters.NX,parameters.NY,parameters.Nmol);
PSF = zeros(parameters.NX,parameters.NY,parameters.Nmol);
model = zeros(parameters.NX,parameters.NY,parameters.Nmol);

for k = 1:parameters.Nmol
    for i = 1:parameters.NX
        for j = 1:parameters.NY
            data_temp = data_raw(floor((i-1)*ps/ps0+1):floor(i*ps/ps0), floor((j-1)*ps/ps0+1):floor(j*ps/ps0), k);
            PSF(i,j,k) = sum(data_temp(:));
            data(i,j,k) = poissrnd(parameters.Nphotons * PSF(i,j,k)+parameters.bg*ps*ps/10000)+parameters.rd;
            model(i,j,k) = parameters.Nphotons * PSF(i,j,k)+parameters.bg*ps*ps/10000+parameters.rd;
        end
    end
    %model(floor(0.5*parameters.NX),floor(0.5*parameters.NY),k) = model(floor(0.5*parameters.NX),floor(0.5*parameters.NY),k)+20; %adding a hot pixel at the center
end
%% get CRLB
numparams = 5;
parameters.numparams = numparams;

Nph_GT = parameters.Nphotons;
x0_GT = 0;
y0_GT = 0;
z0_GT = 0;

Theta = zeros(5,1);
Theta(1)=x0_GT;
Theta(2)=y0_GT;
Theta(3)=z0_GT;
Theta(4)=Nph_GT;
Theta(5)=ps;

parameters.zemitStack = zeros(size(data,3),1)'; % move emitter
parameters.objStageStack = zeros(size(data,3),1)'; %move objStage
parameters.ztype = 'emitter';
parameters.sizeZ = length(parameters.zemit);
sqrt_crlb = zeros(5,ps/ps0);
for i = 1:1:(ps/ps0)
    [fisher] = get_fisher(data_raw,PSF,model,Theta,parameters,i);
    exprnd(1);
    sqrt_crlb_tmp = zeros(5,parameters.Nmol-1);
    %% plot crlb
    for k = 1:parameters.Nmol-1
    sqrt_crlb_tmp(:,k) = sqrt(diag(inv(fisher(:,:,k))));
    end
    sqrt_crlb(:,i) = sum(sqrt_crlb_tmp,2)/parameters.Nmol-1;
    crlb_atz(:,:,i) = sqrt_crlb_tmp;
end
crlb = sum(sqrt_crlb,2)/(ps/ps0);
x_crlb=crlb(1);
y_crlb=crlb(2);
z_crlb=crlb(3);
crlb_at_z = sum(crlb_atz,3)/(ps/ps0);
xy_crlb = sqrt(x_crlb^2+y_crlb^2);
crlb = sqrt(x_crlb^2+y_crlb^2+z_crlb^2);
% 对所有的sqrt(crlb_xy求和)
clc;
%disp([num2str(ps*100/ps_max),'%']);
end