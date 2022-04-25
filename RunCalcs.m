function [Output UBRFit ErrRun] = RunCalcs (Output, Range, RunRats, RunStats, RV, xvec, iPlot)
  
% Speed impact on double/triple split
Trip = zeros(length(RV),1);
GapTot = Trip;
for i = 1:length(RV)
    ind = RunRats(:,1) == RV(i); %Speed
    Trip(i) = sum(RunStats(ind,6));
    GapTot(i) = sum(sum(RunStats(ind,5:6)));
end
TRate = Trip./GapTot;
valid = ~isnan(TRate);
TFit1 = lscov(xvec(valid,:),TRate(valid),GapTot(valid));
TFit2 = lscov(xvec(valid,:),TRate(valid),ones(sum(valid),1));
Output(Range(1),:) = TFit1.';

if (iPlot)
  figure;
  scatter(RV,TRate)
  xlabel('Speed Rating')
  ylabel('Triple Rate')
  title('Triple Rate vs Speed Rating')
  hold on;
  plot(RV,TFit1(2)+RV.*TFit1(1));
  plot(RV,TFit2(2)+RV.*TFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% Double Plays
DP = zeros(length(RV),1);
BIP = DP;
for i = 1:length(RV)
    ind = RunRats(:,1) == RV(i); %Speed
    DP(i) = sum(RunStats(ind,16)); %GDP
    BIP(i) = sum(RunStats(ind,3))-sum(sum(RunStats(ind,4:7))) - sum(RunStats(ind,15)); %AB - H - SO
end
DPRate = DP./BIP;
valid = ~isnan(DPRate);
DPFit1 = lscov(xvec(valid,:),DPRate(valid),BIP(valid));
DPFit2 = lscov(xvec(valid,:),DPRate(valid),ones(sum(valid),1));
Output(Range(2),:) = DPFit1.';

if (iPlot)
  figure;
  scatter(RV,DPRate)
  xlabel('Speed Rating')
  ylabel('DP/BIP')
  title('DP/BIP vs Speed Rating')
  hold on;
  plot(RV,DPFit1(2)+RV.*DPFit1(1));
  plot(RV,DPFit2(2)+RV.*DPFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% Stolen Bases vs Speed
SBAttempt = zeros(length(RV),1);
TimesOB = SBAttempt;
for i = 1:length(RV)
    ind = RunRats(:,1) == RV(i); %Speed
    SBAttempt(i) = sum(sum(RunStats(ind,19:20)));
    TimesOB(i) = sum(sum(RunStats(ind,[4,10:12]))); %Times on first
end
SBrate = SBAttempt./TimesOB;
valid = ~isnan(SBrate);
SBFit1 = lscov(xvec(valid,:),SBrate(valid),TimesOB(valid));
SBFit2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
%valid = ~isnan(log(SBrate)) & ~isinf(log(SBrate));
%SBFit1 = lscov(xvec(valid,:),log(SBrate(valid)),ones(sum(valid),1));
Output(Range(3),:) = SBFit1.';

if (iPlot)
  figure;
  scatter(RV,SBrate)
  xlabel('Speed Rating')
  ylabel('SB Attempt Rate')
  title('SB Attempt Rate vs Speed Rating')
  hold on;
  %plot(RV,exp(SBFit1(2)+RV*SBFit1(1)));
  plot(RV,SBFit1(2)+RV*SBFit1(1));
  plot(RV,SBFit2(2)+RV*SBFit2(1));
  legend('Data','WeightFit','RegLogFit','Location','NorthWest')
  hold off;
endif

%% Stolen Base Success Rate
SB = zeros(length(RV),1);
for i = 1:length(RV)
    ind = RunRats(:,2) == RV(i); %STE
    SB(i) = sum(RunStats(ind,19));
    SBAttempt(i) = sum(sum(RunStats(ind,19:20))); %Sb Attempts
end
SBPct = SB./SBAttempt;
valid = ~isnan(SBPct);
SBFit1ste = lscov(xvec(valid,:),SBPct(valid),SBAttempt(valid));
SBFit2ste = lscov(xvec(valid,:),SBPct(valid),ones(sum(valid),1));
Output(Range(4),:) = SBFit1ste.';

if(iPlot)
  figure;
  scatter(RV,SBPct)
  xlabel('Steal Rating')
  ylabel('SB%')
  title('SB% vs Steal Rating')
  hold on;
  plot(RV,SBFit1ste(2)+RV*SBFit1ste(1));
  plot(RV,SBFit2ste(2)+RV*SBFit2ste(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
  hold off;
endif

% UBR Fit
val2B = (1.068+.644+.305-.831 - .489 - .214)/3; %Value of a double versus a single (from run state matrix)
val3B = (1.426+.865+.413-.831-.489-.214)/3; %Value of a triple versus a single (from run state matrix)
valSB = 0.2;
TimesOB = sum(RunStats(:,[4:6, 10:12]),2) - RunStats(:,20); %1B,2B,3B,BB,HBP,IBB,-CS
iOB = TimesOB > 0.25*max(TimesOB); %Limit players
Runs = RunStats(iOB,9) - RunStats(iOB, 7) - val2B*RunStats(iOB, 5) - val3B*RunStats(iOB,6) - valSB*RunStats(iOB,19); %Runs-HR-runvalues of 2B,3B,SB
RpOB = Runs./TimesOB(iOB);

RatMat = [RunRats(iOB,[1, 3]), ones(sum(iOB),1)];

UBRFit = lscov(RatMat, RpOB, TimesOB(iOB));

MSERun = sum((((RatMat*UBRFit-RpOB).*TimesOB(iOB))/mean(TimesOB(iOB))).^2)/length(RpOB);
Variance = sum((((RpOB-mean(RpOB)).*TimesOB(iOB))/mean(TimesOB(iOB))).^2)/length(RpOB);
ErrRun = 1-MSERun/Variance;

endfunction
