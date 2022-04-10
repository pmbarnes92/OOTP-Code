%Calculate Hitter Regressions

function Output = HitCalcs (Output, Range, Hitrats, HitStats, RV, xvec, iPlot, PlotText)

%% Contact
Hits = zeros(length(RV),1);
AB = Hits;
for i = 1:length(RV)
    ind = Hitrats(:,1) == RV(i);
    Hits(i) = sum(sum(HitStats(ind,4:7)));
    AB(i) = sum(HitStats(ind,3)); %AB
end
Avg = Hits./AB;
valid = ~isnan(Avg);
AvgFit1 = lscov(xvec(valid,:),Avg(valid),AB(valid));
AvgFit2 = lscov(xvec(valid,:),Avg(valid),ones(sum(valid),1));
Output(Range(1),:) = AvgFit1.';

if (iPlot(1))
  figure;
  scatter(RV,Avg)
  xlabel('Contact Rating')
  ylabel('Average')
  title(['Average vs Contact Rating (' PlotText ')'])
  hold on;
  plot(RV,AvgFit1(2)+RV.*AvgFit1(1));
  plot(RV,AvgFit2(2)+RV.*AvgFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%% Power (Set to index 3)
HR = zeros(length(RV),1);
AB = HR;
for i = 1:length(RV)
    ind = Hitrats(:,3) == RV(i);
    HR(i) = sum(HitStats(ind,7));
    AB(i) = sum(HitStats(ind,3)); %AB
end
HRRate = HR./AB;
valid = ~isnan(HRRate);
HRFit1 = lscov(xvec(valid,:),HRRate(valid),AB(valid));
HRFit2 = lscov(xvec(valid,:),HRRate(valid),ones(sum(valid),1));
Output(Range(3),:) = HRFit1.';

if (iPlot(2))
  figure;
  scatter(RV,HRRate)
  xlabel('Power Rating')
  ylabel('HRRate')
  title(['HRRate vs Power Rating (' PlotText ')'])
  hold on;
  plot(RV,HRFit1(2)+RV.*HRFit1(1));
  plot(RV,HRFit2(2)+RV.*HRFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% Gap Power (Set to Index 2)
Gap = zeros(length(RV),1);
AB = Gap;
for i = 1:length(RV)
    ind = Hitrats(:,2) == RV(i);
    Gap(i) = sum(sum(HitStats(ind,5:6))); %Doubles and Triples
    AB(i) = sum(HitStats(ind,3)); %AB
end
GapRate = Gap./AB;
valid = ~isnan(GapRate);
GapFit1 = lscov(xvec(valid,:),GapRate(valid),AB(valid));
GapFit2 = lscov(xvec(valid,:),GapRate(valid),ones(sum(valid),1));
Output(Range(2),:) = GapFit1.';

if (iPlot(3))
  figure;
  scatter(RV,GapRate)
  xlabel('Gap Rating')
  ylabel('GapRate')
  title(['GapRate vs Gap Rating (' PlotText ')'])
  hold on;
  plot(RV,GapFit1(2)+RV.*GapFit1(1));
  plot(RV,GapFit2(2)+RV.*GapFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% Eye Rating
BB = zeros(length(RV),1);
PA = BB;
for i = 1:length(RV)
    ind = Hitrats(:,4) == RV(i);
    BB(i) = sum(HitStats(ind,10)); 
    PA(i) = sum(HitStats(ind,2)); %PA
end
BBRate = BB./PA;
valid = ~isnan(BBRate);
BBFit1 = lscov(xvec(valid,:),BBRate(valid),PA(valid));
BBFit2 = lscov(xvec(valid,:),BBRate(valid),ones(sum(valid),1));
Output(Range(4),:) = BBFit1.';

if (iPlot(4))
  figure;
  scatter(RV,BBRate)
  xlabel('Eye Rating')
  ylabel('BBRate')
  title(['BBRate vs Eye Rating (' PlotText ')'])
  hold on;
  plot(RV,BBFit1(2)+RV.*BBFit1(1));
  plot(RV,BBFit2(2)+RV.*BBFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% K Rating
K = zeros(length(RV),1);
AB = K;
for i = 1:length(RV)
    ind = Hitrats(:,5) == RV(i);
    K(i) = sum(HitStats(ind,15));
    AB(i) = sum(HitStats(ind,3)); %AB
end
KRate = K./AB;
valid = ~isnan(KRate);
KFit1 = lscov(xvec(valid,:),KRate(valid),AB(valid));
KFit2 = lscov(xvec(valid,:),KRate(valid),ones(sum(valid),1));
Output(Range(5),:) = KFit1.';

if (iPlot(5))
  figure;
  scatter(RV,KRate)
  xlabel('Avoid K Rating')
  ylabel('KRate')
  title(['KRate vs Avoid K Rating (' PlotText ')'])
  hold on;
  plot(RV,KFit1(2)+RV.*KFit1(1));
  plot(RV,KFit2(2)+RV.*KFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthEast')
endif

endfunction
