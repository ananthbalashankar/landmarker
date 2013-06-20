function [dist] = getClusterDistance(data,idx,centroids)
dist = [];
for i=1:size(centroids,1)
	dist(i) = 0;
	count(i) = 0;
end
for i=1:size(centroids,1)
	for j=1:length(idx)
		if(idx(j) == i)
			dist(i) = dist(i) + norm(data(j,:)-centroids(i,:));
			count(i) = count(i) + 1;
		end
	end
end
for i=1:size(centroids,1)
	dist(i) = dist(i)/count(i);
end
end
