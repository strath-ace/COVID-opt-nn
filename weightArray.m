function borderWeights=weightArray(weights,days)
% form weight arrays that have more than one country in them i.e., more
% than 1 dimension

% figuring out how many countires we have
[noCountries noCols]=size(weights);

% sending the first one to be weighted
borderWeight = weightChina(weights(1,:),days);

% and then the rest - each being a row
for ii=2:noCountries
    borderWeight = [borderWeight;weightChina(weights(ii,:),days)];
end

borderWeights=borderWeight;
    