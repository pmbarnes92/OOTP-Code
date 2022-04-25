function PitchOut = HoldCalc (PitchOut, Range, HoldRat, PStat, RV, xvec, iPlot)
  
OutsTot = mod(PStat(:,2),1)*10 + floor(PStat(:,2))*3;%Convert IP to Outs  
  
%% Stolen Base Attempts
SBAttempt = zeros(length(RV),1);
Outs = SBAttempt;
for i = 1:length(RV)
    ind = HoldRat == RV(i); %Hold Rating
    SBAttempt(i) = sum(sum(PStat(ind,20:21)));
    Outs(i) = sum(OutsTot(ind)); %Outs Pitched
end
SBrate = SBAttempt./Outs;
valid = ~isnan(SBrate) & SBAttempt > 0;
SBFitHold1 = lscov(xvec(valid,:),SBrate(valid),Outs(valid));
SBFitHold2 = lscov(xvec(valid,:),SBrate(valid),ones(sum(valid),1));
PitchOut(Range(1),:) = SBFitHold1.';

if (iPlot)
  figure;
  scatter(RV(valid),SBrate(valid))
  xlabel('Hold Rating')
  ylabel('SB Attempt Rate')
  title('SB Attempt Rate vs Pitcher Hold Rating')
  hold on;
  plot(RV,SBFitHold1(2)+RV*SBFitHold1(1));
  plot(RV,SBFitHold2(2)+RV*SBFitHold2(1));
  legend('Data','WeightFit','RegLogFit','Location','NorthWest')
  hold off;
endif


%% Runners Thrown Out
RTO = zeros(length(RV),1);
for i = 1:length(RV)
    ind = HoldRat == RV(i); %Hold Rating
    RTO(i) = sum(PStat(ind,21)); %RTO
    SBAttempt(i) = sum(sum(PStat(ind,20:21))); %SB Attempts
end
RTOPct = RTO./SBAttempt;
valid = ~isnan(RTOPct) & SBAttempt > 0;
RTOFit1ste = lscov(xvec(valid,:),RTOPct(valid),SBAttempt(valid));
RTOFit2ste = lscov(xvec(valid,:),RTOPct(valid),ones(sum(valid),1));
PitchOut(Range(2),:) = RTOFit1ste.';

if (iPlot)
  figure;
  scatter(RV(valid),RTOPct(valid))
  xlabel('Hold Rating')
  ylabel('RTO%')
  title('RTO% vs Pitcher Hold Rating')
  hold on;
  plot(RV,RTOFit1ste(2)+RV*RTOFit1ste(1));
  plot(RV,RTOFit2ste(2)+RV*RTOFit2ste(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
  hold off;
endif

endfunction
