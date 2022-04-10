function [Fits, AvgRatings] = InfieldFits (Data, H1B,  RV, xvec, Pos, iPlot, OutfileLoc, OutfileName, Sheet)

Outs = mod(Data(:,20),1)*10 + floor(Data(:,20))*3;%Convert IP to Outs
Playtype = {'Routine','Likely','Even','Unlikely','Remote'};

AvgRatings = zeros(1,5);
AvgRatings(1:4) = sum(Data(:,1:4).*(Outs*ones(1,4)))/sum(Outs);

if (strcmp(Pos, '1B'))
  Fitsorig = zeros(14,2); %Store Fits and average plays per out
  AvgRatings(5) = sum(H1B.*Outs)/sum(Outs); %Make sure to remove " cm" from excel height column
else
  Fitsorig = zeros(13,2);
endif


%% BIZ Analysis
for j = 1:5
  BIZmade = zeros(length(RV),1);
  BIZchances = BIZmade;
  col1 = 23 + 3*(j-1);
  col2 = col1-1;
  for i = 1:length(RV)
      ind = Data(:,1) == RV(i); %Infield Range
      BIZmade(i) = sum(Data(ind,col1)); %Plays Made
      BIZchances(i) = sum(Data(ind,col2)); %Plays in zone
  end
  Rangepct = BIZmade./BIZchances;
  valid = ~isnan(Rangepct);
  BIZFit1 = lscov(xvec(valid,:),Rangepct(valid),BIZchances(valid));
  BIZFit2 = lscov(xvec(valid,:),Rangepct(valid),ones(sum(valid),1));
  Fitsorig(j,:) = BIZFit1.';
  
  if (iPlot(1))
    figure;
    scatter(RV,Rangepct)
    xlabel('Infield Range Rating')
    ylabel('Plays Made Percentage')
    title([Pos, ': Pct of ', Playtype{j},  ' vs Range'])
    hold on;
    plot(RV,BIZFit1(2)+RV.*BIZFit1(1));
    plot(RV,BIZFit2(2)+RV.*BIZFit2(1));
    legend('Stat','WeightFit','RegFit','Location','NorthWest')
  endif
  
  %Arm Calculations
  [maxval maxind] = max(BIZchances); %Find range rating with most data
  ind = Data(:,1) == RV(maxind);
  BIZmade2 = zeros(length(RV),1);
  BIZchances2 = BIZmade2;
  for k = 1:length(RV)
    ind2 = Data(:,2) == RV(k); %Arm Rating
    combind = ind & ind2; %Range and Arm combined index
    BIZmade2(k) = sum(Data(combind,col1)); %Plays Made
    BIZchances2(k) = sum(Data(combind,col2)); %Plays in zone
  endfor
  Rangepct2 = BIZmade2./BIZchances2;
  valid = ~isnan(Rangepct2);
  BIZFit1Arm = lscov(xvec(valid,:),Rangepct2(valid),BIZchances2(valid));
  BIZFit2Arm = lscov(xvec(valid,:),Rangepct2(valid),ones(sum(valid),1));
  Fitsorig(j+5,:) = BIZFit1Arm.';
  
  if (iPlot(2))
    figure;
    scatter(RV,Rangepct2)
    xlabel('Infield Arm Rating')
    ylabel('Plays Made Percentage')
    title([Pos, ': Pct of ', Playtype{j},  ' vs Arm at Range Rating of ' num2str(RV(maxind))])
    hold on;
    plot(RV,BIZFit1Arm(2)+RV.*BIZFit1Arm(1));
    plot(RV,BIZFit2Arm(2)+RV.*BIZFit2Arm(1));
    legend('Stat','WeightFit','RegFit','Location','NorthWest')
  endif
endfor

%%Range vs Arm Fit to use for including Arm in ratings
Arm = zeros(length(RV),1);
Denominator = Arm;
for i = 1:length(RV)
    ind = Data(:,1) == RV(i); %Infield Range
    Arm(i) = sum(Data(ind,2).*Outs(ind)); %Weighted Arm Value
    Denominator(i) = sum(Outs(ind)); %Total Outs
end
AvgArm = Arm./Denominator; %Avg Arm value at each range value
valid = ~isnan(AvgArm);
RAFit1 = lscov(xvec(valid,:),AvgArm(valid),Denominator(valid));
RAFit2 = lscov(xvec(valid,:),AvgArm(valid),ones(sum(valid),1));
Fitsorig(11,:) = RAFit1.';

if (iPlot(3))
  figure;
  scatter(RV,AvgArm)
  xlabel('Infield Range Rating')
  ylabel('Average Arm Rating')
  title([Pos, ': Avg Arm Value vs Range Ratings'])
  hold on;
  plot(RV,RAFit1(2)+RV.*RAFit1(1));
  plot(RV,RAFit2(2)+RV.*RAFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%%Double Play Fit
DP = zeros(length(RV),1);
TCdp = DP;
for i = 1:length(RV)
    ind = Data(:,3) == RV(i);
    DP(i) = sum(Data(ind,16)); %Double Plays
    TCdp(i) = sum(Data(ind,12)); %Total Chances
end
DPpTC = DP./TCdp;
valid = ~isnan(DPpTC);
DPFit1 = lscov(xvec(valid,:),DPpTC(valid),TCdp(valid));
DPFit2 = lscov(xvec(valid,:),DPpTC(valid),ones(sum(valid),1));
Fitsorig(12,:) = DPFit1.';

if (iPlot(4))
  figure;
  scatter(RV,DPpTC)
  xlabel('Infield Double Play Rating')
  ylabel('Double Play per Total Chance')
  title([Pos, ': Double Play per TC vs DP Rating'])
  hold on;
  plot(RV,DPFit1(2)+RV.*DPFit1(1));
  plot(RV,DPFit2(2)+RV.*DPFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%% Error Fit
E = zeros(length(RV),1);
TCe = E;
for i = 1:length(RV)
    ind = Data(:,4) == RV(i);
    E(i) = sum(Data(ind,15)); %Errors
    TCe(i) = sum(Data(ind,12)); %Total Chances
end
EpTC = E./TCe;
valid = ~isnan(EpTC);
EFit1 = lscov(xvec(valid,:),EpTC(valid),TCe(valid));
EFit2 = lscov(xvec(valid,:),EpTC(valid),ones(sum(valid),1));
Fitsorig(13,:) = EFit1.';

if (iPlot(5))
  figure;
  scatter(RV,EpTC)
  xlabel('Infield Error Rating')
  ylabel('Error per Total Chance')
  title([Pos, ': Error per TC vs Error Rating'])
  hold on;
  plot(RV,EFit1(2)+RV.*EFit1(1));
  plot(RV,EFit2(2)+RV.*EFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%Scale fits based on plays in zone per out played.
Fits = Fitsorig;
Fits(1,:) = Fitsorig(1,:)*sum(Data(:,22))/sum(Outs); %Routine
Fits(2,:) = Fitsorig(2,:)*sum(Data(:,25))/sum(Outs); %Likely
Fits(3,:) = Fitsorig(3,:)*sum(Data(:,28))/sum(Outs); %Even
Fits(4,:) = Fitsorig(4,:)*sum(Data(:,31))/sum(Outs); %Unlikely
Fits(5,:) = Fitsorig(5,:)*sum(Data(:,34))/sum(Outs); %Remote
Fits(6,:) = Fitsorig(6,:)*sum(Data(:,22))/sum(Outs); %Routine
Fits(7,:) = Fitsorig(7,:)*sum(Data(:,25))/sum(Outs); %Likely
Fits(8,:) = Fitsorig(8,:)*sum(Data(:,28))/sum(Outs); %Even
Fits(9,:) = Fitsorig(9,:)*sum(Data(:,31))/sum(Outs); %Unlikely
Fits(10,:) = Fitsorig(10,:)*sum(Data(:,34))/sum(Outs); %Remote
Fits(12,:) = Fitsorig(12,:)*(sum(Data(:,12)))/sum(Outs); %Total chances
Fits(Fits(:,1) < 0,1) = 0; %Make sure no fits provide negative results

Fits(11,:) = Fitsorig(11,:); %Range vs Arm fit can be negative so reset
Fits(13,:) = Fitsorig(13,:)*(sum(Data(:,12)))/sum(Outs); %Total chances
Fits(13,1) = min(0,Fits(13,1)); %Error fit must be negative

%First Base Height Fit
if(strcmp(Pos, '1B'))
  heights = unique(H1B); %Find unique heights in order
  xvec2 = [heights, ones(length(heights),1)];
  PO = zeros(length(heights),1);
  BIZ = PO;
  BIZR1 = [23:3:35];
  BIZR2 = [22:3:34, 36];
  for i = 1:length(heights)
      ind = H1B == heights(i);
      PO(i) = sum(Data(ind,14))-sum(sum(Data(ind,BIZR1))); %PO - plays made by first baseman (aka plays he caught at 1B)
      BIZ(i) = sum(sum(Data(ind,BIZR2))); %Balls hit at first baseman (Some idea of number of ground balls on this team)
  end
  POpBIZ = PO./BIZ;
  valid = ~isnan(POpBIZ);
  POFit1 = lscov(xvec2(valid,:),POpBIZ(valid),BIZ(valid));
  POFit2 = lscov(xvec2(valid,:),POpBIZ(valid),ones(sum(valid),1));
  Fitsorig(14,:) = POFit1.';

  if (iPlot(6))
    figure;
    scatter(heights,POpBIZ)
    xlabel('Height')
    ylabel('Put Outs minus plays by First Baseman per BIZ')
    title([Pos, ': POs vs Height'])
    hold on;
    plot(heights,POFit1(2)+heights.*POFit1(1));
    plot(heights,POFit2(2)+heights.*POFit2(1));
    legend('Stat','WeightFit','RegFit','Location','NorthWest')
  endif
  Fits(14,:) = Fitsorig(14,:)*(sum(sum(Data(:,BIZR2))))/sum(Outs); %Balls In Play per Out
  Fits(14,1) = max(0,Fits(14,1)); %Height fit must be positive

endif

xlswrite(fullfile(OutfileLoc, OutfileName), Fits,Sheet); %Write Results to excel file

endfunction
