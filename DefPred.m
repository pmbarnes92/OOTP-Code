function [DefOut CatchOut] = DefPred (Rat, Def, BatEqns, h, OBADataYear, IP, CatchIP, tabnamesD, AvgRatings, indices, outfolder, iruncatch, RowHead)

DefOut = zeros(size(Rat,1),length(indices)); %Overall Run Output
CatchOut = zeros(size(Rat,1),1); %Output for catcher calcs (not used for pitcher)
DefOutcounter = 1;
for i = indices
  if (i < 6) %infield
    
    runval = OBADataYear(6)/OBADataYear(3); %Value of a single
    
    if (i == 2) %First Base
      PosOut = zeros(size(Rat,1),6);
      PosOut(:,6) = Def(i).Fits(14,1)*IP*3*runval*(h-AvgRatings(i,5)); %height
    else
      PosOut = zeros(size(Rat,1),4);
    endif
   
    PosOut(:,2) = sum(Def(i).Fits(1:5,1))*IP*3*runval*(Rat(:,1)-AvgRatings(i,1)); %Range
    PosOut(:,3) = sum(Def(i).Fits(6:10,1))*IP*3*runval*(Rat(:,2)-(Def(i).Fits(11,1)*Rat(:,1)+Def(i).Fits(11,2))); %Subtract fitted Arm rating at each range value
    
    DPRV = (.489-.095+.214)/2; %From Run Value Expectancy Matrix (Matches Batter Calcs)
    PosOut(:,4) = Def(i).Fits(12,1)*IP*3*DPRV*(Rat(:,3)-AvgRatings(i,3)); %Double Play
    
    PosOut(:,5) = Def(i).Fits(13,1)*IP*3*runval*(Rat(:,4)-AvgRatings(i,4)); %Error  
    
    PosOut(:,1) = sum(PosOut(:,2:end),2);
    if (i > 1) %Don't print if pitcher
      ColHead = {'Pos','Name','Bats','Overall','Range','Arm','DP','Error','Height'};
      NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), tabnamesD{i}, PosOut, ColHead, RowHead);
    endif
  else %Outfield
    
    PosOut = zeros(size(Rat,1),4);
    
    SinglePct = .73; %Hardcode these values for now
    DoublePct = .25;
    TriplePct = .02;
    runval = (OBADataYear(6)*SinglePct + OBADataYear(7)*DoublePct + OBADataYear(8)*TriplePct)/OBADataYear(3);
    
    PosOut(:,2) = sum(Def(i).Fits(1:5,1))*IP*3*runval*(Rat(:,5)-AvgRatings(i,1)); %Range
    
    AssistRV = 1.26; %Use assist at home to determine run value to incorporate benefit of deterring running
    PosOut(:,3) = Def(i).Fits(6,1)*IP*3*AssistRV*(Rat(:,6)-AvgRatings(i,2)); %Arm
    
    PosOut(:,4) = Def(i).Fits(7,1)*IP*3*runval*(Rat(:,7)-AvgRatings(i,3)); %Error
    
    PosOut(:,1) = sum(PosOut(:,2:end),2);

    ColHead = {'Pos','Name','Bats','Overall','Range','Arm','Error'};
    NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), tabnamesD{i}, PosOut, ColHead, RowHead);
    
  endif
  DefOut(:,DefOutcounter) = PosOut(:,1); %Store Overall Rating
  DefOutcounter = DefOutcounter + 1;
endfor

%CatcherCalcs
if (iruncatch)
CatchOuts = 3*CatchIP;
Catchinds = [9,8,8];
CatchCalc = zeros(size(Rat,1),length(Catchinds));
for i = 1:length(Catchinds)
  Acatch = [Rat(:,Catchinds(i)), ones(size(Rat,1),1)];
  xcatch = BatEqns(i,:).';
  CatchCalc(:,i) = Acatch*xcatch;
endfor
CERAnom = [55,1]*(BatEqns(1,:).');
CatchOut = (CERAnom-CatchCalc(:,1))*CatchOuts; %CERA runs saved

SBA = CatchCalc(:,2)*CatchOuts;
wRTO = -1*(OBADataYear(11)*CatchCalc(:,3).*SBA + OBADataYear(10)*(1-CatchCalc(:,3)).*SBA); %Runs from throwing runners out

CatchOut = CatchOut + wRTO;

CatchPrint = [CatchOut, (CERAnom-CatchCalc(:,1))*CatchOuts, wRTO];

ColHead = {'Pos','Name','Bats','Overall','CatcherAbility','Catcher Arm'};
NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), 'Catcher', CatchPrint, ColHead, RowHead);
  
endif

endfunction