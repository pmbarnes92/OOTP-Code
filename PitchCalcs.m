function PitchOut = PitchCalcs (PitchOut, Range, PRats, PStats, RV, xvec, iPlot, Split)

OutsTot = mod(PStats(:,2),1)*10 + floor(PStats(:,2))*3;%Convert IP to Outs

%% Stuff
K = zeros(length(RV),1);
Outs = K;
for i = 1:length(RV)
    ind = PRats(:,1) == RV(i); %Stuff
    K(i) = sum(PStats(ind,13)); %SO
    Outs(i) = sum(OutsTot(ind));
end
KOut = K./Outs;
valid = ~isnan(KOut);
KOutFit1 = lscov(xvec(valid,:),KOut(valid),Outs(valid));
KOutFit2 = lscov(xvec(valid,:),KOut(valid),ones(sum(valid),1));
PitchOut(Range(1),:) = KOutFit1.';

if (iPlot(1))
  figure;
  scatter(RV,KOut)
  xlabel('Stuff Rating')
  ylabel('K/Out')
  title([Split ': K/Out vs Stuff Rating'])
  hold on;
  plot(RV,KOutFit1(2)+RV.*KOutFit1(1));
  plot(RV,KOutFit2(2)+RV.*KOutFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthWest')
endif

%% Movement
HR = zeros(length(RV),1);
Outs = HR;
for i = 1:length(RV)
    ind = PRats(:,2) == RV(i); %Movement
    HR(i) = sum(PStats(ind,8));
    Outs(i) = sum(OutsTot(ind));
end
HROut = HR./Outs;
valid = ~isnan(HROut);
HROutFit1 = lscov(xvec(valid,:),HROut(valid),Outs(valid));
HROutFit2 = lscov(xvec(valid,:),HROut(valid),ones(sum(valid),1));
PitchOut(Range(2),:) = HROutFit1.';

if (iPlot(2))
  figure;
  scatter(RV,HROut)
  xlabel('Movement Rating')
  ylabel('HR/Out')
  title([Split ': HR/Out vs Movement Rating'])
  hold on;
  plot(RV,HROutFit1(2)+RV.*HROutFit1(1));
  plot(RV,HROutFit2(2)+RV.*HROutFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthEast')
endif

%% Control
BB = zeros(length(RV),1);
Outs = BB;
for i = 1:length(RV)
    ind = PRats(:,3) == RV(i); %Control
    BB(i) = sum(PStats(ind,11) + PStats(ind,14)); %include HBP
    Outs(i) = sum(OutsTot(ind));
end
BBOut = BB./Outs;
valid = ~isnan(BBOut);
BBOutFit1 = lscov(xvec(valid,:),BBOut(valid),Outs(valid));
BBOutFit2 = lscov(xvec(valid,:),BBOut(valid),ones(sum(valid),1));
PitchOut(Range(3),:) = BBOutFit1.';

if (iPlot(3))
  figure;
  scatter(RV,BBOut)
  xlabel('Control Rating')
  ylabel('BB/Out')
  title([Split, ': BB/Out vs Control Rating'])
  hold on;
  plot(RV,BBOutFit1(2)+RV.*BBOutFit1(1));
  plot(RV,BBOutFit2(2)+RV.*BBOutFit2(1));
  legend('Data','WeightFit','RegFit','Location','NorthEast')
endif

endfunction
