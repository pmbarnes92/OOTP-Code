%Main Batter Calcs File
%Outputs are BatEqns, DefEqns, UBRFit, PitchEqns, SBPrediction
clear all; close all;

%% Read Stat + general variables
pkg load io;
filename = fullfile('C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports','MLBCalcs.xlsx');
OutputFolder = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';

Rat = xlsread(filename,'Batter Ratings','J3:AX1000'); %Batter Ratings
[blah txt blah2] = xlsread(filename,'Batter Ratings','A3:I1000'); %Text based inputs
StatOvr = xlsread(filename,'Batter Stats','H3:BJ1000'); %Total Batting Stats (just used for steals?)
StatR = xlsread(filename,'Batter Split R','H3:BJ1000'); %Batter split stats vs R
StatL = xlsread(filename,'Batter Split L','H3:BJ1000'); %Batter split stats vs L
h = xlsread(filename,'Batter Ratings','E3:E1000'); %Height

PitchRat = xlsread(filename,'Pitcher Ratings','J3:AG2000'); %Pitcher Ratings
[blah txtP blah2] = xlsread(filename,'Pitcher Ratings','A3:I2000'); %Text based inputs
PitchOvr = xlsread(filename,'Pitcher Stats','H3:AR1000'); %Total Pitching Stats (Just used for steals?)
PStatR = xlsread(filename,'Pitcher Split R','H3:AR1000'); %Pitcher split stats vs R
PStatL = xlsread(filename,'Pitcher Split L','H3:AR1000'); %Pitcher split stats vs L


% Text Inputs
Pos = txt(:,1);
Hand = txt(:,6);
Rind = strcmp(Hand, 'R'); %Indexes of batter handedness
Lind = strcmp(Hand, 'L');
Sind = strcmp(Hand, 'S');

%Rating Scale used for regressions
RV = (20:5:80).';
xvec = [RV, ones(length(RV),1)];

Output = zeros(27,2); %BatterOutput


%%HitCalcs
iPlot = ones(4,5); %Default to not plot. Manually set values to plot below
%iPlot(:,2) = 1; %first column adjusts split, second column adjusts variable (BABIP, Pow, Gap, Eye, K)
Output = HitCalcs(Output, 1:5, Rat(Rind, 11:15), StatR(Rind, 1:15), RV, xvec, iPlot(1,:), 'RvR'); %Right (Bat) v Right (Pit)
Output = HitCalcs(Output, 6:10, Rat(Rind|Sind, 6:10), StatL(Rind|Sind, 1:15), RV, xvec, iPlot(2,:), 'RvL'); %Right (Bat) v Left (Pit)
Output = HitCalcs(Output, 11:15, Rat(Lind|Sind, 11:15), StatR(Lind|Sind, 1:15), RV, xvec, iPlot(3,:), 'LvR'); %Left (Bat) v Right (Pit)
Output = HitCalcs(Output, 16:20, Rat(Lind, 6:10), StatL(Lind, 1:15), RV, xvec, iPlot(4,:), 'LvL'); %Left (Bat) v Left (Pit)


%%RunningCalcs
iPlot = true;
[Output UBRFit ErrRun] = RunCalcs(Output, 21:24, Rat(:,39:41), StatOvr(:,1:29), RV, xvec, iPlot); %Running Output


%%DefenseCalcs (use right handed stats only (same as left))
##iPI = StatR(:,41) > 0; %Did player play any innings in the field?
##iPos = {'1B','2B','3B','SS','LF','CF','RF'};
##iIFOF = [1,1,1,1,2,2,2]; %Is position infield or outfield?
##[FitOvr, ErrDef] = DefenseCalcs(Rat(iPI, 21:27), Pos(iPI), h, StatR(iPI, 31:55), iPos, iIFOF, RV, xvec); %Position Player Analysis

MainDefCalc; %Call new Defensive calc method

%Catcher Calcs
iCatch = (StatR(:,41) > 0 & strcmp(Pos, 'C'));
iPlot = true;
Output = CatcherCalcs(Output, 25:27, Rat(iCatch,28:29), StatR(iCatch,31:55), RV, xvec, iPlot);


%%Output Files
xlswrite(fullfile(OutputFolder, 'BatEqns.xlsx'), Output);
%xlswrite(fullfile(OutputFolder, 'DefEqns.xlsx'), FitOvr);
xlswrite(fullfile(OutputFolder, 'UBRFit.xlsx'), UBRFit);



%% Pitcher Section
PitchOut = zeros(14,2);
HandP = txtP(:,7);
RindP = strcmp(HandP, 'R'); %Indexes of Pitcher handedness
LindP = strcmp(HandP, 'L');

%Main Pitcher Calcs
iPlot = ones(4,3);
%iPlot(:,3) = 1; %first column adjusts split, second column adjusts variable (Stuff, Movement, Control)
PitchOut = PitchCalcs(PitchOut, 1:3, PitchRat(RindP, 7:9), PStatR(RindP, 1:15), RV, xvec, iPlot(1,:), 'RvR'); %Right (Pit) v Right (Bat)
PitchOut = PitchCalcs(PitchOut, 4:6, PitchRat(RindP, 4:6), PStatL(RindP, 1:15), RV, xvec, iPlot(2,:), 'RvL'); %Right (Pit) v Left (Bat)
PitchOut = PitchCalcs(PitchOut, 7:9, PitchRat(LindP, 7:9), PStatR(LindP, 1:15), RV, xvec, iPlot(3,:), 'LvR'); %Left (Pit) v Right (Bat)
PitchOut = PitchCalcs(PitchOut, 10:12, PitchRat(LindP, 4:6), PStatL(LindP, 1:15), RV, xvec, iPlot(4,:), 'LvL'); %Left (Pit) v Left (Bat)

%PitcherDefense
##iPI = PStatR(:,37) > 0; %Innings played in the field
##iPos = {'P'};
##iIFOF = [1];
##[FitOvrP, ErrDefP] = DefenseCalcs(PitchRat(iPI, 20:23), 1, h, PStatR(iPI, 29:37), iPos, iIFOF, RV, xvec, iPlot); %Position Player Analysis

%Hold Calc
iPlot = true;
PitchOut = HoldCalc(PitchOut, 13:14, PitchRat(:,19), PitchOvr(:,1:26), RV, xvec, iPlot); %Hold fits for Pitcher

%%Output Pitching Files
xlswrite(fullfile(OutputFolder, 'PitchEqns.xlsx'), PitchOut);
%xlswrite(fullfile(OutputFolder, 'PitcherDefense.xlsx'), FitOvrP);


%%Stolen Base Estimates
AvgSBRate = sum(StatOvr(:,24))/(sum(sum(StatOvr(:,24:25))));
SBPred = [Output(24,1), -Output(27,1), -PitchOut(14,1), (2-2*AvgSBRate+Output(24,2)-Output(27,2)-PitchOut(14,2))]; %Ratings are Steal, Arm, Hold, Constant(Flip Catcher and Hold)
xlswrite(fullfile(OutputFolder, 'SBPrediction.xlsx'), SBPred);



