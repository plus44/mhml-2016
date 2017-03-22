clear;
close all;

%allData = [dataset1;dataset2;dataset3;dataset4;dataset5;dataset6;dataset7;dataset8;dataset9;dataset10;dataset11;dataset12;dataset13;dataset14;dataset15;dataset16;dataset17;dataset18;dataset19;dataset20;dataset21;dataset22;dataset23;dataset24;dataset25;dataset26];
%tableData = table(allData(:,1),allData(:,2),allData(:,3),allData(:,4),allData(:,5),allData(:,6),allData(:,7),allData(:,8),allData(:,9),allData(:,10),allData(:,11),allData(:,12),allData(:,13),allData(:,14),allData(:,15),allData(:,16),allData(:,17),allData(:,18),'VariableNames', {'ax','ay','az', 'mean_Acc', 'max_Acc', 'min_Acc','p_p_Acc', 'var_Acc', 'N_high', 'N_low', 'gx', 'gy', 'gz','yaw','pitch','roll', 'thetaZ', 'response'});
%[tableData, allData] = loadData;
loadData
n =size(allData,1);
K = 1/n; %/ test/train ratio

ids = randperm(n);
testData = allData(ids(1:int32(n*K)),:);
trainData = allData(ids(int32(n*K)+1:n),:);
trainData=allData(ids,:);
%trainData = allData(1:int32(0.8*n), :);
trainSize = size(trainData, 1);
%testData = allData(int32(0.8*n+1):end, :);

base = ones(trainSize, 1);
az =trainData(:,3);
gx =trainData(:,11);
mag =trainData(:,4);
max =trainData(:,5);
min =trainData(:,6);
p2p =trainData(:,7);
var =trainData(:,8);
%nh =trainData(:,9);
nl =trainData(:,10);

%[w_opt, e_min] = fallPerceptron(trainData(:,1:end-1), trainData(:,end), trainSize, 10000);
[w, e] = fallPerceptron([base, az, gx, max, min, p2p, var, nl], trainData(:,end), trainSize, 10000);
e
ypred = sign([base, az, gx, max, min, p2p, var, nl]*w);
y = trainData(:,end); 
testError = trainData(:,end) - ypred;

TP = sum((y==1) & (ypred==1));
FP = sum((y==-1) & (ypred==1));
TN = sum((y==-1) & (ypred==-1));
FN = sum((y==1) & (ypred==-1));
Accurary = (TP + TN ) / (TP + FP + TN + FN);
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
testData;