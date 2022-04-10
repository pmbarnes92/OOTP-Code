function Output = CatcherCalcs (Output, Range, CatchRat, CatchStat, RV, xvec, iPlot)
  
Outs = mod(CatchStat(:,11),1)*10 + floor(CatchStat(:,11))*3; %Convert IP to Outs
  
%% Cera
Runs = zeros(length(RV),1);
OutsT = Runs;
j = 1;
CERAFit = zeros(1,2);
for i = 1:length(RV)
    ind = (CatchRat(:,2) == RV(i)); %Catcher Ability
    Runs(i) = sum(CatchStat(ind,13)); %Runs by Catcher
    OutsT(i) = sum(Outs(ind)); %Outs
end
CERA = Runs./OutsT;
valid = ~isnan(CERA);
CERAFit(j,:) = lscov(xvec(valid,:),CERA(valid),OutsT(valid));
Output(Range(1),:) = CERAFit.';

if (iPlot)
  figure;
  scatter(RV,CERA)
  xlabel('Catcher Position Rating')
  ylabel('CERA')
  title(['C: CERA (ERpO) vs Catcher Ability Rating'])
  hold on;
  plot(RV,CERAFit(j,2)+RV.*CERAFit(j,1));
  legend('Data','WeightFit','Location','NorthWest')
  hold off;
endif

%% Stolen Base Attempts
SBAttempt = zeros(length(RV),1);
for i = 1:length(RV)
    ind = CatchRat(:,1) == RV(i); %Catcher Arm
    SBAttempt(i) = sum(CatchStat(ind,9));
    OutsT(i) = sum(Outs(ind)); %IP
end
SBrate = SBAttempt./OutsT;
valid = ~isnan(SBrate) & SBAttempt > 0;
SBFitArm1 = lscov(xvec(valid,:),SBrate(valid),SBAttempt(valid));
SBFitArm2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
Output(Range(2),:) = SBFitArm1.';

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
    ind = CatchRat(:,1) == RV(i); %Catcher Arm
    RTO(i) = sum(CatchStat(ind,10)); %RTO
    SBAttempt(i) = sum(CatchStat(ind,9));
end
RTOPct = RTO./SBAttempt;
valid = ~isnan(RTOPct) & SBAttempt > 0;
RTOFit1ste = lscov(xvec(valid,:),RTOPct(valid),SBAttempt(valid));
RTOFit2ste = lscov(xvec(valid,:),RTOPct(valid),ones(sum(valid),1));
Output(Range(3),:) = RTOFit1ste.';

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

endfunction
