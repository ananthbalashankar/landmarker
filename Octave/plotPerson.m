function [data avg avg_c] = plotPerson()
index = 0;
data=[];
clusters = {};
cdf_clusters={};
close all;
th = 3;
% landmarks = [];
% for confidence = [2 3 4 5]
%     index = index +1;
%     [a b c d] = changePerson(th,confidence);
%     
%     landmarks = [landmarks; mean(a')];
% %     avg = [];
% %     avg_c = [];
% %   for i=1:4
% %       avg_c(i) = 0;
% %       for j=1:20
% %           avg(i,j)=0;
% %       end
% %   end
% %     for i=1:4
% %         for j=1:8
% %             x = a{i,j};
% %             avg_c(i) = avg_c(i) + b(i,j); 
% %             for k=1:length(x)
% %             avg(i,k) = avg(i,k) + x(k);
% %             end
% %         end
% %     end
% %     avg = avg/8;
% %     avg_c = avg_c /8;
% %     
% %     clusters{index} = avg_c;
% %     cdf_clusters{index} = b;
% %     
% %     figure;
% %     temp = avg';
% %     temp = temp(3:8,:);
% %     bar([3:8],temp);
% %     
% %     figure;
% %     hold on;
% %     cdfplot(avg(1,3:end));
% %     cdfplot(avg(2,3:end));
% %     cdfplot(avg(3,3:end));
% %     cdfplot(avg(4,3:end));
%     
% end

% figure;
% bar([2 3 4 5],landmarks);
% bar([0.1 0.3 0.7],[clusters{1};clusters{2};clusters{3}]);
% 
% for i=1:3
%     figure;
%     hold on;
%     for j=1:4
%         cdfplot(cdf_clusters{i}(j,:));
%     end
% end


confidence = 3;
index = 0;
for place = {'CS_dep','TechMarket'}
    index = index +1;
    [a b c d] = changePerson(th,confidence,place{1});
 z1 = mean(a(1,:));
    z2 = mean(a(2,:));
    z3 = mean(a(3,:));
    z4 = mean(a(4,:));
    common=mean(c);
    data(index,1) = common;
    data(index,2) = max(0,z1-common);
    data(index,3) = max(0,z2-common);
    data(index,4) = max(0,z3-common);
    data(index,5) = max(0,z4-common);
end

figure;
bar([1 2],data,'stack')
%cdfplot(avg_1(3:end));
end