function borderWeights=weightChina(weights,days)
% form weight array for Chinese provinces, HK and Macau

for ii=length(days)-1:-1:1
    if days(ii)==days(ii+1)
        days(ii)=[];
        weights(ii)=[];
    end
end

% % allowing second day to overlap with first day (necessary for Hubei)
% if days(2)==days(3)
%     days=[days(1) days(3:end)];
%     weights=[weights(1) weights(3:end)];
% end
% 
% % allowing second day to overlap with first day (necessary for Hubei)
% if days(1)==days(2)
%     days=days(2:end);
%     weights=weights(2:end);
% end

[newDays, indicesNew]=sort(days(1:end-1));
newDays=[newDays days(end)];
newWeights=weights(indicesNew);

% initialise weights array up until the second days in days array
if newDays(1)==1 % checking we start with a non-zero level
weightsArray=newWeights(1)*ones(1,newDays(2)-newDays(1));
else % if we start with a zero level
weightsArray=[zeros(1,newDays(1)-1) newWeights(1)*ones(1,newDays(2)-newDays(1))];
end

% making the rest of the array (except last group of values)
for jj=2:length(newDays)-2
    weightsArray=[weightsArray newWeights(jj)*ones(1,newDays(jj+1)-newDays(jj))];
end

% adding last group of values
borderWeights=[weightsArray newWeights(end)*ones(1,newDays(end)+1-newDays(length(newDays)-1))];