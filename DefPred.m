function [DefOut] = DefPred (Rat, Def, h, OBADataYear, IP, CatchIP, tabnamesD, AvgRatings, indices, outfolder, iruncatch, RowHead)

DefOut = zeros(size(Rat,1),length(indices)); %Overall Run Output
CatchOut = zeros(size(Rat,1),1); %Output for catcher calcs (not used for pitcher)
DefOutcounter = 1;
for i = indices
  if (i == 1) %Catcher
    CatchOuts = 3*CatchIP;
    Catchinds = [1,2,2,1,1]; %Framing, SBAtt, RTO%, PB, E
    CatchCalc = zeros(size(Rat,1),length(Catchinds));
    for j = 1:length(Catchinds)
      Acatch = [Rat(:,Catchinds(j)), ones(size(Rat,1),1)];
      xcatch = Def(i).Fits(j,:).';
      CatchCalc(:,j) = Acatch*xcatch;
    endfor
    
    NomCalc = zeros(1,length(Catchinds));
    for k = 1:length(Catchinds)
      Acatch2 = [AvgRatings(i,Catchinds(k)), 1];
      xcatch2 = Def(i).Fits(k,:).';
      NomCalc(k) = Acatch2*xcatch2;
    endfor
    
    CatchFrame = CatchCalc(:,1)*CatchOuts; %Catcher Framing Runs
    
    PBRunVal = -(3+.461+.243+.095-.831-.489-.214)/9;%from RE24 1+empty - 1B at all out levels divided by 9 (complicated to explain..rethink about it. it's about .25)
    PBRuns = (CatchCalc(:,4)-NomCalc(:,4))*CatchOuts*PBRunVal;
    
    Erunval = -OBADataYear(6)/OBADataYear(3); %Value of a single
    ERuns = (CatchCalc(:,5)-NomCalc(:,5))*CatchOuts*Erunval;
    

    SBA = CatchCalc(:,2)*CatchOuts;
    wRTO = -1*(OBADataYear(11)*CatchCalc(:,3).*SBA + OBADataYear(10)*(1-CatchCalc(:,3)).*SBA); %Runs from throwing runners out

    CatchOut = CatchFrame + wRTO + PBRuns + ERuns;

    PosOut = [CatchOut, CatchFrame, PBRuns, ERuns, wRTO]; %Got lazy and declared PosOut at the end for catchers only

    ColHead = {'Pos','Name','Bats','Overall','Framing','PBRuns','ErrorRuns','Arm Runs'};
    NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), 'Catcher', PosOut, ColHead, RowHead);

  
  elseif (i < 7) %infield
    
    runval = OBADataYear(6)/OBADataYear(3); %Value of a single
    
    %%REMOVE FIRST BASE HEIGHT FIT FOR NOW. NOT USING UNTIL I MAKE IT WORK
    %if (i == 2) %First Base
     % PosOut = zeros(size(Rat,1),6);
     % PosOut(:,6) = Def(i).Fits(14,1)*IP*3*runval*(h-AvgRatings(i,5)); %height
    %else
      PosOut = zeros(size(Rat,1),4);
    %endif
   
    %PosOut(:,2) = Def(i).Fits(1,1)*IP*3*runval*(Rat(:,3)-AvgRatings(i,1)) - Def(i).Fits(2,1)*IP*3*runval*(Def(i).Fits(3,1)*Rat(:,3)+Def(i).Fits(3,2)-AvgRatings(i,3)); %Range - Arm runs attributed to average arm rating at that range rating (ie covariance of arm and range)
    PosOut(:,2) = Def(i).Fits(1,1)*IP*3*runval*(Rat(:,3)-AvgRatings(i,1)); %Range Runs (no longer need to remove Arm, they are fit separately)
    PosOut(:,3) = Def(i).Fits(2,1)*IP*3*runval*(Rat(:,5)-AvgRatings(i,3)); %Arm Runs
    
    DPRV = (.489-.095+.214)/2; %From Run Value Expectancy Matrix (Matches Batter Calcs)
    PosOut(:,4) = Def(i).Fits(4,1)*IP*3*DPRV*(Rat(:,6)-AvgRatings(i,4)); %Double Play
    
    PosOut(:,5) = -Def(i).Fits(5,1)*IP*3*runval*(Rat(:,4)-AvgRatings(i,2)); %Error  
    
    PosOut(:,1) = sum(PosOut(:,2:end),2);
    if (i > 2) %Don't print if pitcher
      %ColHead = {'Pos','Name','Bats','Overall','Range','Arm','DP','Error','Height'};
      ColHead = {'Pos','Name','Bats','Overall','Range','Arm','DP','Error'};
      NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), tabnamesD{i}, PosOut, ColHead, RowHead);
    endif
  else %Outfield
    
    PosOut = zeros(size(Rat,1),4);
    
    SinglePct = .73; %Hardcode these values for now
    DoublePct = .25;
    TriplePct = .02;
    runval = (OBADataYear(6)*SinglePct + OBADataYear(7)*DoublePct + OBADataYear(8)*TriplePct)/OBADataYear(3);
    
    PosOut(:,2) = Def(i).Fits(1,1)*IP*3*runval*(Rat(:,7)-AvgRatings(i,1)); %Range
    
    AssistRV = 1.26; %Use assist at home to determine run value to incorporate benefit of deterring running
    PosOut(:,3) = Def(i).Fits(2,1)*IP*3*AssistRV*(Rat(:,9)-AvgRatings(i,2)); %Arm
    
    PosOut(:,4) = -Def(i).Fits(3,1)*IP*3*runval*(Rat(:,8)-AvgRatings(i,3)); %Error
    
    PosOut(:,1) = sum(PosOut(:,2:end),2);

    ColHead = {'Pos','Name','Bats','Overall','Range','Arm','Error'};
    NoOutput = WritePredOutput(fullfile(outfolder,'DefenseDetails.xlsx'), tabnamesD{i}, PosOut, ColHead, RowHead);
    
  endif
  DefOut(:,DefOutcounter) = PosOut(:,1); %Store Overall Rating
  DefOutcounter = DefOutcounter + 1;
endfor

endfunction