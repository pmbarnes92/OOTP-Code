function [Fits, AvgRatings] = InfieldFits (Data, H1B,  RV, xvec, Pos, iPlot, OutfileLoc, OutfileName, Sheet)

Outs = mod(Data(:,31),1)*10 + floor(Data(:,31))*3;%Convert IP to Outs
Playtype = {'Routine','Likely','Even','Unlikely','Remote'};

AvgRatings = zeros(1,5);
AvgRatings(1:4) = sum(Data(:,3:6).*(Outs*ones(1,4)))/sum(Outs); %Range, error, arm , DP

%REMOVE THIS SECTION ON 1B HEIGHT FOR NOW. CAN"T MAKE A GOOD FIT
%if (strcmp(Pos, '1B'))
 % Fitsorig = zeros(6,2); %Store Fits and average plays per out
  %AvgRatings(5) = sum(H1B.*Outs)/sum(Outs); %Make sure to remove " cm" from excel height column
%else
  Fitsorig = zeros(5,2);
%endif

%Arm Calculations (RUNNING BEFORE RANGE EVEN THOUGH RANGE IS STORED FIRST)
BIZChancesstart = zeros(length(RV),1);
col1 = 36:3:48;
col2 = col1-1;
for i = 1:length(RV)
  ind = Data(:,3) == RV(i); %Infield Range
  for j = 1:5
      BIZChancesstart(i) = BIZChancesstart(i) + sum(Data(ind,col2(j))); %Calculate BIZ Chances for choosing arm fit. Range fit happens later.
    endfor
end

[maxval maxind] = max(BIZChancesstart); %Find range rating with most data
ind = Data(:,3) == RV(maxind); %Range ind
BIZmadepOut2 = zeros(length(RV),1);
BIZChances2 = BIZmadepOut2;
for k = 1:length(RV)
  ind2 = Data(:,5) == RV(k); %Arm Rating
  combind = ind & ind2; %Range and Arm combined index
  for j = 1:5
      PlayspOut = sum(Data(:,col2(j)))/sum(Outs); 
      if (j == 1)
        PlaysMade = sum(Data(combind,col1(j))) + sum(Data(combind,24)); %Don't include errors in fit (Add back to routine balls).
      else
        PlaysMade = sum(Data(combind,col1(j))); %Non Routine Balls do a straight fit
      endif
      BIZmadepOut2(k) = BIZmadepOut2(k) + PlayspOut*PlaysMade/sum(Data(combind,col2(j))); %Plays Made
      BIZChances2(k) = BIZChances2(k) + sum(Data(combind,col2(j))); %Play Chances for weighting fit
    endfor
end
valid = ~isnan(BIZmadepOut2);
BIZFit1Arm = lscov(xvec(valid,:),BIZmadepOut2(valid),BIZChances2(valid));
BIZFit2Arm = lscov(xvec(valid,:),BIZmadepOut2(valid),ones(sum(valid),1));
Fitsorig(2,:) = BIZFit1Arm.';

if (iPlot(2))
  figure;
  scatter(RV,BIZmadepOut2)
  xlabel('Infield Arm Rating')
  ylabel('Total Plays Made Per Out')
  title([Pos, ': Total Plays Made Per Out vs Arm at Range Rating of ' num2str(RV(maxind))])
  hold on;
  plot(RV,BIZFit1Arm(2)+RV.*BIZFit1Arm(1));
  plot(RV,BIZFit2Arm(2)+RV.*BIZFit2Arm(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%% BIZ Range Analysis (Use Arm Calc)
[maxvalR maxindR] = max(BIZChances2); %Find arm rating with most data
indA = Data(:,5) == RV(maxindR); %Arm ind
BIZmadepOut = zeros(length(RV),1);
BIZChances = BIZmadepOut;
Arm = zeros(length(RV),1);
Denominator = Arm;
col1 = 36:3:48;
col2 = col1-1;
for i = 1:length(RV)
  ind1 = Data(:,3) == RV(i); %Infield Range
  ind = ind1 & indA; %Arm rating and Range Rating
  for j = 1:5
      PlayspOut = sum(Data(:,col2(j)))/sum(Outs); 
      if (j == 1)
        PlaysMade = sum(Data(ind,col1(j))) + sum(Data(ind,24)); %Don't include errors in fit (Add back to routine balls).
      else
        PlaysMade = sum(Data(ind,col1(j))); %Non Routine Balls do a straight fit
      endif
      BIZmadepOut(i) = BIZmadepOut(i) + PlayspOut*PlaysMade/sum(Data(ind,col2(j))); %Plays Made
      BIZChances(i) = BIZChances(i) + sum(Data(ind,col2(j))); %Play Chances for weighting fit
    endfor
end
valid = ~isnan(BIZmadepOut);
BIZFit1 = lscov(xvec(valid,:),BIZmadepOut(valid),BIZChances(valid));
BIZFit2 = lscov(xvec(valid,:),BIZmadepOut(valid),ones(sum(valid),1));
Fitsorig(1,:) = BIZFit1.';

if (iPlot(1))
  figure;
  scatter(RV,BIZmadepOut)
  xlabel('Infield Range Rating')
  ylabel('Total Plays Made Per Out')
  title([Pos, ': Total Plays made per Out vs Range at Arm Rating of ' num2str(RV(maxindR))])
  hold on;
  plot(RV,BIZFit1(2)+RV.*BIZFit1(1));
  plot(RV,BIZFit2(2)+RV.*BIZFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif



%%Range vs Arm Fit to use for including Arm in ratings
Arm = zeros(length(RV),1);
Denominator = Arm;
for i = 1:length(RV)
    ind = Data(:,3) == RV(i); %Infield Range
    Arm(i) = sum(Data(ind,5).*Outs(ind)); %Weighted Arm Value
    Denominator(i) = sum(Outs(ind)); %Total Outs
end
AvgArm = Arm./Denominator; %Avg Arm value at each range value
valid = ~isnan(AvgArm);
RAFit1 = lscov(xvec(valid,:),AvgArm(valid),Denominator(valid));
RAFit2 = lscov(xvec(valid,:),AvgArm(valid),ones(sum(valid),1));
Fitsorig(3,:) = RAFit1.';

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
    ind = Data(:,6) == RV(i);
    DP(i) = sum(Data(ind,25)); %Double Plays
    TCdp(i) = sum(Outs(ind)); %sum(Data(ind,21)); %Switch to Outs instead of Total Chances
    %BIZPlays = sum(sum(Data(ind,36:3:48)));
    %TCdp(i) = sum(Data(ind,23))-(BIZPlays - (sum(Data(ind,22)) - sum(Data(ind,25)))); %Double Play Chances (PO - (BIZPlays - (A - DPmade)))
end
DPpTC = DP./TCdp;
valid = ~isnan(DPpTC);
DPFit1 = lscov(xvec(valid,:),DPpTC(valid),TCdp(valid));
DPFit2 = lscov(xvec(valid,:),DPpTC(valid),ones(sum(valid),1));
Fitsorig(4,:) = DPFit1.';

if (iPlot(4))
  figure;
  scatter(RV,DPpTC)
  xlabel('Infield Double Play Rating')
  ylabel('Double Play per Out Played')
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
    E(i) = sum(Data(ind,24)); %Errors
    TCe(i) = sum(Data(ind,21)); %Total Chances
end
EpTC = E./TCe;
valid = ~isnan(EpTC);
EFit1 = lscov(xvec(valid,:),EpTC(valid),TCe(valid));
EFit2 = lscov(xvec(valid,:),EpTC(valid),ones(sum(valid),1));
Fitsorig(5,:) = EFit1.';

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


%%Adjustments to Fits
Fits = Fitsorig;

%NOTE Make Double Play fits all 0 since I can't get any meaningful correlation
Fits(4,:) = [0,0]; %Fitsorig(4,:)*(sum(Data(:,21)))/sum(Outs); %Total chances 
Fits(Fits(:,1) < 0,1) = 0; %Make sure no fits provide negative results

Fits(3,:) = Fitsorig(3,:); %Range vs Arm fit can be negative so reset
Fits(5,:) = Fitsorig(5,:)*(sum(Data(:,21)))/sum(Outs); %Total chances per out Avg
Fits(5,1) = min(0,Fits(5,1)); %Error fit must be negative

if (strcmp(Pos, 'P')) 
  Fits(2,:) = [0,0]; %Set Pitcher Arm fit to 0 (ignore it)
endif


%First Base Height Fit
if(strcmp(Pos, '1B'))
##  heights = unique(H1B); %Find unique heights in order
##  xvec2 = [heights, ones(length(heights),1)];
##  PO = zeros(length(heights),1);
##  BIZ = PO;
##  BIZR1 = [36:3:48];
##  BIZR2 = [35:3:47, 49];
##  for i = 1:length(heights)
##      ind = H1B == heights(i);
##      PO(i) = sum(Data(ind,23))-sum(sum(Data(ind,BIZR1))); %PO - plays made by first baseman (aka plays he caught at 1B)
##      BIZ(i) = sum(Outs(ind)); %BIZ(i) = sum(sum(Data(ind,BIZR2))); %Balls hit at first baseman (Some idea of number of ground balls on this team)
##  end
##  POpBIZ = PO./BIZ;
##  valid = ~isnan(POpBIZ);
##  POFit1 = lscov(xvec2(valid,:),POpBIZ(valid),BIZ(valid));
##  POFit2 = lscov(xvec2(valid,:),POpBIZ(valid),ones(sum(valid),1));
##  Fitsorig(6,:) = POFit1.';
##
##  if (iPlot(6))
##    figure;
##    scatter(heights,POpBIZ)
##    xlabel('Height')
##    ylabel('Put Outs minus plays by First Baseman per BIZ')
##    title([Pos, ': POs vs Height'])
##    hold on;
##    plot(heights,POFit1(2)+heights.*POFit1(1));
##    plot(heights,POFit2(2)+heights.*POFit2(1));
##    legend('Stat','WeightFit','RegFit','Location','NorthWest')
##  endif
##
##  
## Fits(6,:) = Fitsorig(6,:)*(sum(sum(Data(:,BIZR2))))/sum(Outs); %Balls In Play per Out
## Fits(6,1) = max(0,Fits(6,1)); %Height fit must be positive
  
  Fits(4,:) = [0,0]; %SET DOUBLE PLAY FIT TO 0 FOR FIRST BASE
  Fits(2,:) = [0,0]; %SET 1B ARM FIT TO 0 FOR FIRST BASE

endif

xlswrite(fullfile(OutfileLoc, OutfileName), Fits,Sheet); %Write Results to excel file

endfunction
