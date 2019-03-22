function [pluscells,newdatatable,gate1,gate2]=CycIF_visualgate2D(datatable,ch1,ch2,mgate1,mgate2)
%% For visualization & gating CycIF datatable, require CycIF_tumorview
%  Jerry Lin 2018/03/08     New version
%  Jerry Lin 2018/03/19     New version (colormap)
%
%  datatable : CycIF table format (need Xt & Yt for coordinate)
%  ch1&ch2   : channel names (string)
%  mgate1&2  : manual gates input (log scale)
%  outsw     : output/figure switch (0 or 1);
%
%  Usage:  CycIF_visualgate2D(datatable,'Ch1','Ch2',0,0,1);
%

%% Initialization (define gates) 

if(length(datatable{:,1}>20000))
    datatable = datasample(datatable,20000);
end

temp1 = log(datatable{:,ch1}+5);      %numerial data for gating
temp2 = log(datatable{:,ch2}+5);

[pcells1, gate1, ~,lowb1,highb1]=findgate3(temp1,0,0.05,mgate1);
[pcells2, gate2, ~,lowb2,highb2]=findgate3(temp2,0,0.05,mgate2);


newCh1 = strcat(ch1,'p');
newCh2 = strcat(ch2,'p');
newCh1Ch2 = strcat(ch1,ch2,'p');

datatable{:,newCh1}=pcells1;
datatable{:,newCh2}=pcells2;
datatable{:,newCh1Ch2}=pcells1.*pcells2;

%% Output/figure section

figure('units','normalized','outerposition',[0.5 0 0.5 1]);


%% Plot 1 (gating)
subplot(2,10,1:4);

dscatter(temp1,temp2);
colormap(gca,jet);
hold on;

plot([gate1,gate1],[lowb2-0.5,highb2+1],'--k','LineWidth',2);
plot([lowb1-0.5,highb1+1],[gate2,gate2],'--k','LineWidth',2);


title(['Double positive=',num2str(mean(pcells1.*pcells2),'%0.3f')]);
xlabel([ch1,':',num2str(gate1,'%0.2f')]);
ylabel([ch2,':',num2str(gate2,'%0.2f')]);

xlim([lowb1-0.5,highb1+1]);
ylim([lowb2-0.5,highb2+1]);
hold off;

%% Plot 2 (Density plot for ch1)
ax1=subplot(2,10,11:15);

CycIF_tumorview(datatable,newCh1,2);
caxis([lowb1-0.5 highb1+1.5]);
title([ch1,'+cell=',num2str(mean(pcells1),'%0.3f')]);
xl = xlim;
yl = ylim;

%% Plot 3 (Density plot for ch2)
ax2=subplot(2,10,16:20);

CycIF_tumorview(datatable,newCh2,2);
caxis([lowb2-0.5 highb2+1.5]);
title([ch2,'+cell=',num2str(mean(pcells2),'%0.3f')]);
xlim(xl);
ylim(yl);

%% Plot 4 (Double positive density)
ax3=subplot(2,10,5:10);

CycIF_tumorview(datatable,newCh1Ch2,3);
title('Double Positive cells');
xlim(xl);
ylim(yl);
colormap(gca,redbluecmap);
colorbar;

linkaxes([ax1,ax2,ax3],'xy');


newdatatable = datatable;
pluscells = datatable{:,newCh1Ch2};

return;



