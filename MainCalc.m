%Main Batter Calcs File
%Outputs are BatEqns, DefEqns, UBRFit, PitchEqns, SBPrediction
clear all; close all;

%Variables (Plus divisor at line 18)
Teams = 30;
Games = 162;

[RatSys, Rat, txt, txtP, StatOvr, StatR, StatL, h, PitchRat, PitchOvr, PStatR, PStatL, filename, filenamed, NewRun] = CalcReadFile(); %Gather inputs from user and excel file
OutputFolder = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';
save('CalcPresets','RatSys','filename','filenamed');

%Rating Scale used for regressions
if (RatSys == 1)
  RV = (20:5:80).';
  divisor = 5; %Leave at 5 for BABIP calc to work
else
  divisor = 5;
  RV = (0:divisor:(divisor*round(130/divisor)));
  RV = (0:divisor:130).';
  Rat = divisor*round(Rat/divisor); %Adjust rankings to increments of 5
  PitchRat = divisor*round(PitchRat/divisor); %Adjust rankings to increments of 5
endif
xvec = [RV, ones(length(RV),1)];

% Text Inputs
Pos = txt(:,1);
Hand = txt(:,5);
Rind = strcmp(Hand, 'R'); %Indexes of batter handedness
Lind = strcmp(Hand, 'L');
Sind = strcmp(Hand, 'S');

Output = zeros(24,2); %BatterOutput

%%HitCalcs
iPlot = ones(4,5); %Default to not plot. Manually set values to plot below
%iPlot(:,2) = 1; %first column adjusts split, second column adjusts variable (BABIP, Pow, Gap, Eye, K)
Output = HitCalcs(Output, 1:5, Rat(Rind, 6:10), StatR(Rind, 1:15), RV, xvec, divisor, iPlot(1,:), 'RvR'); %Right (Bat) v Right (Pit)
Output = HitCalcs(Output, 6:10, Rat(Rind|Sind, 1:5), StatL(Rind|Sind, 1:15), RV, xvec, divisor, iPlot(2,:), 'RvL'); %Right (Bat) v Left (Pit)
Output = HitCalcs(Output, 11:15, Rat(Lind|Sind, 6:10), StatR(Lind|Sind, 1:15), RV, xvec, divisor, iPlot(3,:), 'LvR'); %Left (Bat) v Right (Pit)
Output = HitCalcs(Output, 16:20, Rat(Lind, 1:5), StatL(Lind, 1:15), RV, xvec, divisor, iPlot(4,:), 'LvL'); %Left (Bat) v Left (Pit)

%%RunningCalcs
iPlot = true;
[Output UBRFit ErrRun] = RunCalcs(Output, 21:24, Rat(:,32:34), StatOvr(:,1:20), RV, xvec, iPlot); %Running Output

%%Batting Output Files
xlswrite(fullfile(OutputFolder, 'BatEqns.xlsx'), Output);
xlswrite(fullfile(OutputFolder, 'UBRFit.xlsx'), UBRFit);

%Defensive Calculations (Currently need to adjust iplot within the defense subroutine)
[Def, AvgRatings] = MainDefCalc(filenamed, RV, xvec, RatSys, divisor); %Call new Defensive calc method

NoOutput = YearConstants(StatOvr, StatR, StatL, PitchOvr, PStatR, PStatL, Def, Teams, Games, OutputFolder); %Print Constants used for predictions



%% Pitcher Section
PitchOut = zeros(14,2);
HandP = txtP(:,6);
RindP = strcmp(HandP, 'R'); %Indexes of Pitcher handedness
LindP = strcmp(HandP, 'L');

%Main Pitcher Calcs
iPlot = ones(4,3);
%iPlot(:,3) = 1; %first column adjusts split, second column adjusts variable (Stuff, Movement, Control)
PitchOut = PitchCalcs(PitchOut, 1:3, PitchRat(RindP, 7:9), PStatR(RindP, 1:14), RV, xvec, iPlot(1,:), 'RvR'); %Right (Pit) v Right (Bat)
PitchOut = PitchCalcs(PitchOut, 4:6, PitchRat(RindP, 4:6), PStatL(RindP, 1:14), RV, xvec, iPlot(2,:), 'RvL'); %Right (Pit) v Left (Bat)
PitchOut = PitchCalcs(PitchOut, 7:9, PitchRat(LindP, 7:9), PStatR(LindP, 1:14), RV, xvec, iPlot(3,:), 'LvR'); %Left (Pit) v Right (Bat)
PitchOut = PitchCalcs(PitchOut, 10:12, PitchRat(LindP, 4:6), PStatL(LindP, 1:14), RV, xvec, iPlot(4,:), 'LvL'); %Left (Pit) v Left (Bat)

%Hold Calc
iPlot = true;
PitchOut = HoldCalc(PitchOut, 13:14, PitchRat(:,19), PitchOvr(:,1:21), RV, xvec, iPlot); %Hold fits for Pitcher

%%Output Pitching Files
xlswrite(fullfile(OutputFolder, 'PitchEqns.xlsx'), PitchOut);
%xlswrite(fullfile(OutputFolder, 'PitcherDefense.xlsx'), FitOvrP);


%%Stolen Base Estimates
AvgSBRate = sum(StatOvr(:,24))/(sum(sum(StatOvr(:,19:20))));
SBPred = [Output(24,1), -Def(1).Fits(3,1), -PitchOut(14,1), (2-2*AvgSBRate+Output(24,2)-Def(1).Fits(3,2)-PitchOut(14,2))]; %Ratings are Steal, Arm, Hold, Constant(Flip Catcher and Hold)
xlswrite(fullfile(OutputFolder, 'SBPrediction.xlsx'), SBPred);



