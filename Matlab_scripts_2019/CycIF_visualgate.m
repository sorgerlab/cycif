function [postivecells,gate]=CycIF_visualgate(datatable,channel,mgate)
%% For visualization & gating CycIF datatable, require CycIF_tumorview
%  Jerry Lin 2018/11/27
%            2019/03/18 Bug fixed
%
%  datatable : CycIF table format (need Xt & Yt for coordinate)
%  channel   : channel name (string)
%  mgate     : manual gate input (log scale)

%% Initialization 
temp1 = log(datatable{:,channel});      %numerial data for gating

figure('units','normalized','outerposition',[0.5 0 0.5 1]);
%set(gcf,'Position',[962 42 958 954]);

%% Plot 1 (gating)
subplot(2,10,1:4);

[pluscells, gate, ~,lowb,highb]=findgate3(temp1,1,0.05,mgate);
title (strcat({'Gating '},channel));
newchannel = strcat(channel,'p');
datatable{:,newchannel}=pluscells;

%% Plot 2 (Density plot)
ax(1)=subplot(2,10,5.5:10);
CycIF_tumorview(datatable,channel,1);
caxis([lowb highb+1.5]);
title('Digital Representation (log)');
xl = xlim;
yl = ylim;
% set(gca,'xtick',0:2*416:xl(2));
% set(gca,'ytick',0:2*351:yl(2));
%colormap(gca,jet);
% grid on;
%colorbar('southoutside');


%% Plot 3 (Postivie/Negative view)
ax(2)=subplot(2,10,11:14.5);
CycIF_tumorview(datatable,newchannel,2);

title('Positive cells');
%set(gca,'xtick',0:2*416:xl(2));
%set(gca,'ytick',0:2*351:yl(2));
xlim(xl);
ylim(yl);
%grid on;
lgd = legend;
lgd.Orientation = 'vertical';
lgd.Location = 'southeast';

%% Plot 4 (positive density)
ax(3)=subplot(2,10,15.5:20);
CycIF_tumorview(datatable,newchannel,3);
title('Positive density');
xlim(xl);
ylim(yl);
% set(gca,'xtick',0:2*416:xl(2));
% set(gca,'ytick',0:2*351:yl(2));
% grid on;
colormap(gca,redbluecmap);
colorbar;
legend off;

linkaxes(ax,'xy');
return;



