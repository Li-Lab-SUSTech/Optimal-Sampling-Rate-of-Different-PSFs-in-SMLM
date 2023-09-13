function [fisher] =  get_fisher(data_raw,PSF,model,Theta,parameters,iter)
% dudtheta 是每一张图片的每个pixel关于所有参数的偏微分
[dudx,dudy,dudz] =  get_Derivative(data_raw,PSF,Theta,parameters,iter);
ps = parameters. pixelSizeX;

fisher = zeros(5,5,parameters.Nmol-1);
hotpixel_number = floor((parameters.NX-1)*0.2);

% adding hot pixel
% for i = 1 : hotpixel_number
%     hotpixel_x(i) = round(rand*(hotpixel_number-1))+1;
%     hotpixel_y(i) = round(rand*(hotpixel_number-1))+1;
% end
% hotnoise_map = zeros(parameters.NX-1,parameters.NY-1);
% for i = 1:hotpixel_number
%     for j = 1:hotpixel_number
%         hotnoise_map(hotpixel_x(i),hotpixel_y(j)) = 10;
%     end
% end

for k = 1:parameters.Nmol-1
    dudtheta(:,:,1) = dudx(:,:,k);
    dudtheta(:,:,2) = dudy(:,:,k);
    dudtheta(:,:,3) = dudz(:,:,k);
    dudtheta(:,:,4) = PSF(1:parameters.NX-1,1:parameters.NY-1,k);
    dudtheta(:,:,5) = ones(parameters.NX-1,parameters.NY-1).*ps*ps/10000;
    t2 = 1./model(1:parameters.NX-1,1:parameters.NY-1,k);
    for m = 1:5
        temp1 = dudtheta(:,:,m); 
        for n = m:5
                temp2 = dudtheta(:,:,n);
                temp = t2.*temp1.*temp2;
                fisher(m,n,k) = sum(temp(:));
                fisher(n,m,k) = fisher(m,n,k);  
        end
    end
end

end








