# Abstract
Resolution of single molecule localization microscopy (SMLM) depends on the localization accuracy, which can be improved by utilizing engineered point spread functions (PSF) with delicate shapes. However, the intrinsic pixelation effect of the detector sensor will deteriorate PSFs under different sampling rates. The influence of the pixelation effect to the achieved 3D localization accuracy for different PSF shapes under different signal to background ratio (SBR) and pixel dependent readout noise has not been investigated in detail so far. In this work, we proposed a framework to characterize the 3D localization accuracy of pixelated PSF at different sampling rates. Four different PSFs (astigmatic PSF, double helix (DH) PSF, Tetrapod PSF and 4Pi PSF) were evaluated and the pixel size with optimal 3D localization performance were derived. This work provides a theoretical guide for the optimal design of sampling rate for 3D super resolution imaging. 

# Requirements
Matlab R2019a or newer  

The code runs on macOS and Microsoft Windows 7 or newer, 64-bit

128G RAM

# How to run
These three catalogs corresponds to 4Pi PSF demo, Astigmatic & Tetrapod PSF demo and Double-Helix PSF demo.

Data of 4Pi PSF can be downloaded from [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8340047.svg)](https://doi.org/10.5281/zenodo.8340047).

Example codes are available in the file ***test1.m*** in each demo 

For other PSFs, if you have the zenike coefficients, use Astigmatic & Tetrapod PSF demo, add or replace the coefficients in ***PSF_generate.m***

If you have the pupil function of PSF, use Double-Helix PSF demo, add or replace the phase file.

# Contact
For any questions / comments about this software, please contact [Li Lab](https://faculty.sustech.edu.cn/liym2019/en/).

# Copyright
Copyright (c) 2023 Li Lab, Southern University of Science and Technology, Shenzhen.
