function [dudx,dudy,dudz] =  get_Derivative(data_raw,PSF,Theta,parameters,iter)

NX = parameters.NX;
NY = parameters.NY;
pixelsizeX0 = parameters. pixelSizeX0;
pixelsizeY0 = parameters. pixelSizeY0;
pixelsizeX = parameters. pixelSizeX;
pixelsizeY = parameters. pixelSizeY;

dudx = zeros(NX-1,NY-1,parameters.Nmol-1,4);
dudy = zeros(NX-1,NY-1,parameters.Nmol-1,4);
dudz = zeros(NX-1,NY-1,parameters.Nmol-1,4);
for iter1 = 1:4
    for k = 1:parameters.Nmol-1
        for i = 1:NX-1
            for j = 1:NY-1
                dudx(i,j,k,iter1) = Theta(4) * (sum(data_raw(floor(i * pixelsizeX/pixelsizeX0+iter),floor((j-1)*pixelsizeY/pixelsizeY0 + 1) : floor(j*pixelsizeY/pixelsizeY0),k,iter1)) - sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1+iter),floor((j-1)*pixelsizeY/pixelsizeY0 + 1) : floor(j*pixelsizeY/pixelsizeY0),k,iter1))) / pixelsizeX0;
                dudy(i,j,k,iter1) = Theta(4) * (sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1) : floor(i*pixelsizeX/pixelsizeX0),floor(j * pixelsizeY/pixelsizeY0)+iter,k,iter1)) - sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1) : floor(i*pixelsizeX/pixelsizeX0),floor((j-1)*pixelsizeY/pixelsizeY0+iter+1),k,iter1))) / pixelsizeY0;
                dudz(i,j,k,iter1) = Theta(4) * (PSF(i,j,k+1,iter1)-PSF(i,j,k,iter1))/ parameters.interval;
            end
        end
    end
end
end



