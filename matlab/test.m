clear;
close all;

nFiles = 10;

    in = load('C:\Users\perko\OneDrive - Imperial College London\MHML\MobiFall_Dataset_v1.0\pat1\FALLS\BSC\BSC_acc_1_1.txt');
    in = in(100:300,:);
    
    
    sRate = 0.01;
    wSize = 0.5;
    crossOver = 0.5;
    
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
        
        j = j+nSize*(1-crossOver);
        t=t+1;
    end
   
        response = ones(t-1,1);
   
    features( :, :) = [f1 f2 f3 f4 f5 response];
    




figure
hold on
plot(sqrt(in(:,4).^2+in(:,2).^2+in(:,3).^2))
%plot(f1);
%plot(f2);
% plot(f3);
% plot(f4);
% plot(f5);
