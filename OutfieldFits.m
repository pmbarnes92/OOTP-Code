%% Fits shown in graphs are multiplied by chances per out played to be used for evaluating players later
function [Fits, AvgRatings] = OutfieldFits(Data, RV, xvec, Pos, iPlot, OutfileLoc, OutfileName, Sheet)

Fitsorig = zeros(7,2); %Store Fits and average plays per out
Outs = mod(Data(:,20),1)*10 + floor(Data(:,20))*3;%Convert IP to Outs
Playtype = {'Routine','Likely','Even','Unlikely','Remote'};

AvgRatings = zeros(1,5);
AvgRatings(1:3) = sum(Data(:,5:7).*(Outs*ones(1,3)))/sum(Outs);

%% BIZ Analysis
for j = 1:5
  BIZmade = zeros(length(RV),1);
  BIZchances = BIZmade;
  col1 = 23 + 3*(j-1);
  col2 = col1-1;
  for i = 1:length(RV)
      ind = Data(:,5) == RV(i);
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
    xlabel('Outfield Range Rating')
    ylabel('Plays Made Percentage')
    title([Pos, ': Pct of ', Playtype{j},  ' vs Range'])
    hold on;
    plot(RV,BIZFit1(2)+RV.*BIZFit1(1));
    plot(RV,BIZFit2(2)+RV.*BIZFit2(1));
    legend('Stat','WeightFit','RegFit','Location','NorthWest')
  endif
endfor


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
    ind = Data(:,6) == RV(i);
    A(i) = sum(Data(ind,13)); %Assists
    TCa(i) = sum(Data(ind,12))-sum(Data(ind,13)); %Total Chances - Asssist
end
ApTC = A./TCa;
valid = ~isnan(ApTC);
AFit1 = lscov(xvec(valid,:),ApTC(valid),TCa(valid));
AFit2 = lscov(xvec(valid,:),ApTC(valid),ones(sum(valid),1));
Fitsorig(6,:) = AFit1.';

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

%% Error Fit
E = zeros(length(RV),1);
TCe = E;
for i = 1:length(RV)
    ind = Data(:,7) == RV(i);
    E(i) = sum(Data(ind,15)); %Errors
    TCe(i) = sum(Data(ind,12))-sum(Data(ind,13)); %Total Chances - Asssist
end
EpTC = E./TCe;
valid = ~isnan(EpTC);
EFit1 = lscov(xvec(valid,:),EpTC(valid),TCe(valid));
EFit2 = lscov(xvec(valid,:),EpTC(valid),ones(sum(valid),1));
Fitsorig(7,:) = EFit1.';

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
Fits(1,:) = Fitsorig(1,:)*sum(Data(:,22))/sum(Outs); %Routine
Fits(2,:) = Fitsorig(2,:)*sum(Data(:,25))/sum(Outs); %Likely
Fits(3,:) = Fitsorig(3,:)*sum(Data(:,28))/sum(Outs); %Even
Fits(4,:) = Fitsorig(4,:)*sum(Data(:,31))/sum(Outs); %Unlikely
Fits(5,:) = Fitsorig(5,:)*sum(Data(:,34))/sum(Outs); %Remote
Fits(6,:) = Fitsorig(6,:)*(sum(Data(:,12))-sum(Data(:,13)))/sum(Outs); %Total chances - Assists

Fits(Fits(:,1) < 0,1) = 0; %Make sure no fits provide negative slopes

Fits(7,:) = Fitsorig(7,:)*(sum(Data(:,12))-sum(Data(:,13)))/sum(Outs); %Total chances - Assists
Fits(7,1) = min(0,Fits(7,1)); %Error fit must be negative

xlswrite(fullfile(OutfileLoc, OutfileName), Fits,Sheet); %Write Results to excel file

endfunction
