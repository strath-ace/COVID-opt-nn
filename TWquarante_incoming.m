function border = TWquarante_incoming(t)
% t-values correspond to days that the following mitigation factors were
% taken
% t(n) = orignal day => area affected -> (native, foreign, chinese)
%      - ranges taken to be even, when possible 10 days either side
%      - tanges trunctaed when too close to day 1 or close to date that 
%      - currently doesn't move
%
% t(1) = 2 => Hubei -> (2, 2, 7)
%      - only affects Hubei => og = 2 
%      => range:       t(1)=[1,3] 
%                      implied: t(1)<=17 & t(1)<=t(2)
%                      day 17: all of China -> (5,5,7)
%        
% t(2) = 3 => Hubei -> (5, 5, 7)
%      - only affects Hubei => og = 3 
%      => range:       t(2)=[1,5] & t(2)>=t(1) 
%                      implied: t(2)<=17
%                      day 17: all of China -> (5,5,7)
%
% t(3) = 3 => China -> (4, 4, 4)    ;excludes HK and Macau
%      - affects China (ex Hubei, HK, Macau) => og = 3
%      => range        t(3)=[1,5] 
%                      implied: t(3)<=12 & t(3)<=t(4)
%                      day 12: Guangdong -> (4,4,7)
%
% t(4) = 5 => China -> (4, 4, 6)    ;excludes HK and Macau
%      - affects China (ex Hubei, HK, Macau) => og = 5
%      => range:       t(4)=[1,9] & t(4)>=t(3) 
%                      implied: t(4)<=12
%                      day 12: Guangdong -> (4,4,7)
% 
% t(5) = 34 => Italy, Iran, Singapore, Thailand, Japan -> (4, 4)
%      - affects the above countries => og = 34
%      => range:       t(5)=[24,44] 
%                      implied: t(5)>=21 & t(5)<=t(6)
%                      day 21: All -> (3,3)
%                      day 38: Italy -> (5,5) - this is now changeable
%
% t(6) = 58 => All -> (5, 6)
%      - affects the whole world => og = 58
%      => range:       t(6)=[48,68]
%                      implied: t(6)>=t(5) & t(6)>=t(7) & t(6)>=t(8) & t(6)>=t(9)
%                               t(6)>=t(10) & t(6)>=t(11) & t(6)>=t(12)
%                      day 56: Singapore, Thailand, Japan -> (5,5)
%                      day 57: Canada, Australia, New Zealand -> (5,5)
%                      these are nowchangeable now
%
% t(7) = 41 => Iran -> (5, 5)
%      - affects Iran => og = 41
%      => range:       t(7)=[31,51] & t(7)>=t(5) & t(7)<=t(6)
%
% t(8) = 35 => South Korea -> (4,5)
%      - affects South Korea => og = 35
%      => range:       t(8)=[25,45] & t(8)<=t(6)
%                      implied: t(8)>=21, t(8)<=t(9)
%                      day 21: All -> (3,3)
%
% t(9) = 37 => South Korea -> (5,5)
%      - affects South Korea => og = 37
%      => range:       t(9)=[27,47] & t(9)>=t(8) & t(9)<=t(6)
%
% t(10) = 46 => France, Germany, Spain -> (4,4)
%      - affects France, Germany, Spain => og = 46
%      => range:       t(10)=[36,56] & t(10)<=t(6)
%                      implied: t(10)>=21
%                      day 21: All -> (3,3)
%
% t(11) = 53 => Europe -> (5,5)
%      - affects Europe => og = 53
%      => range:       t(11)=[43,63] & t(11)<=t(6) & t(11)>=t(10)
%                      implied: t(11)>=t(12)
%
% t(12) = 50 => Europe, Bahrain, Kuwait -> (4,4)
%      - affects Europe, Bahrain, Kuwait => og = 50
%      => range:       t(12)=[40,60] & t(12)<=t(6) & t(12)<=t(11)
%                      implied: t(12)>=21
%                      day 21: All -> (3,3)
%
%
% loading in the smoothed daily cases array as percentages of the global
% number ignoring cases in Taiwan
[countries, provinces, percentageDaily]=JHdata();
[noCountries noDays]=size(percentageDaily);

% levels of quarantine / border control
%levelFor=1/7:1/7:1;
%levelTai=1/5:1/5:1;

% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% ----------------------- China, HK, Macau -------------------------------
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------

% ------------------------------------------------------------------------
% -------------------------------- Data ----------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from China (and Taiwan)
outboundChina=4043686;
inboundChinaChinese=2683093;
inboundChinaForeign=30972;

travelChina=[outboundChina;inboundChinaForeign;inboundChinaChinese]*1/(outboundChina+inboundChinaChinese+inboundChinaForeign);

% tracking total inbound and outbound
outboundSoFar=outboundChina;
inboundSoFar=inboundChinaChinese+inboundChinaForeign;

% days of Hubei
dayHub2=1;          % Hubei -> (2,2,2)
dayHub27=t(1);      % = 2 originally: Hubei -> (2,2,7)
dayHub57=t(2);      % = 3 originally: Hubei -> (5,5,7)

% days of China
dayChina4=t(3);     % = 3 originally: China -> (4,4,4) (excl HK & Macau)
dayChina46=t(4);    % = 5 originally: China -> (4,4,6) (excl HK & Macau)
dayChinaC57=16;     % chinese -> 7 => China -> (5,5,7), HK, Macau -> (5,5,5)
dayChinaF7=17;      % foreigners -> 7 => China -> (5,7,7), HK, Macau -> (5,7,5)

% days of Guangdong and Zhejiang
dayGuang47=12;      % Guangdong -> (4,4,7)
dayZhej57=13;       % Zhejiang -> (5,5,7)

% days of Hong Kong and Macau
dayHKM3=3;          % HK & Macau -> (3,3,3)
dayHKM4=12;         % HK & Macau -> (4,4,4)

% ------------------------- positions and series -------------------------

% Hubei series and global sum
posTaiwan=find(strcmp(countries,"Taiwan*"));

% Hubei series and global sum
posHubei=find(strcmp(provinces,"Hubei"));
seriesHubei=percentageDaily(posHubei,:);

% Guangdong series and global sum
posGuangdong=find(strcmp(provinces,"Guangdong"));
seriesGuangdong=percentageDaily(posGuangdong,:);

% Zhejiang series and global sum
posZhejiang=find(strcmp(provinces,"Zhejiang"));
seriesZhejiang=percentageDaily(posZhejiang,:);

% Hong Kong and Macau series and global sum
posHK=find(strcmp(provinces,"Hong Kong"));
posMacau=find(strcmp(provinces,"Macau"));

seriesHKmacau=percentageDaily([posHK posMacau],:);

% China series minus the above mentioned provinces / countries
posChina=find(strcmp(countries,"China"));
posChina(posChina==posHubei)=[];         % remove Hubei
posChina(posChina==posGuangdong)=[];     % remove Guangdong
posChina(posChina==posZhejiang)=[];      % remove Zhejiang
posChina(posChina==posHK)=[];            % remove Hong Kong
posChina(posChina==posMacau)=[];         % remove Macau

% series for China not including above areas
seriesChina=sum(percentageDaily(posChina,:));

% tracking positions used so far
posSoFar=[posTaiwan;posHubei;posChina;posGuangdong;posZhejiang;posHK;posMacau];

% ------------------------------------------------------------------------
% ----------------------------- Hubei ------------------------------------
% ------------------------------------------------------------------------

% levels of mitigation brought in
levelsHubeiTai=[2;2;5;5]/5;
levelsHubeiElse=[2 2; 2 7; 5 7; 7 7]/7;
levelsHubei=[levelsHubeiTai levelsHubeiElse];

% weighted levels
hubeiWeights=transpose(levelsHubei*travelChina);
hubeiWeightArray=weightChina(hubeiWeights,[dayHub2 dayHub27 dayHub57 dayChinaF7 noDays]);

% weighted border control Hubei
borderHubei=seriesHubei.*hubeiWeightArray;
border=borderHubei;

% ------------------------------------------------------------------------
% ----------------------------- China ------------------------------------
% ------------------------------------------------------------------------

% levels of mitigation brought in
levelsChinaTai=[4;4;5;5]/5;
levelsChinaElse=[4 4; 4 6; 5 7; 7 7]/7;
levelsChina=[levelsChinaTai levelsChinaElse];

% weighted levels
chinaWeights=transpose(levelsChina*travelChina);
chinaWeightArray=weightChina(chinaWeights,[dayChina4 dayChina46 dayChinaC57 dayChinaF7 noDays]);

% weighted border control China
borderChina=seriesChina.*chinaWeightArray;
border=border+borderChina;

% ------------------------------------------------------------------------
% --------------------------- Guangdong ----------------------------------
% ------------------------------------------------------------------------

% levels of mitigation brought in
levelsGuangdongTai=[4;4;4;5;5]/5;
levelsGuangdongElse=[4 4; 4 6; 4 7; 5 7; 7 7]/7;
levelsGuangdong=[levelsGuangdongTai levelsGuangdongElse];

% weighted levels
guangdongWeights=transpose(levelsGuangdong*travelChina);
guangdongWeightArray=weightChina(guangdongWeights,[dayChina4 dayChina46 dayGuang47 dayChinaC57 dayChinaF7 noDays]);

% weighted border control Guangdong
borderGuangdong=seriesGuangdong.*guangdongWeightArray;
border=border+borderGuangdong;

% ------------------------------------------------------------------------
% --------------------------- Zhejiang -----------------------------------
% ------------------------------------------------------------------------

% levels of mitigation brought in
levelsZhejiangTai=[4;4;5;5]/5;
levelsZhejiangElse=[4 4; 4 6; 5 7; 7 7]/7;
levelsZhejiang=[levelsZhejiangTai levelsZhejiangElse];

% weighted levels
zhejiangWeights=transpose(levelsZhejiang*travelChina);
zhejiangWeightArray=weightChina(zhejiangWeights,[dayChina4 dayChina46 dayZhej57 dayChinaF7 noDays]);

% weighted border control Zhejiang
borderZhejiang=seriesZhejiang.*zhejiangWeightArray;
border=border+borderZhejiang;

% ------------------------------------------------------------------------
% ----------------------- Hong Kong & Macau ------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Hong Kong & Macau (and Taiwan) in
% that order: each col 1 = Hong Kong, col 2 = Macau
outboundHKmacau=[1676374 596721];
inboundHKmacauFor=[113656 3017];
inboundHKmacauNat=[1484567 156766];

totalHkmacau=outboundHKmacau+inboundHKmacauFor+inboundHKmacauNat;
travelHKmacau=[outboundHKmacau;inboundHKmacauFor;inboundHKmacauNat]./totalHkmacau;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundHKmacau);
inboundSoFar = inboundSoFar + sum(inboundHKmacauFor)+sum(inboundHKmacauNat);

% levels of mitigation brought in
levelsHKmacauTai=[3;4;5;5]/5;
levelsHKmacauElse=[3 3; 4 4; 5 5; 7 5]/7;
levelsHKmacau=[levelsHKmacauTai levelsHKmacauElse];

% weighted levels
macauHKWeights=transpose(levelsHKmacau*travelHKmacau);
macauHKWeightArray=weightArray(macauHKWeights,[dayHKM3 dayHKM4 dayChinaC57 dayChinaF7 noDays]);

% weighted border control HK and Macau
borderHKmacau=seriesHKmacau.*macauHKWeightArray;
border=border+sum(borderHKmacau);

% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% -------------------------- Rest of World -------------------------------
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------

% ----------- Levels and days used by several countries ------------------

% levels of mitigation brought in
levelsMiscTai=[2;3;4;5;5]/5;
levelsMiscElse=[2;3;4;5;6]/7;
levelsMisc=[levelsMiscTai levelsMiscElse];

% shared days
dayAll2 = 4;        % all -> (2,2)
dayAll3 = 21;       % all -> (3,3)
dayAll56 = t(6);    % = 58 originally: all -> (5,6)

% Italy, Iran, Singapore, Thailand, Japan
dayIISTJ4 = t(5);   % = 34 Italy, Iran, Singapore, Thailand, Japan -> (4,4)
dayItaly5 = 38;     % Italy -> (5,5) 
if t(5)>dayItaly5
    dayItaly5 = t(5); % shifts italy5 so it's always after dayIISTJ4
end
dayIran5 = t(7);    % = 41 originally: Iran -> (5,5)
daySTJ5 = 56;       % Singapore, Thailand, Japan -> (5,5) (also large group)
if t(6)<daySTJ5
    daySTJ5 = t(6); % shifts daySTJ5 so it's always before or equal to dayAll56
end

% South Korea
daySK45 = t(8);     % = 35 originally: SK -> (4,5)
daySK5 = t(9);      % = 37 originally: SK -> (5,5)

% Europe: France, Germany, Spain
dayFGS4 = t(10);    % = 46 originally: FGS -> (4,4)
dayEur5 = t(11);    % = 53 originally: Europe -> (5,5) (also large ->(4,4))
dayEur4 = t(12);    % = 50 originally: Europe, Bahrain, Kuwai -> (4,4)

% Canada, Australia, New Zealand
dayCAN5 = 57;       % CAN -> (5,5)
if t(6)<dayCAN5
    dayCAN5 = t(6); % shifts dayCAN5 so it's always before or equal to dayAll56
end

% ------------------------- positions and series -------------------------

% Italy series and global sum
posItaly=find(strcmp(countries,"Italy"));
seriesItaly=percentageDaily(posItaly,:);

% Iran series and global sum
posIran=find(strcmp(countries,"Iran"));
seriesIran=percentageDaily(posIran,:);

% Singapore, Thailand, Japan series and global sum
posSingapore=find(strcmp(countries,"Singapore"));
posThailand=find(strcmp(countries,"Thailand"));
posJapan=find(strcmp(countries,"Japan"));

seriesSTJ=percentageDaily([posSingapore posThailand posJapan],:);

% South Korea position and series
posSK=find(strcmp(countries,"Korea, South"));
seriesSK=percentageDaily(posSK,:);

posSoFar=[posSoFar;posItaly;posIran;posSingapore;posThailand;posJapan;posSK];

% France, Germany, Spain
posFrance=find(strcmp(countries,"France"));
posGermany=find(strcmp(countries,"Germany"));
posSpain=find(strcmp(countries,"Spain"));

seriesFrance=sum(percentageDaily(posFrance,:));
seriesFGS=[seriesFrance;percentageDaily([posGermany posSpain],:)];

% Bahrain, Kuwait position and series
posBahrain=find(strcmp(countries,"Bahrain"));
posKuwait=find(strcmp(countries,"Kuwait"));

seriesBK=percentageDaily([posBahrain posKuwait],:);

posSoFar=[posSoFar;posFrance;posGermany;posSpain;posBahrain;posKuwait];

% Europe position and series
posAustria=find(strcmp(countries,"Austria"));
posBelgium=find(strcmp(countries,"Belgium"));
posIceland=find(strcmp(countries,"Iceland"));
posNorway=find(strcmp(countries,"Norway"));
posSweden=find(strcmp(countries,"Sweden"));
posSwitzerland=find(strcmp(countries,"Switzerland"));
posCzechia=find(strcmp(countries,"Czechia"));
posEstonia=find(strcmp(countries,"Estonia"));
posFinland=find(strcmp(countries,"Finland"));
posGreece=find(strcmp(countries,"Greece"));
posHungary=find(strcmp(countries,"Hungary"));
posLatvia=find(strcmp(countries,"Latvia"));
posLiechtenstein=find(strcmp(countries,"Liechtenstein"));
posLithuania=find(strcmp(countries,"Lithuania"));
posLuxembourg=find(strcmp(countries,"Luxembourg"));
posMalta=find(strcmp(countries,"Malta"));
posPoland=find(strcmp(countries,"Poland"));
posPortugal=find(strcmp(countries,"Portugal"));
posSlovakia=find(strcmp(countries,"Slovakia"));
posSlovenia=find(strcmp(countries,"Slovenia"));
posDenmark=find(strcmp(countries,"Denmark"));
posNetherlands=find(strcmp(countries,"Netherlands"));

seriesDenmark=sum(percentageDaily(posDenmark,:));
seriesNetherlands=sum(percentageDaily(posNetherlands,:));
seriesEur=[percentageDaily([posAustria posBelgium posIceland posNorway posSweden posSwitzerland posCzechia posEstonia posFinland posGreece posHungary posLatvia posLiechtenstein posLithuania posLuxembourg posMalta posPoland posPortugal posSlovakia posSlovenia],:);seriesDenmark;seriesNetherlands];

posSoFar=[posSoFar;posAustria;posBelgium;posIceland;posNorway;posSweden;posSwitzerland;posCzechia;posEstonia;posFinland;posGreece;posHungary;posLatvia;posLiechtenstein;posLithuania;posLuxembourg;posMalta;posPoland;posPortugal;posSlovakia;posSlovenia;posDenmark;posNetherlands];

% Ireland, UK, Dubai (United Arab Emirates)
posIreland=find(strcmp(countries,"Ireland"));
posUK=find(strcmp(countries,"United Kingdom"));
posUAE=find(strcmp(countries,"United Arab Emirates"));

seriesIUD=[percentageDaily(posIreland,:);sum(percentageDaily(posUK,:));percentageDaily(posUAE,:)];

posSoFar=[posSoFar;posIreland;posUK;posUAE];
    
% large group of countries position and series
posBurma=find(strcmp(countries,"Burma"));
posLaos=find(strcmp(countries,"Laos"));
posVietnam=find(strcmp(countries,"Vietnam"));
posMalaysia=find(strcmp(countries,"Malaysia"));
posPhilippines=find(strcmp(countries,"Philippines"));
posBrunei=find(strcmp(countries,"Brunei"));
posIndonesia=find(strcmp(countries,"Indonesia"));
posCambodia=find(strcmp(countries,"Cambodia"));
posTimorLeste=find(strcmp(countries,"Timor-Leste"));
posIndia=find(strcmp(countries,"India"));
posSriLanka=find(strcmp(countries,"Sri Lanka"));
posBangladesh=find(strcmp(countries,"Bangladesh"));
posNepal=find(strcmp(countries,"Nepal"));
posBhutan=find(strcmp(countries,"Bhutan"));
posMaldives=find(strcmp(countries,"Maldives"));
posUS=find(strcmp(countries,"US"));
posMoldova=find(strcmp(countries,"Moldova"));

seriesLar=percentageDaily([posBurma posLaos posVietnam posMalaysia posPhilippines posBrunei posIndonesia posCambodia posTimorLeste posIndia posSriLanka posBangladesh posNepal posBhutan posMaldives posUS posMoldova],:);

posSoFar=[posSoFar;posBurma;posLaos;posVietnam;posMalaysia;posPhilippines;posBrunei;posIndonesia;posCambodia;posTimorLeste;posIndia;posSriLanka;posBangladesh;posNepal;posBhutan;posMaldives;posUS;posMoldova];

% Canada, Australia, New Zealand
posCanada=find(strcmp(countries,"Canada"));
posOz=find(strcmp(countries,"Australia"));
posNZ=find(strcmp(countries,"New Zealand"));

seriesCAN=[sum(percentageDaily(posCanada,:));sum(percentageDaily(posOz,:));percentageDaily(posNZ,:)];

posSoFar=[posSoFar;posCanada;posOz;posNZ];

% the rest of the world
posRest=setdiff([1:noCountries],posSoFar);
seriesRest=sum(percentageDaily(posRest,:));

% ------------------------------------------------------------------------
% ----------------------------- Italy ------------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Italy (and Taiwan)
outboundItaly=27717;
inboundItaly=20115;
travelItaly=[outboundItaly;inboundItaly]/(outboundItaly+inboundItaly);

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + outboundItaly;
inboundSoFar = inboundSoFar + inboundItaly;

% weighted levels
italyWeights=transpose(levelsMisc*travelItaly);
italyWeightArray=weightChina(italyWeights,[dayAll2 dayAll3 dayIISTJ4 dayItaly5 dayAll56 noDays]);

% weighted border control Italy
borderItaly = seriesItaly.*italyWeightArray;
border = border + borderItaly;

% ------------------------------------------------------------------------
% ----------- TYPO ----------- Iran ----------- TYPO ---------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Iran (and Taiwan)
outboundIran=13;
inboundIran=1059;
travelIran=[outboundIran;inboundIran]/(outboundIran+inboundIran);

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + outboundIran;
inboundSoFar = inboundSoFar + inboundIran;

% weighted levels TYPO
iranWeights=transpose(levelsMisc*travelIran);
%iranWeights=[0.2871 0.43065 0.707045 0.717751 0.858875];
iranWeightArray=weightChina(iranWeights,[dayAll2 dayAll3 dayIISTJ4 dayIran5 dayAll56 noDays]);

% weighted border control HK and Macau
borderIran = seriesIran.*iranWeightArray;
border = border + borderIran;

% ------------------------------------------------------------------------
% ------------------- Singapore, Thailand, Japan -------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Singapore, Thailand, Japan (and Taiwan) in
% that order: each col 1 = Singapore, col 2 = Thailand, col 3 = Japan
outboundSTJ=[387485 830166 4911481];
inboundSTJ=[460635 413926 2167952];
totalSTJ=outboundSTJ+inboundSTJ;
travelSTJ=[outboundSTJ;inboundSTJ]./totalSTJ;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundSTJ);
inboundSoFar = inboundSoFar + sum(inboundSTJ);

% weighted levels so each col gives that countries weights
STJWeights=transpose(levelsMisc*travelSTJ);
STJWeightArray=weightArray(STJWeights,[dayAll2 dayAll3 dayIISTJ4 daySTJ5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderSTJ = seriesSTJ.*STJWeightArray;
border = border + sum(borderSTJ);

% ------------------------------------------------------------------------
% -------------------------- South Korea ---------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Italy (and Taiwan)
outboundSK=1209062;
inboundSK=1242598;
travelSK=[outboundSK;inboundSK]/(outboundSK+inboundSK);

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + outboundSK;
inboundSoFar = inboundSoFar + inboundSK;

% levels of mitigation brought in
levelsSKTai=[2;3;4;5;5]/5;
levelsSKElse=[2;3;5;5;6]/7;
levelsSK=[levelsSKTai levelsSKElse];

% weighted levels
SKWeights=transpose(levelsSK*travelSK);
SKWeightArray=weightChina(SKWeights,[dayAll2 dayAll3 daySK45 daySK5 dayAll56 noDays]);

% weighted border control South Korea
borderSK = seriesSK.*SKWeightArray;
border = border + borderSK;

% ------------------------------------------------------------------------
% --------- Typo -------- France, Germany, Spain -------- Typo -----------
% ------------------------------------------------------------------------

% ratios for travel to and from France, Germany, Spain (and Taiwan) in
% that order: each col 1 = France, col 2 = Germany, col 3 = Spain
outboundFGS=[75642 69021 9];
inboundFGS=[57393 72708 14298];
totalFGS=outboundFGS+inboundFGS;
travelFGS=[outboundFGS;inboundFGS]./totalFGS;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundFGS);
inboundSoFar = inboundSoFar + sum(inboundFGS);

% weighted levels so each col gives that countries weights
FGSWeights=transpose(levelsMisc*travelFGS);
FGSWeightArray=weightArray(FGSWeights,[dayAll2 dayAll3 dayFGS4 dayEur5 dayAll56 noDays]);
%FGSWeightArray=STJWeightArray;

% weighted border control France, Germany, Spain
borderFGS = seriesFGS.*FGSWeightArray;
border = border + sum(borderFGS);

% ------------------------------------------------------------------------
% ------------------------- Bahrain, Kuwait ------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Bahrain, Kuwait (and Taiwan) in
% that order: each col 1 = Bahrain, col 2 = Kuwait
outboundBK=[1 2];
inboundBK=[110 291];
totalBK=outboundBK+inboundBK;
travelBK=[outboundBK;inboundBK]./totalBK;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundBK);
inboundSoFar = inboundSoFar + sum(inboundBK);

% levels of mitigation brought in
levelsBKTai=[2;3;4;5]/5;
levelsBKElse=[2;3;4;6]/7;
levelsBK=[levelsBKTai levelsBKElse];

% weighted levels so each col gives that countries weights
BKWeights=transpose(levelsBK*travelBK);
BKWeightArray=weightArray(BKWeights,[dayAll2 dayAll3 dayEur4 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderBK = seriesBK.*BKWeightArray;
border = border + sum(borderBK);

% ------------------------------------------------------------------------
% ------------------------------ Europe ----------------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Europe (and Taiwan) in
% that order: each col: Austria, Belgium, Iceland, 
% Norway, Sweden, Switzerland, Czech Rep, Estonia, FInland, Greece, 
% Hungary, Latvia, Liechtenstein, Lithuania, Luxembourg, Malta, Poland, 
% Portugal, Slovakia, Slovenia, Denmark, Netherlands
outboundEur=[81537, 1, 88, 1, 0, 6, 10, 0, 10, 2, 0, 0, 0, 0, 0, 0, 27, 1, 0, 0, 2, 63334];
inboundEur=[9160, 8980, 302, 3690, 9522, 12011, 4718, 577, 3798, 2050, 2432, 699, 49, 832, 588, 270, 8065, 7789, 2473, 670, 7667, 27640];
totalEur=outboundEur+inboundEur;
travelEur=[outboundEur;inboundEur]./totalEur;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundEur);
inboundSoFar = inboundSoFar + sum(inboundEur);

% weighted levels so each col gives that countries weights
eurWeights=transpose(levelsMisc*travelEur);
eurWeightArray=weightArray(eurWeights,[dayAll2 dayAll3 dayEur4 dayEur5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderEur = seriesEur.*eurWeightArray;
border = border + sum(borderEur);

% ------------------------------------------------------------------------
% ------------------------- Ireland, UK, Dubai ---------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Ireland, UK, Dubai (and Taiwan) in
% that order: each col 1 = Ireland, col 2 = UK, etc.
outboundIUD=[1 37992 136603];
inboundIUD=[4218 76904 2339];
totalIUD=outboundIUD+inboundIUD;
travelIUD=[outboundIUD;inboundIUD]./totalIUD;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundIUD);
inboundSoFar = inboundSoFar + sum(inboundIUD);

% levels of mitigation brought in
levelsIUDTai=[2;3;5;5]/5;
levelsIUDElse=[2;3;5;6]/7;
levelsIUD=[levelsIUDTai levelsIUDElse];

% weighted levels so each col gives that countries weights
IUDWeights=transpose(levelsIUD*travelIUD);
IUDWeightArray=weightArray(IUDWeights,[dayAll2 dayAll3 dayEur5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderIUD = seriesIUD.*IUDWeightArray;
border = border + sum(borderIUD);

% ------------------------------------------------------------------------
% -------------------- Large group of countries --------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Europe (and Taiwan) in
% that order: each col: "Burma", "Laos", "Vietnam", "Malaysia", 
% "Philippines", "Brunei", "Indonesia", "Cambodia", "Timor-Leste", "India", 
% "Sri Lanka", "Bangladesh", "Nepal", "Bhutan", "Maldives", "US", "Moldova"
outboundLar=[25071, 0, 853257, 299959, 331792, 6317, 156060, 89975, 0, 11938, 9, 2, 0, 8926, 3, 550978, 0];
inboundLar=[17591, 857, 405396, 537692, 509519, 3557, 229960, 14140, 119, 40353, 1348, 1180, 1832, 922, 107, 605054, 36];
totalLar=outboundLar+inboundLar;
travelLar=[outboundLar;inboundLar]./totalLar;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundLar);
inboundSoFar = inboundSoFar + sum(inboundLar);

% weighted levels so each col gives that countries weights
larWeights=transpose(levelsMisc*travelLar);
larWeightArray=weightArray(larWeights,[dayAll2 dayAll3 dayEur5 daySTJ5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderLar = seriesLar.*larWeightArray;
border = border + sum(borderLar);

% ------------------------------------------------------------------------
% ------------------ Canada, Australia, New Zealand ----------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Canada, Australia, New Zealand (and Taiwan)
% in that order: each col 1 = Canada, col 2 = Australia, etc.
outboundCAN=[125474 180048 32457];
inboundCAN=[136651 111788 19831];
totalCAN=outboundCAN+inboundCAN;
travelCAN=[outboundCAN;inboundCAN]./totalCAN;

% tracking outbound and inbound so far
outboundSoFar = outboundSoFar + sum(outboundCAN);
inboundSoFar = inboundSoFar + sum(inboundCAN);

% weighted levels so each col gives that countries weights
cANWeights=transpose(levelsMisc*travelCAN);
cANWeightArray=weightArray(cANWeights,[dayAll2 dayAll3 dayEur5 dayCAN5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderCAN = seriesCAN.*cANWeightArray;
border = border + sum(borderCAN);

% ------------------------------------------------------------------------
% ------------------------- Rest of the world ----------------------------
% ------------------------------------------------------------------------

% ratios for travel to and from Asia, Africa, Americas, Oceania, Europe, 
% and other (with Taiwan) in
% that order: each col 1 = Ireland, col 2 = UK, etc.
outboundTotals=[15757473 27 676520 228135 363583 75597];
inboundTotals=[10561699 12537 766254 134860 386752 2003];

outboundRest=sum(outboundTotals)-outboundSoFar;
inboundRest=sum(inboundTotals)-inboundSoFar;

totalRest=outboundRest+inboundRest;
travelRest=[outboundRest;inboundRest]/totalRest;

% weighted levels so each col gives that countries weights
restWeights=transpose(levelsBK*travelRest);
restWeightArray=weightChina(restWeights,[dayAll2 dayAll3 dayEur5 dayAll56 noDays]);

% weighted border control Singpore, Thailand, Japan
borderRest = seriesRest.*restWeightArray;
border = border + borderRest;