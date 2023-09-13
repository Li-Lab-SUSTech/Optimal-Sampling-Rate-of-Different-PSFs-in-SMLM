function [parameters] = setting_parameters()

parameters.NA = 1.50;                                                % numerical aperture of obj             
parameters.refmed = 1.518;                                           % refractive index of sample medium
parameters.refcov = 1.518;                                           % refractive index of converslip
parameters.refimm = 1.518;                                           % refractive index of immersion oil
parameters.lambda = 660;                                             % wavelength of emission
parameters.objStage0 = -2000;                                        % nm, initial objStage0 position,relative to focus at coverslip
parameters.zemit0 = -1*parameters.refmed/parameters.refimm*(parameters.objStage0);  % reference emitter z position, nm, distance of molecule to coverslip
parameters.pixelSizeX0 = 2;                                       
parameters.pixelSizeY0 = 2;
parameters.Npixels = 3000;
parameters.range = parameters.pixelSizeX0 * parameters.Npixels;
parameters.Npupil = 128;                                             % sampling at the pupil plane

parameters.focaldepth = 600;
parameters.Nmol = 101;
parameters.interval = 2*parameters.focaldepth / (parameters.Nmol-1);

parameters.xemit = 0;                             %nm
parameters.yemit = 0;                             %nm
parameters.zemit = -600;                  %nm

parameters.objStage = 0;             %nm

end

