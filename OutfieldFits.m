%% Fits shown in graphs are multiplied by chances per out played to be used for evaluating players later
function [Fits, AvgRatings] = OutfieldFits(Data, RV, xvec, Pos, iPlot, OutfileLoc, OutfileName, Sheet)

Fitsorig = zeros(3,2); %Store Fits and average plays per out
Outs = mod(Data(:,31),1)*10 + floor(Data(:,31))*3;%Convert IP to Outs
Playtype = {'Routine','Likely','Even','Unlikely','Remote'};

AvgRatings = zeros(1,5);
AvgRatings(1:3) = sum(Data(:,7:9).*(Outs*ones(1,3)))/sum(Outs);

%% BIZ Analysis
BIZmadepOut = zeros(length(RV),1);
BIZChances = BIZmadepOut; %Used to weight fit
col1 = 36:3:48;
col2 = col1-1;
for i = 1:length(RV)
    ind = Data(:,7) == RV(i);
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
  xlabel('Outfield Range Rating')
  ylabel('Total Plays Made Per Out')
  title([Pos, ': Total Plays made per Out vs Range'])
  hold on;
  plot(RV,BIZFit1(2)+RV.*BIZFit1(1));
  plot(RV,BIZFit2(2)+RV.*BIZFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif


##
##
##%% Total Chances
##TC = zeros(length(RV),1);
##OP = TC;
##for i = 1:length(RV)
##    ind = Data(:,5) == RV(i);
##    TC(i) = sum(Data(ind,12))-sum(Data(ind,13)); %Total Chances - Assist
##    OP(i) = sum(Outs(ind)); %Outs Played
##end
##TCpO = TC./OP;
##valid = ~isnan(TCpO);
##TCFit1 = lscov(xvec(valid,:),TCpO(valid),OP(valid));
##TCFit2 = lscov(xvec(valid,:),TCpO(valid),ones(sum(valid),1));
##Fitsorig(1,:) = TCFit1.';
##
##if (iPlot(1))
##  figure;
##  scatter(RV,TCpO)
##  xlabel('Outfield Range Rating')
##  ylabel('TC per Outs Played')
##  title([Pos, ': TC per Out vs Range'])
##  hold on;
##  plot(RV,TCFit1(2)+RV.*TCFit1(1));
##  plot(RV,TCFit2(2)+RV.*TCFit2(1));
##  legend('Stat','WeightFit','RegFit','Location','NorthWest')
##endif

%% Assist Fit
A = zeros(length(RV),1);
TCa = A;
for i = 1:length(RV)
    ind = Data(:,9) == RV(i);
    A(i) = sum(Data(ind,22)); %Assists
    TCa(i) = sum(Data(ind,21))-sum(Data(ind,22)); %Total Chances - Asssist
end
ApTC = A./TCa;
valid = ~isnan(ApTC);
AFit1 = lscov(xvec(valid,:),ApTC(valid),TCa(valid));
AFit2 = lscov(xvec(valid,:),ApTC(valid),ones(sum(valid),1));
Fitsorig(2,:) = AFit1.';

if (iPlot(2))
  figure;
  scatter(RV,ApTC)
  xlabel('Outfield Arm Rating')
  ylabel('Assist per Total Chance')
  title([Pos, ': Assist per TC vs Arm'])
  hold on;
  plot(RV,AFit1(2)+RV.*AFit1(1));
  plot(RV,AFit2(2)+RV.*AFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%% Arm Runs Stat Fit (New to ootp23)
##Arm = zeros(length(RV),1);
##TCa = Arm;
##for i = 1:length(RV)
##    ind = Data(:,9) == RV(i);
##    Arm(i) = sum(Data(ind,51)); %Arm Runs
##    TCa(i) = sum(Data(ind,21))-sum(Data(ind,22)); %Total Chances - Asssist
##end
##ApTC = Arm./TCa;
##valid = ~isnan(ApTC);
##AFit1 = lscov(xvec(valid,:),ApTC(valid),TCa(valid));
##AFit2 = lscov(xvec(valid,:),ApTC(valid),ones(sum(valid),1));
##Fitsorig(2,:) = AFit1.';
##
##if (iPlot(2))
##  figure;
##  scatter(RV,ApTC)
##  xlabel('Outfield Arm Rating')
##  ylabel('Arm Runs per Total Chance')
##  title([Pos, ': Arm Runs per TC vs Arm'])
##  hold on;
##  plot(RV,AFit1(2)+RV.*AFit1(1));
##  plot(RV,AFit2(2)+RV.*AFit2(1));
##  legend('Stat','WeightFit','RegFit','Location','NorthWest')
##endif

%% Error Fit
E = zeros(length(RV),1);
TCe = E;
for i = 1:length(RV)
    ind = Data(:,8) == RV(i);
    E(i) = sum(Data(ind,24)); %Errors
    TCe(i) = sum(Data(ind,21))-sum(Data(ind,22)); %Total Chances - Asssist
end
EpTC = E./TCe;
valid = ~isnan(EpTC);
EFit1 = lscov(xvec(valid,:),EpTC(valid),TCe(valid));
EFit2 = lscov(xvec(valid,:),EpTC(valid),ones(sum(valid),1));
Fitsorig(3,:) = EFit1.';

if (iPlot(3))
  figure;
  scatter(RV,EpTC)
  xlabel('Outfield Error Rating')
  ylabel('Error per Total Chance')
  title([Pos, ': Error per TC vs Error'])
  hold on;
  plot(RV,EFit1(2)+RV.*EFit1(1));
  plot(RV,EFit2(2)+RV.*EFit2(1));
  legend('Stat','WeightFit','RegFit','Location','NorthWest')
endif

%Scale fits based on plays in zone per out played.
Fits = Fitsorig;
Fits(2,:) = Fitsorig(2,:)*(sum(Data(:,21))-sum(Data(:,22)))/sum(Outs); %Total chances - Assists

Fits(Fits(:,1) < 0,1) = 0; %Make sure no fits provide negative slopes

Fits(3,:) = Fitsorig(3,:)*(sum(Data(:,21))-sum(Data(:,22)))/sum(Outs); %Total chances - Assists
Fits(3,1) = min(0,Fits(3,1)); %Error fit must be negative

xlswrite(fullfile(OutfileLoc, OutfileName), Fits,Sheet); %Write Results to excel file

endfunction
