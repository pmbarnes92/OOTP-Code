function [Fitsorig, AvgRatings] = CatcherCalcs (Data, RV, xvec, Pos, iPlot, OutfileLoc, OutfileName, Sheet)
  
Fitsorig = zeros(5,2); %Store Fits and average plays per out
Outs = mod(Data(:,31),1)*10 + floor(Data(:,31))*3;%Convert IP to Outs

AvgRatings = zeros(1,5);
AvgRatings(1:2) = sum(Data(:,1:2).*(Outs*ones(1,2)))/sum(Outs);

%% Cera
##Runs = zeros(length(RV),1);
##OutsT = Runs;
##j = 1;
##CERAFit = zeros(1,2);
##for i = 1:length(RV)
##    ind = (Data(:,1) == RV(i)); %Catcher Ability
##    Runs(i) = sum(Data(ind,33)); %Runs by Catcher
##    OutsT(i) = sum(Outs(ind)); %Outs
##end
##CERA = Runs./OutsT;
##valid = ~isnan(CERA);
##CERAFit(j,:) = lscov(xvec(valid,:),CERA(valid),OutsT(valid));
##Fitsorig(1,:) = CERAFit.';
##
##if (iPlot)
##  figure;
##  scatter(RV,CERA)
##  xlabel('Catcher Position Rating')
##  ylabel('CERA')
##  title(['C: CERA (ERpO) vs Catcher Ability Rating'])
##  hold on;
##  plot(RV,CERAFit(j,2)+RV.*CERAFit(j,1));
##  legend('Data','WeightFit','Location','NorthWest')
##  hold off;
##endif

%Catcher Framing
CatFram = zeros(length(RV),1);
OutsT = CatFram;
for i = 1:length(RV)
    ind = (Data(:,1) == RV(i)); %Catcher Ability
    CatFram(i) = sum(Data(ind,50)); %Catcher Framing Runs
    OutsT(i) = sum(Outs(ind)); %Outs
end
FramepOut = CatFram./OutsT;
valid = ~isnan(FramepOut);
FrameFit = lscov(xvec(valid,:),FramepOut(valid),OutsT(valid));
Fitsorig(1,:) = FrameFit.';

if (iPlot)
  figure;
  scatter(RV,FramepOut)
  xlabel('Catcher Ability Rating')
  ylabel('Catcher Framing Runs per Out')
  title(['C: Catcher Framing vs Catcher Ability Rating'])
  hold on;
  plot(RV,FrameFit(2)+RV.*FrameFit(1));
  legend('Data','WeightFit','Location','NorthWest')
  hold off;
endif

%Passed Ball
PB = zeros(length(RV),1);
OutsT = PB;
for i = 1:length(RV)
    ind = (Data(:,1) == RV(i)); %Catcher Ability
    PB(i) = sum(Data(ind,32)); %Catcher Framing Runs
    OutsT(i) = sum(Outs(ind)); %Outs
end
PBpO = PB./OutsT;
valid = ~isnan(PBpO);
PBFit = lscov(xvec(valid,:),PBpO(valid),OutsT(valid));
Fitsorig(4,:) = PBFit.'; %Store in slot 4 to keep stolen basees in same spot

if (iPlot)
  figure;
  scatter(RV,PBpO)
  xlabel('Catcher Ability Rating')
  ylabel('Catcher Passed Balls per Out')
  title(['C: Catcher PB per Out vs Catcher Ability Rating'])
  hold on;
  plot(RV,PBFit(2)+RV.*PBFit(1));
  legend('Data','WeightFit','Location','NorthWest')
  hold off;
endif

%Error
E = zeros(length(RV),1);
OutsT = E;
for i = 1:length(RV)
    ind = (Data(:,1) == RV(i)); %Catcher Ability
    E(i) = sum(Data(ind,24)); %Catcher Framing Runs
    OutsT(i) = sum(Outs(ind)); %Outs
end
EpO = E./OutsT;
valid = ~isnan(EpO);
EFit = lscov(xvec(valid,:),EpO(valid),OutsT(valid));
Fitsorig(5,:) = EFit.'; %Store in slot 5 to keep stolen basees in same spot

if (iPlot)
  figure;
  scatter(RV,EpO)
  xlabel('Catcher Ability Rating')
  ylabel('Catcher Errors per Out')
  title(['C: Catcher Error per Out vs Catcher Ability Rating'])
  hold on;
  plot(RV,EFit(2)+RV.*EFit(1));
  legend('Data','WeightFit','Location','NorthWest')
  hold off;
endif


%% Stolen Base Attempts
SBAttempt = zeros(length(RV),1);
for i = 1:length(RV)
    ind = Data(:,2) == RV(i); %Catcher Arm
    SBAttempt(i) = sum(Data(ind,29));
    OutsT(i) = sum(Outs(ind)); %IP
end
SBrate = SBAttempt./OutsT;
valid = ~isnan(SBrate) & SBAttempt > 0;
SBFitArm1 = lscov(xvec(valid,:),SBrate(valid),SBAttempt(valid));
SBFitArm2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
Fitsorig(2,:) = SBFitArm1.';

if (iPlot)
  figure;
  scatter(RV(valid),SBrate(valid))
  xlabel('Arm Rating')
  ylabel('SB Attempt Rate')
  title('SB Attempt Rate vs Catcher Arm Rating')
  hold on;
  plot(RV,SBFitArm1(2)+RV*SBFitArm1(1));
  plot(RV,SBFitArm2(2)+RV*SBFitArm2(1));
  legend('Data','WeightFit','RegLogFit','Location','NorthWest')
  hold off;
endif


%% Runners Thrown Out
RTO = zeros(length(RV),1);
for i = 1:length(RV)
    ind = Data(:,2) == RV(i); %Catcher Arm
    RTO(i) = sum(Data(ind,30)); %RTO
    SBAttempt(i) = sum(Data(ind,29));
end
RTOPct = RTO./SBAttempt;
valid = ~isnan(RTOPct) & SBAttempt > 0;
RTOFit1ste = lscov(xvec(valid,:),RTOPct(valid),SBAttempt(valid));
RTOFit2ste = lscov(xvec(valid,:),RTOPct(valid),ones(sum(valid),1));
Fitsorig(3,:) = RTOFit1ste.';

if (iPlot)
  figure;
  scatter(RV(valid),RTOPct(valid))
  xlabel('Catcher Arm')
  ylabel('RTO%')
  title('RTO% vs Catcher Arm Rating')
  hold on;
  plot(RV,RTOFit1ste(2)+RV*RTOFit1ste(1));
  plot(RV,RTOFit2ste(2)+RV*RTOFit2ste(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
  hold off;
endif

xlswrite(fullfile(OutfileLoc, OutfileName), Fitsorig,Sheet); %Write Results to excel file

endfunction
