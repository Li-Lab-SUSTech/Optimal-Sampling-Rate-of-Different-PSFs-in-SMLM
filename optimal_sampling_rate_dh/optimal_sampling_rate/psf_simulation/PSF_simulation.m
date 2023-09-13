function [data_raw] = PSF_simulation(phase_DH,parameters)
%% hyper parameters for PSF model used for fit
% (xemit,yemit,pixelsizeX,pixelsizeY都和实际正好反过来)
parameters.phase = phase_DH;
Nmol = parameters.Nmol;
Npixels = parameters.Npixels;
parameters.sizeX = Npixels;
parameters.sizeY = Npixels;

parameters.xemit = ones(1,Nmol)*0;                             %nm
parameters.yemit = ones(1,Nmol)*0;                             %nm
parameters.zemit = linspace(-parameters.focaldepth,parameters.focaldepth,Nmol)*1;                  %nm
parameters.objStage = linspace(-1,1,Nmol)*0;             %nm

[data_raw] = vectorPSF_Final(phase_DH,parameters);
end