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
CosThetaMed = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2);  %fast focus field calculation公式1
CosThetaCov = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refcov^2);  %Ncov*SinThetaCov=Nmed*SinThetaMed
CosThetaImm = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refimm^2);   %同上+
%need check again, compared to original equation, FresnelPmedcov is
%multipiled by refmed  菲涅尔系数p波和s波的透射
FresnelPmedcov = 2*refmed*CosThetaMed./(refmed*CosThetaCov+refcov*CosThetaMed);
FresnelSmedcov = 2*refmed*CosThetaMed./(refmed*CosThetaMed+refcov*CosThetaCov);
FresnelPcovimm = 2*refcov*CosThetaCov./(refcov*CosThetaImm+refimm*CosThetaCov);
FresnelScovimm = 2*refcov*CosThetaCov./(refcov*CosThetaCov+refimm*CosThetaImm);
FresnelP = FresnelPmedcov.*FresnelPcovimm; %P波透射系数
FresnelS = FresnelSmedcov.*FresnelScovimm; %S波透射系数

% Apoidization for sine condition
% apoid = sqrt(CosThetaImm)./CosThetaMed;  %普通切趾就是让光瞳的透过率变化非阶跃式，而是缓变形式，消除次级环的影响，但这里是切趾的另一种含义
apoid = 1./sqrt(CosThetaImm);  % add by fs
% apoid = 1./sqrt(CosThetaMed);  % add by fs

% definition aperture
ApertureMask = double((XPupil.^2+YPupil.^2)<1.0);
Amplitude = ApertureMask.*apoid;  %调制了一下光瞳函数的振幅

% setting of vectorial functions    计算pupil上每个点的方位角（与光轴垂直的面）
Phi = atan2(YPupil,XPupil);
CosPhi = cos(Phi);
SinPhi = sin(Phi);
CosTheta = sqrt(1-(XPupil.^2+YPupil.^2)*NA^2/refmed^2); %算的是CosThetaMed，也就是与光轴夹角,为什么不是ThetaImm
SinTheta = sqrt(1-CosTheta.^2);

pvec{1} = FresnelP.*CosTheta.*CosPhi;  %文献中公式2和3，p波经过折射后方向变换，z方向分量取负可能是光传播方向与文献相反
pvec{2} = FresnelP.*CosTheta.*SinPhi;
pvec{3} = -FresnelP.*SinTheta;
% pvec{3} = FresnelP.*SinTheta; % add by fs
svec{1} = -FresnelS.*SinPhi;
svec{2} = FresnelS.*CosPhi;
svec{3} = 0;

%  光波电矢量包括p波和s波两个分量，把p波和s波挪回pupil平面的坐标轴方向，（本来是径向和切向）
% 相当于重新分解pupil面该点的光场为x方向和y方向两个分量，其实可以用一个矢量来表示？不知道为什么这里用了两个合成的
PolarizationVector = cell(2,3);  
for jtel = 1:3
  PolarizationVector{1,jtel} = CosPhi.*pvec{jtel}-SinPhi.*svec{jtel};   % x方向偏振好像只需要考虑这一行代码?
  PolarizationVector{2,jtel} = SinPhi.*pvec{jtel}+CosPhi.*svec{jtel};   % y方向偏振
end

wavevector = cell(1,3); % 波矢量，感觉是用来引入分子位置带来的相位变化
wavevector{1} = (2*pi*NA/lambda)*XPupil;  % NA/lambda应该是截止空间频率
wavevector{2} = (2*pi*NA/lambda)*YPupil;
wavevector{3} = (2*pi*refimm/lambda)*CosThetaImm;  % 在物镜的浸油中
wavevectorzmed = (2*pi*refmed/lambda)*CosThetaMed; % 在样品介质中

%% calculation aberration function
Waberration = zeros(size(XPupil));
orders = parameters.aberrations(:,1:2);
zernikecoefs = squeeze(parameters.aberrations(:,3));
normfac = sqrt(2*(orders(:,1)+1)./ ( 1+double(orders(:,2)==0)) );  
zernikecoefs = normfac.*zernikecoefs; % zernike系数为什么还要调制？
allzernikes = get_zernikefunctions(orders,XPupil,YPupil);


for j = 1:numel(zernikecoefs)
  Waberration = Waberration+zernikecoefs(j)*squeeze(allzernikes(j,:,:));  
end
% % add by fs, for 4f, pupil is not just after the objective, is in the 4f, so the
% % coordinate should transpose  
PhaseFactor = exp(2*pi*1i*Waberration/lambda);  %zernike像差引入的相位因子


PupilMatrix = cell(2,3);  %引入zernike像差后的pupil function
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
    if zemit(jz)+zemit0>=0  %大于0说明分子位置在玻片上方
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
          PupilFunction =PositionPhaseMask.*PupilMatrix{itel,jtel};  %引入zernike像差以及xyz相位因子后的pupil function
          %PupilFunction = PositionPhaseMask.*phase_DH;
          %IntermediateImage = transpose(cztfunc(pupil,Ay,By,Dy));  %关于y方向傅里叶变换
          IntermediateImage = transpose(cztfunc(PupilFunction,Ay,By,Dy));  %关于y方向傅里叶变换
          FieldMatrix{itel,jtel,jz} = transpose(cztfunc(IntermediateImage,Ax,Bx,Dx)); %关于x方向傅里叶变换
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
%% fixed dipole, add by fs,先把x和y分量相干加起来，再平方和
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
    PupilFunction = Amplitude.*PolarizationVector{itel,jtel};  %没有zernike像差以及xyz相位因子的pupil function
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




