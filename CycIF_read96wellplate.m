%% Import CycIF data from text files.
% 2017/06/27  Jerry Lin
%
% Script for importing data from the following text file:
%
%   Results-Nuc-[Row][Col][Filed].txt    Nuclear data
%   Results-Cyto-[Row][Col][Filed].txt   Cytosol data
%   
% 02: including X, Y, & Field in the output 

%% Initialize variables.
rows = {'A','B','C','D','E','F','G','H'};
cols = {'01','02','03','04','05','06','07','08','09','10','11','12'};

mypath = uigetdir('Z:\sorger\data\Cytell\Connor\ProcessedCycIF\');

sitedata_nuc = cell(8,12,12);
welldata_nuc = cell(8,12);
wellsum_nuc = cell(8,12);

sitedata_Cyto = cell(8,12,12);
welldata_Cyto = cell(8,12);
wellsum_Cyto = cell(8,12);

start_r = input('Please input starting row (1-8):');
end_r = input('Please input ending row (1-8):');
start_c = input('Please input starting column (1-12):');
end_c = input('Please input ending column (1-12):');
start_f = input('Please input starting field (1-12):');
end_f = input('Please input ending field (1-12):');

if end_f>10
    flds = {'fld01','fld02','fld03','fld04','fld05','fld06','fld07','fld08','fld09','fld10','fld11','fld12'};
else
    flds = {'fld1','fld2','fld3','fld4','fld5','fld6','fld7','fld8','fld9','fld10','fld11','fld12'};
end

%% Read nuclear data
for r=start_r:end_r;
    for c=start_c:end_c;
        for f=start_f:end_f;
            site = strcat(rows(r),cols(c),flds(f));
            well = strcat(rows(r),cols(c));
            filename = strjoin(strcat(mypath,'\Results-Nuc-',site,'.txt'));
            

disp(strcat('Processing:',filename));

if exist(filename,'file')
    
%%filename = 'C:\CycIF\Results-B02fld01.txt';
delimiter = '\t';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%s)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: double (%f)
%	column18: double (%f)
%   column19: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%f%f%f%f%f%f%f%f%f%f%f%s%s%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
temp = table(dataArray{1:end-1}, 'VariableNames', {'VarName1','Label','Area','Mean','StdDev','Min','Max','X','Y','Perim','Circ','IntDen','Median','VarName14','RawIntDen','Slice','AR','Round','Solidity'});
if(f<10)
    temp.Channel = cellfun(@(x) x(20:length(x)),temp.Label,'UniformOutput',false);
else
    temp.Channel = cellfun(@(x) x(21:length(x)),temp.Label,'UniformOutput',false);
end
temp.Well = repmat(well,length(temp.Label),1);
temp.Field = repmat(f,length(temp.Label),1);


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
sitedata_nuc{r,c,f}=temp;
if(istable(welldata_nuc{r,c}))
    welldata_nuc{r,c} = [welldata_nuc{r,c};temp];
else
    welldata_nuc{r,c} = temp;
end

end

end
        %% processing well summary
        temp1 = varfun(@mean,welldata_nuc{r,c},'GroupingVariables','Channel','InputVariables','Mean');
        channels = temp1.Channel;
        sizes = temp1.GroupCount;
        
        allchs = zeros(sizes(1),length(channels));
        
        for i=1:length(channels);
            allchs(:,i) = welldata_nuc{r,c}.Mean(strcmp(welldata_nuc{r,c}.Channel,channels{i}));
        end
        channels(i+1) = {'Area'};
        allchs(:,i+1) = welldata_nuc{r,c}.Area(strcmp(welldata_nuc{r,c}.Channel,channels{1}));
        DAPI = welldata_nuc{r,c}.Mean(strcmp(welldata_nuc{r,c}.Channel,'DAPI-0001'));
        AREA = allchs(:,i+1);
        channels(i+2) = {'IntDAPI'};
        allchs(:,i+2) = DAPI .* AREA;

        channels(i+3) = {'X'};
        allchs(:,i+3) = welldata_nuc{r,c}.X(strcmp(welldata_nuc{r,c}.Channel,channels{1}));
        channels(i+4) = {'Y'};
        allchs(:,i+4) = welldata_nuc{r,c}.Y(strcmp(welldata_nuc{r,c}.Channel,channels{1}));
        channels(i+5) = {'Field'};
        allchs(:,i+5) = welldata_nuc{r,c}.Field(strcmp(welldata_nuc{r,c}.Channel,channels{1}));

        wellsum_nuc{r,c}=allchs;
        %tableTemp = array2table(allchs,'VariableNames',channels);
        clearvars allchs DAPI AREA temp1 sizes well temp site;
     end
end

%% Read cytosol data
for r=start_r:end_r;
    for c=start_c:end_c;
        for f=start_f:end_f;
            site = strcat(rows(r),cols(c),flds(f));
            well = strcat(rows(r),cols(c));
            filename = strjoin(strcat(mypath,'\Results-Cyto-',site,'.txt'));
            

disp(strcat('Processing:',filename));
if exist(filename,'file')
%%filename = 'C:\CycIF\Results-B02fld01.txt';
delimiter = '\t';
startRow = 2;

%% Format string for each line of text:
%   column1: double (%f)
%	column2: text (%s)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: double (%f)
%	column18: double (%f)
%   column19: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%s%f%f%f%f%f%f%f%f%f%f%f%s%s%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
temp = table(dataArray{1:end-1}, 'VariableNames', {'VarName1','Label','Area','Mean','StdDev','Min','Max','X','Y','Perim','Circ','IntDen','Median','VarName14','RawIntDen','Slice','AR','Round','Solidity'});
if(f<10)
    temp.Channel = cellfun(@(x) x(20:length(x)),temp.Label,'UniformOutput',false);
else
    temp.Channel = cellfun(@(x) x(21:length(x)),temp.Label,'UniformOutput',false);
end
temp.Well = repmat(well,length(temp.Label),1);
temp.Field = repmat(f,length(temp.Label),1);

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
sitedata_Cyto{r,c,f}=temp;
if(istable(welldata_Cyto{r,c}))
    welldata_Cyto{r,c} = [welldata_Cyto{r,c};temp];
else
    welldata_Cyto{r,c} = temp;
end

end

end
        %% processing well summary
        temp1 = varfun(@mean,welldata_Cyto{r,c},'GroupingVariables','Channel','InputVariables','Mean');
        channels = temp1.Channel;
        sizes = temp1.GroupCount;
        
        allchs = zeros(sizes(1),length(channels));
        
        for i=1:length(channels);
            allchs(:,i) = welldata_Cyto{r,c}.Mean(strcmp(welldata_Cyto{r,c}.Channel,channels{i}));
        end
        channels(i+1) = {'Area'};
        allchs(:,i+1) = welldata_Cyto{r,c}.Area(strcmp(welldata_Cyto{r,c}.Channel,channels{1}));
        DAPI = welldata_Cyto{r,c}.Mean(strcmp(welldata_Cyto{r,c}.Channel,'DAPI-0001'));
        AREA = allchs(:,i+1);
        channels(i+2) = {'IntDAPI'};
        allchs(:,i+2) = DAPI .* AREA;

        channels(i+3) = {'X'};
        allchs(:,i+3) = welldata_nuc{r,c}.X(strcmp(welldata_nuc{r,c}.Channel,channels{1}));
        channels(i+4) = {'Y'};
        allchs(:,i+4) = welldata_nuc{r,c}.Y(strcmp(welldata_nuc{r,c}.Channel,channels{1}));
        channels(i+5) = {'Field'};
        allchs(:,i+5) = welldata_nuc{r,c}.Field(strcmp(welldata_nuc{r,c}.Channel,channels{1}));

        wellsum_Cyto{r,c}=allchs;
        %tableTemp = array2table(allchs,'VariableNames',channels);
        clearvars allchs DAPI AREA temp1 sizes well temp site;
     end
end
