function [countries, provinces, percentageDaily]=JHdata()
% loading in the smoothed daily cases array as percentages of the global
% number ignoring cases in Taiwan

% reading in data from John Hopkins University starting second row and 5th
% column, then we remove the last column as its redundant
%data_JHU=csvread('time_series_covid19_confirmed_global.csv',1,4);
%data_JHU=data_JHU(:,1:end-1);
data_JHU=readcell('time_series_covid19_confirmed_global.csv',"Range","2:267"); %readin data
globalCell=cell2mat(data_JHU(:,5:end)); % time series as an array
countries=string(data_JHU(:,2)); % countries as string array
provinces=string(data_JHU(:,1)); % provinces as string array

% making area string array to describe provinces with country attached
area=strings(length(countries),1);
for ii=1:length(provinces)
    if ismissing(provinces(ii))
        area(ii)=countries(ii);
    else
        area(ii)=join([provinces(ii) countries(ii)]);
    end
end

% dimensions
%noCountries=length(countries);
%nodays=length(seriesTaiwan);
[noCountries noDays]=size(globalCell);

% daily differences - smoothing daily differences - averaging over 3
dailyGlobal=diff(globalCell,1,2);
smoothDaily=zeros(noCountries,noDays-3); % initiating smoothed daily array
for ii=1:noCountries
    % averaging over groups of 3
    smoothDaily(ii,:)=aveknt([0 dailyGlobal(ii,:) 0],4);
end
% adding first entry as 2/3 of the first col + 1/3 of the second
smoothDaily=[(2/3)*dailyGlobal(:,1)+(1/3)*dailyGlobal(:,2) smoothDaily];

% Taiwan series and global sum
posTaiwan=find(strcmp(countries,"Taiwan*"));
seriesTaiwan=smoothDaily(posTaiwan,:);

% global and global without Taiwan
seriesGlobal=sum(smoothDaily);
globalWOTaiwan=seriesGlobal-seriesTaiwan;

% rest of the world as percentage of global (with Italian values removed)
percentageDaily=zeros(noCountries,noDays-2);
for ii=1:noCountries
percentageDaily(ii,:)=smoothDaily(ii,:)./globalWOTaiwan;
end