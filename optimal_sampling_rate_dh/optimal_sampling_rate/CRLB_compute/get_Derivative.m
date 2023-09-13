function [dudx,dudy,dudz] =  get_Derivative(data_raw,PSF,Theta,parameters,iter)

NX = parameters.NX;
NY = parameters.NY;
pixelsizeX0 = parameters. pixelSizeX0;
pixelsizeY0 = parameters. pixelSizeY0;
pixelsizeX = parameters. pixelSizeX;
pixelsizeY = parameters. pixelSizeY;

dudx = zeros(NX-1,NY-1,parameters.Nmol-1);
dudy = zeros(NX-1,NY-1,parameters.Nmol-1);
dudz = zeros(NX-1,NY-1,parameters.Nmol-1);

for k = 1:parameters.Nmol-1
    for i = 1:NX-1
        for j = 1:NY-1
            dudx(i,j,k) = Theta(4) * (sum(data_raw(floor(i * pixelsizeX/pixelsizeX0+iter),floor((j-1)*pixelsizeY/pixelsizeY0 + 1) : floor(j*pixelsizeY/pixelsizeY0),k)) - sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1+iter),floor((j-1)*pixelsizeY/pixelsizeY0 + 1) : floor(j*pixelsizeY/pixelsizeY0),k))) / pixelsizeX0;
            dudy(i,j,k) = Theta(4) * (sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1) : floor(i*pixelsizeX/pixelsizeX0),floor(j * pixelsizeY/pixelsizeY0)+iter,k)) - sum(data_raw(floor((i-1)*pixelsizeX/pixelsizeX0 + 1) : floor(i*pixelsizeX/pixelsizeX0),floor((j-1)*pixelsizeY/pixelsizeY0+iter+1),k))) / pixelsizeY0;
            dudz(i,j,k) = Theta(4) * (PSF(i,j,k+1)-PSF(i,j,k))/parameters.interval;
        end
    end
end
end



