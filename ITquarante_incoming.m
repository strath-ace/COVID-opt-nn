function border = ITquarante_incoming(t)

% cumulative data for Italy, China and Global minus Italy
data_IT = [0	0	0	0	0	0	0	0	0	2	2	2	2	2	2	2	3	3	3	3	3	3	3	3	3	3	3	3	3	3	20	62	155	229	322	453	655	888	1128	1694	2036	2502	3089	3858	4636	5883	7375	9172	10149	12462	12462	17660	21157	24747	27980	31506	35713	41035	47021	53578	59138	63927	69176	74386	80589	86498	92472	97689	101739	105792	110574	115242	119827	124632	128948	132547	];
data_China = [548	643	920	1406	2075	2877	5509	6087	8141	9802	11891	16630	19716	23707	27440	30587	34110	36814	39829	42354	44386	44759	59895	66358	68413	70513	72434	74211	74619	75077	75550	77001	77022	77241	77754	78166	78600	78928	79356	79932	80136	80261	80386	80537	80690	80770	80823	80860	80887	80921	80932	80945	80977	81003	81033	81058	81102	81156	81250	81305	81435	81498	81591	81661	81782	81897	81999	82122	82198	82279	82361	82432	82511	82543	82602	82665	];
data_Global = [555	654	941	1434	2118	2927	5578	6166	8234	9927	12038	16787	19881	23892	27635	30794	34391	37120	40150	42762	44802	45221	60368	66885	69030	71224	73258	75136	75639	76197	76819	78572	78958	79561	80406	81388	82746	84112	86011	88369	90306	92840	95120	97886	101801	105847	109821	113590	118620	125875	128352	145205	156101	167454	181574	197102	214821	242570	272208	304507	336953	378235	418045	467653	529591	593291	660693	720140	782389	857487	932605	1013466	1095917	1197408	1272115	1345101	];

% daily increase of time series
daily_data_IT = diff(data_IT);
daily_data_China = diff(data_China);
daily_data_Global = diff(data_Global);
daily_data_Global_WO_IT = daily_data_Global - daily_data_IT;
daily_data_rest_WO_IT = daily_data_Global - daily_data_IT - daily_data_China;

% inital entry for smoothed daily time series = 2/3*series(1) +
% 1/3*series(2)
%smooth_daily_IT=2/3*daily_data_IT(1)+1/3*daily_data_IT(2);
smooth_daily_China=2/3*daily_data_China(1)+1/3*daily_data_China(2);
smooth_daily_Global=2/3*daily_data_Global(1)+1/3*daily_data_Global(2);
smooth_daily_Global_WO_IT=2/3*daily_data_Global_WO_IT(1)+1/3*daily_data_Global_WO_IT(2);
smooth_daily_rest_WO_IT=2/3*daily_data_rest_WO_IT(1)+1/3*daily_data_rest_WO_IT(2);

% loop averaging daily series over day before, day of and day after
for ii=1:length(daily_data_IT)
    if ii>1 && ii<length(daily_data_IT)
        smooth_daily_China=[smooth_daily_China mean(daily_data_China(ii-1:ii+1))];
        smooth_daily_Global=[smooth_daily_Global mean(daily_data_Global(ii-1:ii+1))];
        smooth_daily_Global_WO_IT=[smooth_daily_Global_WO_IT mean(daily_data_Global_WO_IT(ii-1:ii+1))];
        smooth_daily_rest_WO_IT=[smooth_daily_rest_WO_IT mean(daily_data_rest_WO_IT(ii-1:ii+1))];
    elseif ii==1
        smooth_daily_China=[smooth_daily_China mean(daily_data_China(ii:ii+1))];
        smooth_daily_Global=[smooth_daily_Global mean(daily_data_Global(ii:ii+1))];
        smooth_daily_Global_WO_IT=[smooth_daily_Global_WO_IT mean(daily_data_Global_WO_IT(ii:ii+1))];
        smooth_daily_rest_WO_IT=[smooth_daily_rest_WO_IT mean(daily_data_rest_WO_IT(ii:ii+1))];
    else
        smooth_daily_China=[smooth_daily_China mean(daily_data_China(ii-1:ii))];
        smooth_daily_Global=[smooth_daily_Global mean(daily_data_Global(ii-1:ii))];
        smooth_daily_Global_WO_IT=[smooth_daily_Global_WO_IT mean(daily_data_Global_WO_IT(ii-1:ii))];
        smooth_daily_rest_WO_IT=[smooth_daily_rest_WO_IT mean(daily_data_rest_WO_IT(ii-1:ii))];
    end
end

% daily China and rest of the world as percentage of global (with Italian values removed)
percent_daily_China = smooth_daily_China ./ smooth_daily_Global_WO_IT;
percent_daily_rest = smooth_daily_rest_WO_IT ./ smooth_daily_Global_WO_IT;

% ratios of inbound and outbound passengers for italy from China: outbound =>
% Italians, inbound => foreign tourists
China_outbound = 69444/149599;
China_inbound = 80155/149599;

% ratios of inbound and outbound passengers for italy from the rest of the world: outbound =>
% Italians, inbound => foreign tourists
All_outbound= 16534662/47157929;
All_inbound= 30623267/47157929;

% weights for China time series
fstep_China_outbound = zeros(length(smooth_daily_China),1);
fstep_China_outbound(1:t(1)-1) =China_outbound*1/5*2;
fstep_China_outbound(t(1):end) =China_outbound*1/5*5;
fstep_China_inbound = zeros(length(smooth_daily_China),1);
fstep_China_inbound(1:t(1)-1) =China_inbound*(1/7)*2;
fstep_China_inbound(t(1):end) = China_inbound*(1/7)*7;
% combining inbound and outbound travellers
fstep_China = fstep_China_outbound + fstep_China_inbound;

% weights for rest of the world time series
fstep_rest_outbound = zeros(length(smooth_daily_China),1);
fstep_rest_outbound(1:t(2)-1) =0;
fstep_rest_outbound(t(2):t(3)-1) =All_outbound*1/5*2;
fstep_rest_outbound(t(3):end) =All_outbound*1/5*5;
fstep_rest_inbound = zeros(length(smooth_daily_China),1);
fstep_rest_inbound(1:t(2)-1) = 0;
fstep_rest_inbound(t(2):t(3)-1) = All_inbound*(1/7)*2;
fstep_rest_inbound(t(3):end) = All_inbound*(1/7)*5;
% combining inbound and outbound travellers
fstep_rest = fstep_rest_outbound + fstep_rest_inbound;

% weighted border control against China and the rest of the world
border_China = percent_daily_China.*fstep_China';
border_rest=percent_daily_rest.*fstep_rest';

% combining individual border control
border = border_China + border_rest;