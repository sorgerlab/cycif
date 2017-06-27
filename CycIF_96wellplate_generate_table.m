%% Convert plate CycIF data to table 
% 2017/06/27 Jerry Lin
%
% Need to run CycIF_readplate_xx first
% Need "labels" for column names

myName = input('Please input table name:','s');

rows = {'A','B','C','D','E','F','G','H'};
cols = {'01','02','03','04','05','06','07','08','09','10','11','12'};

start_r = input('Please input starting row (1-8):');
end_r = input('Please input ending row (1-8):');
start_c = input('Please input starting column (1-12):');
end_c = input('Please input ending column (1-12):');

flag1 = input('Do you want to output the csv file?(y/n)','s');

alldata = table;

if ~exist('labels','var')
    labels = channels;
    for i =1:length(channels);
        labels(i) = strrep(channels(i),'-','_');
    end
end

%% Access nuclear data (cell array)
for r=start_r:end_r;
    for c=start_c:end_c;
        temp1 = wellsum_nuc{r,c};
        table1 = array2table(temp1,'VariableNames',labels);
        table1.well = repmat({strcat(rows{r},cols{c})},length(temp1),1);
    
        if isempty(alldata);
           alldata = table1;
        else
           alldata = vertcat(alldata,table1);
        end
    end
end

eval(strcat(myName,'_nuc','=alldata;'));
if strcmp(flag1,'y') 
   outputname = strcat(myName,'_nuc.csv');
   writetable(alldata,outputname);
end

clear alldata;


alldata = table;

%% Access cytosol data (cell array)
for r=start_r:end_r;
    for c=start_c:end_c;
        temp1 = wellsum_Cyto{r,c};
        table1 = array2table(temp1,'VariableNames',labels);
        table1.well = repmat({strcat(rows{r},cols{c})},length(temp1),1);
    
        if isempty(alldata);
           alldata = table1;
        else
           alldata = vertcat(alldata,table1);
        end
    end
end

eval(strcat(myName,'_cyto','=alldata;'));
if strcmp(flag1,'y') 
   outputname = strcat(myName,'_cyto.csv');
   writetable(alldata,outputname);
end
clear alldata;

