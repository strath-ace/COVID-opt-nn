function Dataset = process_Taiwan_data(Dataset)
 
%% DATASET1
% % compute only number of new infected and newly tested
% newtested = [0,diff(Dataset(4,:))];
% newinfected = [0,diff(Dataset(end,:))];
% % merge national and international entries in flights (remove idx 11 and 12)
% % remove min and max temperature, wind speed precipitation, fog and pollution (idx 12-17 and 19-21)
% Dataset(7,:) = round((Dataset(7,:)+Dataset(9,:))/2);
% Dataset(8,:) = round((Dataset(8,:)+Dataset(10,:))/2);
% Dataset([1,9:10,12:15,17:19],:) = [];
% % adding increment to tested and infected people
% Dataset = [Dataset(1:4,:); newtested; Dataset(5:end-1,:); newinfected; Dataset(end,:)];

end