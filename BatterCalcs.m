%Batter Analysis



BatEqnStorage = zeros(22,2); %Adjust as needed
%Contact, Gap (AB), Trip Rate, HR (AB), Eye (PA), K (AB), SB Att (times on 1b), SB%, DP (NOT USED) (per ball in play not hit), UBR speed (per times on base), UBR BR (per times on base), Speed v BR
%Zone Ratings for Positions 1B, 2B, 3B, SS,LF,CF,RF
%CERA, SBAttvArm, RTO%vArm

%% Contact
Hits = zeros(length(RV),1);
AB = Hits;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,1) == RV(i);
    Hits(i) = sum(sum(Stat(ind,4:7)));
    AB(i) = sum(Stat(ind,3)); %use 2 for PA and 3 for AB (11,12)
end
Avg = Hits./AB;
figure;
scatter(RV,Avg)
xlabel('Contact Rating')
ylabel('Average')
title('Average vs Contact Rating')

valid = ~isnan(Avg);
AvgFit1 = lscov(xvec(valid,:),Avg(valid),AB(valid));
AvgFit2 = lscov(xvec(valid,:),Avg(valid),ones(sum(valid),1));
hold on;
plot(RV,AvgFit1(2)+RV.*AvgFit1(1));
plot(RV,AvgFit2(2)+RV.*AvgFit2(1));
legend('Stat','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(1,:) = AvgFit1.';

%% Power
HR = zeros(length(RV),1);
AB = HR;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,3) == RV(i);
    HR(i) = sum(Stat(ind,7));
    AB(i) = sum(Stat(ind,3));
end
HRRate = HR./AB;
figure;
scatter(RV,HRRate)
xlabel('Power Rating')
ylabel('HRRate')
title('HRRate vs Power Rating')

valid = ~isnan(HRRate);
HRFit1 = lscov(xvec(valid,:),HRRate(valid),AB(valid));
HRFit2 = lscov(xvec(valid,:),HRRate(valid),ones(sum(valid),1));
hold on;
plot(RV,HRFit1(2)+RV.*HRFit1(1));
plot(RV,HRFit2(2)+RV.*HRFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(4,:) = HRFit1.';

%% Gap Power
Gap = zeros(length(RV),1);
AB = Gap;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,2) == RV(i);
    Gap(i) = sum(sum(Stat(ind,5:6))); %Include doubles and triples
    AB(i) = sum(Stat(ind,3));
end
GapRate = Gap./AB;
figure;
scatter(RV,GapRate)
xlabel('Gap Rating')
ylabel('GapRate')
title('GapRate vs Gap Rating')

valid = ~isnan(GapRate);
GapFit1 = lscov(xvec(valid,:),GapRate(valid),AB(valid));
GapFit2 = lscov(xvec(valid,:),GapRate(valid),ones(sum(valid),1));
hold on;
plot(RV,GapFit1(2)+RV.*GapFit1(1));
plot(RV,GapFit2(2)+RV.*GapFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(2,:) = GapFit1.';

%% Eye Rating
BB = zeros(length(RV),1);
PA = BB;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,4) == RV(i);
    BB(i) = sum(Stat(ind,10)); 
    PA(i) = sum(Stat(ind,2)); %Plate Appearances
end
BBRate = BB./PA;
figure;
scatter(RV,BBRate)
xlabel('Eye Rating')
ylabel('BBRate')
title('BBRate vs Eye Rating')

valid = ~isnan(BBRate);
BBFit1 = lscov(xvec(valid,:),BBRate(valid),PA(valid));
BBFit2 = lscov(xvec(valid,:),BBRate(valid),ones(sum(valid),1));
hold on;
plot(RV,BBFit1(2)+RV.*BBFit1(1));
plot(RV,BBFit2(2)+RV.*BBFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(5,:) = BBFit1.';

%% K Rating
K = zeros(length(RV),1);
AB = K;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,5) == RV(i);
    K(i) = sum(Stat(ind,15));
    AB(i) = sum(Stat(ind,3)); %Abs?
end
KRate = K./AB;
figure;
scatter(RV,KRate)
xlabel('Avoid K Rating')
ylabel('KRate')
title('KRate vs Avoid K Rating')

valid = ~isnan(KRate);
KFit1 = lscov(xvec(valid,:),KRate(valid),AB(valid));
KFit2 = lscov(xvec(valid,:),KRate(valid),ones(sum(valid),1));
hold on;
plot(RV,KFit1(2)+RV.*KFit1(1));
plot(RV,KFit2(2)+RV.*KFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthEast')

BatEqnStorage(6,:) = KFit1.';

%% Speed impact on double/triple split
Trip = zeros(length(RV),1);
GapTot = Trip;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,39) == RV(i); %Speed
    Trip(i) = sum(Stat(ind,6));
    GapTot(i) = sum(sum(Stat(ind,5:6)));
end
TRate = Trip./GapTot;
figure;
scatter(RV,TRate)
xlabel('Speed Rating')
ylabel('Triple Rate')
title('Triple Rate vs Speed Rating')

valid = ~isnan(TRate);
TFit1 = lscov(xvec(valid,:),TRate(valid),GapTot(valid));
TFit2 = lscov(xvec(valid,:),TRate(valid),ones(sum(valid),1));
hold on;
plot(RV,TFit1(2)+RV.*TFit1(1));
plot(RV,TFit2(2)+RV.*TFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(3,:) = TFit1.';

%% Stolen Bases vs Speed
SBAttempt = zeros(length(RV),1);
TimesOB = SBAttempt;
for i = 1:length(RV)
    ind = Rat(:,39) == RV(i);
    SBAttempt(i) = sum(sum(Stat(ind,24:25)));
    TimesOB(i) = sum(sum(Stat(ind,[4,10:12]))); %Times on first
end
SBrate = SBAttempt./TimesOB;
figure;
scatter(RV,SBrate)
xlabel('Speed Rating')
ylabel('SB Attempt Rate')
title('SB Attempt Rate vs Speed Rating')

%valid = ~isnan(log(SBrate)) & ~isinf(log(SBrate));
%SBFit1 = lscov(xvec(valid,:),log(SBrate(valid)),ones(sum(valid),1));
valid = ~isnan(SBrate);
SBFit1 = lscov(xvec(valid,:),SBrate(valid),SBAttempt(valid));
SBFit2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
hold on;
%plot(RV,exp(SBFit1(2)+RV*SBFit1(1)));
plot(RV,SBFit1(2)+RV*SBFit1(1));
plot(RV,SBFit2(2)+RV*SBFit2(1));
legend('Data','WeightFit','RegLogFit','Location','NorthWest')
hold off;

BatEqnStorage(7,:) = SBFit1.';

%% Stolen Base Success Rate
SB = zeros(length(RV),1);
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,40) == RV(i); %STE
    SB(i) = sum(Stat(ind,24));
    SBAttempt(i) = sum(sum(Stat(ind,24:25))); %Sb Attempts
end
SBPct = SB./SBAttempt;
figure;
scatter(RV,SBPct)
xlabel('Steal Rating')
ylabel('SB%')
title('SB% vs Steal Rating')

valid = ~isnan(SBPct);
SBFit1ste = lscov(xvec(valid,:),SBPct(valid),SBAttempt(valid));
SBFit2ste = lscov(xvec(valid,:),SBPct(valid),ones(sum(valid),1));
hold on;
plot(RV,SBFit1ste(2)+RV*SBFit1ste(1));
plot(RV,SBFit2ste(2)+RV*SBFit2ste(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')
hold off;

BatEqnStorage(8,:) = SBFit1ste.';

%% Double Plays
DP = zeros(length(RV),1);
BIP = DP;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,39) == RV(i); %Speed
    DP(i) = sum(Stat(ind,16)); %GDP
    BIP(i) = sum(Stat(ind,3))-sum(sum(Stat(ind,4:7))) - sum(Stat(ind,15)); %AB - H - SO
end
DPRate = DP./BIP;
figure;
scatter(RV,DPRate)
xlabel('Speed Rating')
ylabel('DP/BIP')
title('DP/BIP vs Speed Rating')

valid = ~isnan(DPRate);
DPFit1 = lscov(xvec(valid,:),DPRate(valid),BIP(valid));
DPFit2 = lscov(xvec(valid,:),DPRate(valid),ones(sum(valid),1));
hold on;
plot(RV,DPFit1(2)+RV.*DPFit1(1));
plot(RV,DPFit2(2)+RV.*DPFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(9,:) = DPFit1.';

%% UBR
UBR = zeros(length(RV),1);
OB = UBR;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,39) == RV(i); %Speed
    UBR(i) = sum(Stat(ind,28)); %UBR
    OB(i) = sum(sum(Stat(ind,[4:6,10:12]))); %Times on base
end
UBRateSpeed = UBR./OB;
figure;
scatter(RV,UBRateSpeed)
xlabel('BaseRunning/Speed Rating')
ylabel('UBR/BIP')
title('UBR/BIP vs BaseRunning/Speed Rating')

valid = ~isnan(UBRateSpeed);
UBRFit1Speed = lscov(xvec(valid,:),UBRateSpeed(valid),OB(valid));
%UBRFit2 = lscov(xvec(valid,:),UBRateSpeed(valid),ones(sum(valid),1));

BatEqnStorage(10,:) = UBRFit1Speed.';

for i = 1:length(RV)
    ind = Rat(:,41) == RV(i); %Baserunning
    UBR(i) = sum(Stat(ind,28)); %UBR
    OB(i) = sum(sum(Stat(ind,[4:6,10:12]))); %Times on base
end
hold on;
UBRateBR = UBR./OB;
scatter(RV,UBRateBR)

valid = ~isnan(UBRateBR);
UBRFit1BR = lscov(xvec(valid,:),UBRateBR(valid),OB(valid));
%UBRFit2 = lscov(xvec(valid,:),UBRate(valid),ones(sum(valid),1));
plot(RV,UBRFit1Speed(2)+RV.*UBRFit1Speed(1));
plot(RV,UBRFit1BR(2)+RV.*UBRFit1BR(1));
legend('SpeedData','BRData','WeightFit Speed','WeightFit BR','Location','NorthWest')
hold off;

BatEqnStorage(11,:) = UBRFit1BR.';

%% Speed vs BR
WeightBR = zeros(length(RV),1);
PA = WeightBR;
%Contact-Average
for i = 1:length(RV)
    ind = Rat(:,39) == RV(i); %Speed
    WeightBRtemp = Stat(ind,2).*Rat(ind,41); %BR * PA
    WeightBR(i) = sum(WeightBRtemp);
    PA(i) = sum(Stat(ind,2)); %PA
end
BR = WeightBR./PA;
figure;
scatter(RV,BR)
xlabel('Speed Rating')
ylabel('BaseRunning Rating')
title('Baserunning vs Speed Rating')

valid = ~isnan(BR);
BRFit1 = lscov(xvec(valid,:),BR(valid),PA(valid));
BRFit2 = lscov(xvec(valid,:),BR(valid),ones(sum(valid),1));
hold on;
plot(RV,BRFit1(2)+RV.*BRFit1(1));
plot(RV,BRFit2(2)+RV.*BRFit2(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')

BatEqnStorage(12,:) = BRFit1.';


%% Position Rating vs ZR

P = {'1B','2B','3B','SS','LF','CF','RF'};
ZR = zeros(length(RV),1);
IP = ZR;
ZRFit = zeros(length(P),2);
for j = 1:length(P)
    for i = 1:length(RV)
        ind = (Rat(:,30) == RV(i) & strcmp(P{j},Pos));
        ZR(i) = sum(Stat(ind,37)); %Zone Rating
        IP(i) = sum(Stat(ind,41)); %IP
    end
    ZRpO = ZR./IP;
    figure;
    scatter(RV,ZRpO)
    xlabel('Position Rating')
    ylabel('ZR')
    title([P{j} ': ZR vs Position Rating'])
    
    valid = ~isnan(ZRpO);
    ZRFit(j,:) = lscov(xvec(valid,:),ZRpO(valid),IP(valid));
    hold on;
    plot(RV,ZRFit(j,2)+RV.*ZRFit(j,1));
    legend('Data','WeightFit','Location','NorthWest')
    hold off;
end

BatEqnStorage(13:19,:) = ZRFit;

%% Cera
P = {'C'};
Runs = zeros(length(RV),1);
IP = Runs;

j = 1;
for i = 1:length(RV)
    ind = (Rat(:,29) == RV(i) & strcmp(P{j},Pos)); %Infield Error
    Runs(i) = sum(Stat(ind,43)); %Runs by Catcher
    IP(i) = sum(Stat(ind,41)); %IP
end
CERA = Runs./IP;
figure;
scatter(RV,CERA)
xlabel('Catcher Position Rating')
ylabel('CERA')
title([P{j} ': CERA vs Catcher Position Rating'])

valid = ~isnan(CERA);
CERAFit(j,:) = lscov(xvec(valid,:),CERA(valid),IP(valid));
hold on;
plot(RV,CERAFit(j,2)+RV.*CERAFit(j,1));
legend('Data','WeightFit','Location','NorthWest')
hold off;

BatEqnStorage(20,:) = CERAFit;

%% Stolen Base Attempts CATCHER
SBAttempt = zeros(length(RV),1);
IP = SBAttempt;
for i = 1:length(RV)
    ind = Rat(:,28) == RV(i); %Catcher Arm
    SBAttempt(i) = sum(Stat(ind,39));
    IP(i) = sum(Stat(ind,41)); %IP
end
SBrate = SBAttempt./IP;
valid = ~isnan(SBrate) & SBAttempt > 0;
figure;
scatter(RV(valid),SBrate(valid))
xlabel('Arm Rating')
ylabel('SB Attempt Rate')
title('SB Attempt Rate vs Catcher Arm Rating')

SBFitArm1 = lscov(xvec(valid,:),SBrate(valid),SBAttempt(valid));
SBFitArm2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
hold on;
plot(RV,SBFitArm1(2)+RV*SBFitArm1(1));
plot(RV,SBFitArm2(2)+RV*SBFitArm2(1));
legend('Data','WeightFit','RegLogFit','Location','NorthWest')
hold off;

BatEqnStorage(21,:) = SBFitArm1;

%% Runners Thrown Out CATCHER
RTO = zeros(length(RV),1);
for i = 1:length(RV)
    ind = Rat(:,28) == RV(i); %Catcher Arm
    RTO(i) = sum(Stat(ind,40)); %RTO
    SBAttempt(i) = sum(Stat(ind,39));
end
RTOPct = RTO./SBAttempt;
valid = ~isnan(SBPct) & SBAttempt > 0;
figure;
scatter(RV(valid),RTOPct(valid))
xlabel('Catcher Arm')
ylabel('RTO%')
title('RTO% vs Catcher Arm Rating')

RTOFit1ste = lscov(xvec(valid,:),RTOPct(valid),SBAttempt(valid));
RTOFit2ste = lscov(xvec(valid,:),RTOPct(valid),ones(sum(valid),1));
hold on;
plot(RV,RTOFit1ste(2)+RV*RTOFit1ste(1));
plot(RV,RTOFit2ste(2)+RV*RTOFit2ste(1));
legend('Data','WeightFit','RegFit','Location','NorthWest')
hold off;

BatEqnStorage(22,:) = RTOFit1ste;

xlswrite('BattingParams.xlsx',BatEqnStorage);
