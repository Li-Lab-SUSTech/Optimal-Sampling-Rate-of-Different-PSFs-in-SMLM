function [a] = barplot()
clear global variable
%% plot 3D bars RMSE vs Z vs PS
final_record = load([pwd,filesep,'optimal_sampling_rate\data\crlb_z_astigmatic.mat']);
final_record=final_record.crlb_z_astigmatic;
final_record=final_record(:,1:8:265);
for i = 1:9
    temp(i,:) = final_record(10-i,:);
end
final_record = temp;
figure('Color',[1 1 1]);
% plot3(record.z,record.binnedPS,record.rmse_rowz_colps)
bar_tmp = bar3(final_record');
axis square
ylabel('pixel size')
xlabel('Photons')
zlabel('CRLB_{z}')
set(gca, 'Box', 'off', ... % �߿�
'LineWidth', 1, 'GridLineStyle', '-',... % �������߿�
'XGrid', 'off', 'YGrid', 'off','ZGrid', 'on', ... % ����
'TickDir', 'out', 'TickLength', [.015 .015], ... % �̶�
'XMinorTick', 'off', 'YMinorTick', 'off', 'ZMinorTick', 'off',... % С�̶�
'XColor', [.1 .1 .1], 'YColor', [.1 .1 .1], 'ZColor', [.1 .1 .1],... % ��������ɫ
'Xtick',1:1:size(final_record,1),...
'YTick',1:6:size(final_record,2),...
'Xticklabel',[18000,16000,14000,12000,10000,8000,6000,4000,2000],... % X������̶ȱ�ǩ
'Yticklabel',[24,64,120,168,216,264,296],...
'fontname','Arial Rounded MT Bold','fontsize',15)
colormap("jet")
view(210,45)
for k = 1:length(bar_tmp)
    zdata = bar_tmp(k).ZData;
    bar_tmp(k).CData = zdata;
    bar_tmp(k).FaceColor = 'interp';
end
a=1;
end