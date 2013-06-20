function [data] = plotDevice()
index = 0;
data=[];
landmarks=[];
clusters = [];
cdf_clusters={};
%close all;
th = 3;
% for confidence = [2 3 4 5]
%     index = index +1;
%     [a b c d e f] = changeDevice(th,confidence);
%     
%     landmarks = [landmarks;mean(b) mean(c)];
%     %clusters = [clusters;mean(d) mean(e)];
%     %cdf_clusters{index} = [d;e];
%     
%     
%     
% %     figure;
% %     hold on;
% %     cdfplot(avg(3:end));
% %     cdfplot(avg_1(3:end));
%     
% end
% figure;
% bar([2 3 4 5],landmarks);

confidence = 3;
index = 0;
for place = {'CS_dep','TechMarket'}
    index = index +1;
    
    [a b c d e f] = changeDevice(th,confidence,place{1});
    z1=mean(b);
    z2=mean(c);
    common = mean(f);
    data(index,1) = common;
    data(index,2) = z1-common;
    data(index,3) = z2-common;
end



% for i=1:3
%     figure;
%     hold on;
%     for j=1:2
%         cdfplot(cdf_clusters{i}(j,:));
%     end
% end

figure;
bar([1 1.2],data,0.1,'stack')
legend('Stable','S3','S2');
xticklabel_rotate([1 1.2],45,{'Indoors','Outdoors'},'interpreter','none')
%cdfplot(avg_1(3:end));
end