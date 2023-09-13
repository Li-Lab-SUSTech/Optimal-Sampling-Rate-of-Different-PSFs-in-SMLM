function [data_raw] = psf_generate(int)
load('data/fourpi.mat');
switch int
    case 1
        data_raw = fourpi;
end

