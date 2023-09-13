function [PSFs,pupil] = vectorPSF_Final(parameters)
%% parameters: NA, refractive indices of medium, cover slip, immersion fluid,
% wavelength (in nm), sampling in pupil
%optics para
% add norm function comparecd to v3 #need test
% add pixelX Y 
NA = parameters.NA;
refmed = parameters.refmed;
refcov = parameters.refcov;
refimm = parameters.refimm;
lambda = parameters.lambda;

%image para
xemit = parameters.xemit;
yemit = parameters.yemit;
zemit = parameters.zemit;
objStage=parameters.objStage;
zemit0 = parameters.zemit0;

objStage0 = parameters.objStage0;
Npupil = parameters.Npupil;
sizeX = parameters.sizeX;
sizeY = parameters.sizeY;
sizeZ = parameters.Nmol;
pixelSizeX0 = parameters.pixelSizeX0;
pixelSizeY0 = parameters.pixelSizeY0;
xrange = pixelSizeX0*sizeX/2; %117*17/2  nm
yrange = pixelSizeY0*sizeY/2; %127*17/2  nm

%% pupil radius (in diffraction units) and pupil coordinate sampling
PupilSize = 1.0;
DxyPupil = 2*PupilSize/Npupil;
XYPupil = (-PupilSize+DxyPupil/2) :DxyPupil:PupilSize;
[YPupil,XPupil] = meshgrid(XYPupil,XYPupil);

%% calculation of relevant Fresnel-coefficients for the interfaces
% between the medium and the cover slip and between the cover slip
% and the immersion fluid   
CosThetaMed = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2);  %fast focus field calculation��ʽ1
CosThetaCov = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refcov^2);  %Ncov*SinThetaCov=Nmed*SinThetaMed
CosThetaImm = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refimm^2);   %ͬ��+
%need check again, compared to original equation, FresnelPmedcov is
%multipiled by refmed  ������ϵ��p����s����͸��
FresnelPmedcov = 2*refmed*CosThetaMed./(refmed*CosThetaCov+refcov*CosThetaMed);
FresnelSmedcov = 2*refmed*CosThetaMed./(refmed*CosThetaMed+refcov*CosThetaCov);
FresnelPcovimm = 2*refcov*CosThetaCov./(refcov*CosThetaImm+refimm*CosThetaCov);
FresnelScovimm = 2*refcov*CosThetaCov./(refcov*CosThetaCov+refimm*CosThetaImm);
FresnelP = FresnelPmedcov.*FresnelPcovimm; %P��͸��ϵ��
FresnelS = FresnelSmedcov.*FresnelScovimm; %S��͸��ϵ��

% Apoidization for sine condition
% apoid = sqrt(CosThetaImm)./CosThetaMed;  %��ͨ��ֺ�����ù�ͫ��͸���ʱ仯�ǽ�Ծʽ�����ǻ�����ʽ�������μ�����Ӱ�죬����������ֺ����һ�ֺ���
apoid = 1./sqrt(CosThetaImm);  % add by fs
% apoid = 1./sqrt(CosThetaMed);  % add by fs

% definition aperture
ApertureMask = double((XPupil.^2+YPupil.^2)<1.0);
Amplitude = ApertureMask.*apoid;  %������һ�¹�ͫ���������

% setting of vectorial functions    ����pupil��ÿ����ķ�λ�ǣ�����ᴹֱ���棩
Phi = atan2(YPupil,XPupil);
CosPhi = cos(Phi);
SinPhi = sin(Phi);
CosTheta = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2); %�����CosThetaMed��Ҳ���������н�,Ϊʲô����ThetaImm
SinTheta = sqrt(1-CosTheta.^2);

pvec{1} = FresnelP.*CosTheta.*CosPhi;  %�����й�ʽ2��3��p�������������任��z�������ȡ�������ǹ⴫�������������෴
pvec{2} = FresnelP.*CosTheta.*SinPhi;
pvec{3} = -FresnelP.*SinTheta;
% pvec{3} = FresnelP.*SinTheta; % add by fs
svec{1} = -FresnelS.*SinPhi;
svec{2} = FresnelS.*CosPhi;
svec{3} = 0;

%  �Ⲩ��ʸ������p����s��������������p����s��Ų��pupilƽ��������᷽�򣬣������Ǿ��������
% �൱�����·ֽ�pupil��õ�ĹⳡΪx�����y����������������ʵ������һ��ʸ������ʾ����֪��Ϊʲô�������������ϳɵ�
PolarizationVector = cell(2,3);  
for jtel = 1:3
  PolarizationVector{1,jtel} = CosPhi.*pvec{jtel}-SinPhi.*svec{jtel};   % x����ƫ�����ֻ��Ҫ������һ�д���?
  PolarizationVector{2,jtel} = SinPhi.*pvec{jtel}+CosPhi.*svec{jtel};   % y����ƫ��
end

wavevector = cell(1,3); % ��ʸ�����о��������������λ�ô�������λ�仯
wavevector{1} = (2*pi*NA/lambda)*XPupil;  % NA/lambdaӦ���ǽ�ֹ�ռ�Ƶ��
wavevector{2} = (2*pi*NA/lambda)*YPupil;
wavevector{3} = (2*pi*refimm/lambda)*CosThetaImm;  % ���ﾵ�Ľ�����
wavevectorzmed = (2*pi*refmed/lambda)*CosThetaMed; % ����Ʒ������

%% calculation aberration function
Waberration = zeros(size(XPupil));
orders = parameters.aberrations(:,1:2);
zernikecoefs = squeeze(parameters.aberrations(:,3));
normfac = sqrt(2*(orders(:,1)+1)./ ( 1+double(orders(:,2)==0)) );  
zernikecoefs = normfac.*zernikecoefs; % zernikeϵ��Ϊʲô��Ҫ���ƣ�
allzernikes = get_zernikefunctions(orders,XPupil,YPupil);


for j = 1:numel(zernikecoefs)
  Waberration = Waberration+zernikecoefs(j)*squeeze(allzernikes(j,:,:));  
end
% % add by fs, for 4f, pupil is not just after the objective, is in the 4f, so the
% % coordinate should transpose  
PhaseFactor = exp(2*pi*1i*Waberration/lambda);  %zernike����������λ����


PupilMatrix = cell(2,3);  %����zernike�����pupil function
for itel = 1:2
  for jtel = 1:3
    PupilMatrix{itel,jtel} = Amplitude.*PhaseFactor.*PolarizationVector{itel,jtel};
  end
end

%% pupil and image size (in diffraction units)
% PupilSize = NA/lambda;
ImageSizex = xrange*NA/lambda;
ImageSizey = yrange*NA/lambda;

% calculate auxiliary vectors for chirpz
[Ax,Bx,Dx] = prechirpz(PupilSize,ImageSizex,Npupil,sizeX);
[Ay,By,Dy] = prechirpz(PupilSize,ImageSizey,Npupil,sizeY);


FieldMatrix = cell(2,3,sizeZ);
for jz = 1:sizeZ
    % xyz induced phase contribution
    if zemit(jz)+zemit0>=0  %����0˵������λ���ڲ�Ƭ�Ϸ�
        Wxyz= (-1*xemit(jz))*wavevector{1} + (-1*yemit(jz))*wavevector{2}+ (zemit(jz)+zemit0)*wavevectorzmed;
        %   zemitrun = objStage(jz);
        PositionPhaseMask = exp( 1i*( Wxyz+ (objStage(jz)+objStage0) * wavevector{3} ) );
    else
        disp("warning! the emitter's position may have not physical meaning") % add by fs
        
        Wxyz= (-1*xemit(jz))*wavevector{1}+(-1*yemit(jz))*wavevector{2};
        %   zemitrun = objStage(jz);
        PositionPhaseMask = exp(1i*(Wxyz+ (objStage(jz)+objStage0+zemit(jz)+zemit0) * wavevector{3}));
    end
  
    for itel = 1:2
        for jtel = 1:3

          % pupil functions and FT to matrix elements
          PupilFunction =PositionPhaseMask.*PupilMatrix{itel,jtel};  %����zernike����Լ�xyz��λ���Ӻ��pupil function
          %PupilFunction = PositionPhaseMask.*phase_DH;
          %IntermediateImage = transpose(cztfunc(pupil,Ay,By,Dy));  %����y������Ҷ�任
          IntermediateImage = transpose(cztfunc(PupilFunction,Ay,By,Dy));  %����y������Ҷ�任
          FieldMatrix{itel,jtel,jz} = transpose(cztfunc(IntermediateImage,Ax,Bx,Dx)); %����x������Ҷ�任
        end
    end
end

%% calculates the free dipole PSF given the field matrix.

%  each of the three x-,y- and z-orientated dipoles in the sample contributes one PSF 
% for the x and one for the y polarization on the camera
PSFs = zeros(sizeX,sizeY,sizeZ);
for jz = 1:sizeZ
    for jtel = 1:3
        for itel = 1:2
            PSFs(:,:,jz) = PSFs(:,:,jz) + (1/3) * abs(FieldMatrix{itel,jtel,jz}) .^2;
        end
    end
end
%% fixed dipole, add by fs,�Ȱ�x��y������ɼ���������ƽ����
% FixedPSF = zeros(sizeX,sizeY,sizeZ);
% 
% pola = 45/180*pi
% azim = 0/180*pi
% dipor(1) = sin(pola)*cos(azim);
% dipor(2) = sin(pola)*sin(azim);
% dipor(3) = cos(pola);         
% 
% % calculation of fixed PSF 
% for jz =1:sizeZ
%     Ex = dipor(1)*FieldMatrix{1,1,jz}+dipor(2)*FieldMatrix{1,2,jz}+dipor(3)*FieldMatrix{1,3,jz};
%     Ey = dipor(1)*FieldMatrix{2,1,jz}+dipor(2)*FieldMatrix{2,2,jz}+dipor(3)*FieldMatrix{2,3,jz};
%     FixedPSF(:,:,jz) = abs(Ex).^2+abs(Ey).^2;
%     FixedPSF(:,:,jz) = FixedPSF(:,:,jz)/sum(FixedPSF(:,:,jz),'all');
% end
% % imageslicer(FixedPSF)
% figure;
% for i_dp=1:sizeZ
%     subplot(5,5,i_dp);
%     surf(FixedPSF(:,:,i_dp),'edgecolor','none');view(2);
%     axis square;xlabel(num2str(zemit(i_dp)))
% end
%% calculate intensity normalization function using the PSFs at focus
% position without any aberration. It might not work when sizex and sizeY
% are very small
FieldMatrix = cell(2,3);
for itel = 1:2
  for jtel = 1:3
    PupilFunction = Amplitude.*PolarizationVector{itel,jtel};  %û��zernike����Լ�xyz��λ���ӵ�pupil function
%     PupilFunction = Amplitude.*phase_DH;
    IntermediateImage = transpose(cztfunc(PupilFunction,Ay,By,Dy));
    FieldMatrix{itel,jtel} = transpose(cztfunc(IntermediateImage,Ax,Bx,Dx));
  end
end

intFocus = zeros(sizeX,sizeY);
for jtel = 1:3
    for itel = 1:2
        intFocus = intFocus + (1/3)*abs(FieldMatrix{itel,jtel}).^2;
    end
end

normIntensity = sum(intFocus(:));

PSFs = PSFs./normIntensity;

%% blur the vector psf
% I_sigmax= hh5(22);
% I_sigmay= hh5(23);
% [x1,y1]=meshgrid( - 2 : 2 );
% gauss_psf=exp(-x1.^2./2./I_sigmax^2).*exp(-y1.^2./2./I_sigmay^2);
% gauss_psf = gauss_psf/sum(gauss_psf,'all');
% % figure;mesh(gauss_psf);title('psf gauss calculated by Isigma');
% PSFs = convn(PSFs,gauss_psf,'same');





% sigma = 1.0;
% if sigma ~=0
%     h = fspecial('gaussian',5,sigma);
%     PSFs = convn(PSFs,h,'same');
% end
% 
% hx = fspecial('gaussian',5,0.6);
% hy = fspecial('gaussian',5,0.5);
% hxs = sum(hx,1);
% hys = sum(hy,1);
% 
% hgauss = hys'*hxs;
% hgauss = hgauss/(sum(hgauss(:)));
% 
% PSFs = convn(PSFs,hgauss,'same');

%% Waberration to show
Waberration = Waberration.*ApertureMask;
pupil = Waberration;




