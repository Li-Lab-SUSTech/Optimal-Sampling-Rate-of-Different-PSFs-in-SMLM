function [data_raw,pupil] = psf_generate(int,parameters)
load('data/spiral_phase_zone3_power0.5');
switch int
    case 1
        data_raw = PSF_simulation(phase_DH,parameters);
        pupil = phase_DH;
end

