clear;
close all;

sRate = 0.03;
wSize = 0.5;
crossOver = 0.5;

nFiles = 26;
nNoFall = 10;
for i=1:nFiles
    switch i
        case 1
            in= load('CyFall/pat1/Mount&Start.txt');
        case 2
            in= load('CyFall/pat1/RideStraight.txt');
        case 3
            in= load('CyFall/pat1/Eights.txt');
        case 4
            in= load('CyFall/pat1/Stop&Dismount.txt');
        case 5
            in= load('CyFall/pat1/Pavement.txt');
        case 6
            in= load('CyFall/pat2/Mount&Start.txt');
        case 7
            in= load('CyFall/pat2/RideStraight.txt');
        case 8
            in= load('CyFall/pat2/Eights.txt');
        case 9
            in= load('CyFall/pat2/Stop&Dismount.txt');
        case 10
            in= load('CyFall/pat2/Pavement.txt');
        case 11
            in= load('CyFall/Falls/Fall1.txt');
        case 12
            in= load('CyFall/Falls/Fall2.txt');
        case 13
            in= load('CyFall/Falls/Fall3.txt');
        case 14
            in= load('CyFall/Falls/Fall4.txt');
        case 15
            in= load('CyFall/Falls/Fall5.txt');
        case 16
            in= load('CyFall/Falls/Fall6.txt');
        case 17
            in= load('CyFall/Falls/Fall7.txt');
        case 18
            in= load('CyFall/Falls/Fall8.txt');
        case 19
            in= load('CyFall/Falls/Fall9.txt');
        case 20
            in= load('CyFall/Falls/Fall10.txt');
        case 21
            in= load('CyFall/Falls/Fall11.txt');
        case 22
            in= load('CyFall/Falls/Fall12.txt');
        case 23
            in= load('CyFall/Falls/Fall13.txt');
        case 24
            in= load('CyFall/Falls/Fall14.txt');
        case 25
            in= load('CyFall/Falls/Fall15.txt');
        case 26
            in= load('CyFall/Falls/Fall16.txt');
            
            %         case 11
            %             in = load('C:\Users\perko\OneDrive - Imperial College London\MHML\MobiFall_Dataset_v1.0\pat1\FALLS\BSC\BSC_acc_1_1.txt');
            %             in = in(100:300,:);%Get only fall data
            %             sRate = 0.1;
    end
    
    
    
    nSize = int32(wSize/sRate);
    j=1;
    t=1;
    while (j+nSize < length(in))
        a = in(j:j+nSize, 2:4);
        f1(t,:) = mean(a);
        magAcc = sqrt(a(:,1).^2+a(:,2).^2+a(:,3).^2);
        f2(t,:) = mean(magAcc);
        f3(t,:) = max(magAcc);
        f4(t,:) = min(magAcc);
        f5(t,:) = f3(t,:) - f4(t,:);
        b = in(j:j+nSize, 5:10);
        f6(t,:) = mean(b);

        j = j+nSize*(1-crossOver);
        t=t+1;
    end
    f7  = real(acos (f2/9810));
    if i > nNoFall
        response = true(t-1,1);
    else
        response = false(t-1,1);
    end
    dataset = [f1 f2 f3 f4 f5 f6 f7 response];
    
    % features(i, :, :) = [f1 f2 f3 f4 f5 response];
    switch i
        case 1
            dataset1 = dataset;
        case 2
            dataset2 = dataset;
        case 3
            dataset3 = dataset;
        case 4
            dataset4 = dataset;
        case 5
            dataset5 = dataset;
        case 6
            dataset6 = dataset;
        case 7
            dataset7 = dataset;
        case 8
            dataset8 = dataset;
        case 9
            dataset9 = dataset;
        case 10
            dataset10 = dataset;
        case 11
            dataset11 = dataset;
        case 12
            dataset12 = dataset;
        case 13
            dataset13 = dataset;
        case 14
            dataset14 = dataset;
        case 15
            dataset15 = dataset;
        case 16
            dataset16 = dataset;
        case 16
            dataset16 = dataset;
        case 17
            dataset17 = dataset;
        case 18
            dataset18 = dataset;
        case 19
            dataset19 = dataset;
        case 20
            dataset20 = dataset;
        case 21
            dataset21 = dataset;
        case 22
            dataset22 = dataset;
        case 23
            dataset23 = dataset;
        case 24
            dataset24 = dataset;
        case 25
            dataset25 = dataset;
        case 26
            dataset26 = dataset;
    end
            
    clearvars f1 f2 f3 f4 f5 f6 f7 response
end

allData = [dataset1;dataset2;dataset3;dataset4;dataset5;dataset6;dataset7;dataset8;dataset9;dataset10;dataset11;dataset12;dataset13;dataset14;dataset15;dataset16;dataset17;dataset18;dataset19;dataset20;dataset21;dataset22;dataset23;dataset24;dataset25;dataset26];
%table = table(allData);
tableData = table(allData(:,1),allData(:,2),allData(:,3),allData(:,4),allData(:,5),allData(:,6),allData(:,7),allData(:,8),allData(:,9),allData(:,10),allData(:,11),allData(:,12),allData(:,13),allData(:,14),allData(:,15),allData(:,16),allData(:,17),allData(:,18),'VariableNames', {'Ax','Ay','Az', 'mean(|A|)', 'max(|A|)', 'min(|A|)','p_p(|A|)', 'gx', 'gy', 'gz','y','p','r', 'thetaZ', 'response'});
%[mode, accuracy] = trainClassifier(allData);

% for i=1:nFiles
%     switch i
%         case 1
%             dataset1 = squeeze(features(i,:,:));
%         case 2
%             dataset2 = squeeze(features(i,:,:));
%         case 3
%             dataset3 = squeeze(features(i,:,:));
%         case 4
%             dataset4 = squeeze(features(i,:,:));
%         case 5
%             dataset5 = squeeze(features(i,:,:));
%         case 6
%             dataset6 = squeeze(features(i,:,:));
%         case 7
%             dataset7 = squeeze(features(i,:,:));
%         case 8
%             dataset8 = squeeze(features(i,:,:));
%         case 9
%             dataset9 = squeeze(features(i,:,:));
%         case 10
%             dataset10 = squeeze(features(i,:,:));
%         case 11
%             dataset11 = squeeze(features(i,:,:));
%     end
% end


% figure
% hold on
% plot(f1);
% plot(f2);
% plot(f3);
% plot(f4);
% plot(f5);
