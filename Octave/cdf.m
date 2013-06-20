function [data] = cdf()
index = 0;
data=[];
clusters = {};
cdf_clusters={};
close all;
for th = [1 3 7]
    index = index +1;
    [a b c d e f] = changeTime(th);
    avg = [1:20]*0;
    for i=1:length(b)
        x = b{i};
        for j=1:length(x)
        avg(j) = avg(j) + x(j);
        end
    end
    avg = avg/length(b);
    avg_1 = [1:20]*0;
    for i=1:length(c)
        x = c{i};
        for j=1:length(x)
        avg_1(j) = avg_1(j) + x(j);
        end
    end
    avg_1 = avg_1 /length(c);
    
    clusters{index} = [mean(d) mean(e)];
    cdf_clusters{index} = [d;e];
    
    figure;
    temp = [avg;avg_1]';
    temp = temp(3:8,:);
    bar([3:8],temp);
    
    figure;
    hold on;
    cdfplot(avg(3:end));
    cdfplot(avg_1(3:end));
    
   
    z=sum(avg(3:end));
    c=mean(f);
    x=sum(avg_1(3:end));
    data(index,1) = c;
    data(index,2) = z-c;
    data(index,3) = x-c;
end

figure;
bar([0.1 0.3 0.7],[clusters{1};clusters{2};clusters{3}]);

for i=1:3
    figure;
    hold on;
    for j=1:2
        cdfplot(cdf_clusters{i}(j,:));
    end
end

figure;
bar(data,'stack')
%cdfplot(avg_1(3:end));
end