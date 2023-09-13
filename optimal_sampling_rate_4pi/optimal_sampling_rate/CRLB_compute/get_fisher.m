function [fisher] =  get_fisher(data_raw,PSF,model,Theta,parameters,iter)
% dudtheta 是每一张图片的每个pixel关于所有参数的偏微分
[dudx,dudy,dudz] =  get_Derivative(data_raw,PSF,Theta,parameters,iter);
ps = parameters. pixelSizeX;

fisher = zeros(5,5,parameters.Nmol-1,4);

for iter1 = 1:4
    for k = 1:parameters.Nmol-1
        dudtheta(:,:,1) = dudx(:,:,k,iter1);
        dudtheta(:,:,2) = dudy(:,:,k,iter1);
        dudtheta(:,:,3) = dudz(:,:,k,iter1);
        dudtheta(:,:,4) = PSF(1:parameters.NX-1,1:parameters.NY-1,k,iter1);
        dudtheta(:,:,5) = ones(parameters.NX-1,parameters.NY-1).*ps*ps/10000;
        t2 = 1./model(1:parameters.NX-1,1:parameters.NY-1,k,iter1);
        for m = 1:5
            temp1 = dudtheta(:,:,m); 
            for n = m:5
                    temp2 = dudtheta(:,:,n);
                    temp = t2.*temp1.*temp2;
                    fisher(m,n,k,iter1) = sum(temp(:));
                    fisher(n,m,k,iter1) = fisher(m,n,k,iter1);  
            end
        end
    end
end
fisher = sum(fisher,4);
end








