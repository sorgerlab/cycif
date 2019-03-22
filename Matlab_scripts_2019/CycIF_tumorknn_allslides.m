%% CycIF_tumorknn_allslide
%  Jerry Lin 2018/12/02
%
%  Processing KNN model to all slides/samples
%  Resampling & generate allsample

%% Initialization

allsample = table;
samplesize = 5000;
sw1 = false;

S100gate = 9;


%% Processing all slides
for i =1:length(slideName)
        name1 = strcat('data',slideName{i});
        data1 = eval(name1);
        
        disp(strcat('Now processing:',name1));
        data1.S100p = data1.S100 > exp(S100gate);
        knn20 = fitcknn(data1{:,{'Xt','Yt'}},data1.S100p,'NumNeighbors',20);
        data1.S100knn = predict(knn20,data1{:,{'Xt','Yt'}});
        disp(strcat('S100knn cells =',num2str(mean(data1.S100knn))));
        
        eval(strcat(name1,'=data1;'));
        
        sample1 = datasample(data1,samplesize);
        
        if(sw1)
            filename = strcat('sample',slideName{i},'.csv');
            writetable(sample1,filename);
        end
        
        eval(strcat('sample',slideName{i},'=sample1;'));
        sample1.slidename = repmat(slideName(i),length(sample1.X),1);
        
        if(isempty(allsample))
            allsample = sample1;
        else
            allsample = vertcat(allsample,sample1);
        end      
end