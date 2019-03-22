function [postivecells,gate]=CycIF_visualgate_Shu(datatable,channel,FDR,K)
%% For visualization & gating CycIF datatable, require CycIF_tumorview & findcutoff (Shu)
%  Jerry Lin 2017/12/01
%
%  datatable : CycIF table format (need Xt & Yt for coordinate)
%  channel   : channel name (string)
%  FDR       : FDR for inputs in findcutoff (Shu);

%% Initialization 

temp1 = log(datatable{:,channel});      %numerial data for gating

figure;
%set(gcf,'Position',[962 42 958 954]);

%% Plot 1 (gating)
subplot(2,10,1:4);

[~, ~, ~,lowb,highb]=findgate3(temp1,0,0.05,0);
[gate, pluscells]=CycIF_findcutoff(temp1,2,K,FDR);
title (strcat({'GMM Gating '},channel));
newchannel = strcat(channel,'p');
datatable{:,newchannel}=pluscells;
xlim([lowb-0.5 gate+2]);

%% Plot 2 (Density plot)
ha(1)=subplot(2,10,5.5:10);
CycIF_tumorview(datatable,channel,1);
caxis([lowb highb+1.5]);
title('Digital Representation (log)');
xl = xlim;
yl = ylim;
disp(xl);
disp(max(datatable.Xt));
%set(gca,'xtick',0:2*416:xl(2));
%set(gca,'ytick',0:2*351:yl(2));
colormap(gca,jet);
%grid on;

%% Plot 3 (Postivie/Negative view)
ha(2)=subplot(2,10,11:14.5);
CycIF_tumorview(datatable,newchannel,2);
title('Positive cells');
set(gca,'xtick',0:2*416:xl(2));
set(gca,'ytick',0:2*351:yl(2));
xlim(xl);
ylim(yl);
grid on;
lgd = legend;
lgd.Orientation = 'vertical';
lgd.Location = 'southeast';

%% Plot 4 (positive density)
ha(3)=subplot(2,10,15.5:20);
CycIF_tumorview(datatable,newchannel,3);
title('Positive density');
xlim(xl);
ylim(yl);
%set(gca,'xtick',0:2*416:xl(2));
%set(gca,'ytick',0:2*351:yl(2));
%grid on;
colormap(gca,redbluecmap);
colorbar;
legend off;

linkaxes(ha,'xy');
return;



