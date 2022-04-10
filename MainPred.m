%% Generate Predictions
clear all; close all;

%%Inputs
pkg load io;
folderloc = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';

BatEqns = xlsread(fullfile(folderloc,'BatEqns.xlsx'));
%DefEqns = xlsread(fullfile(folderloc,'DefEqns.xlsx')); %Old Defense Method
UBRFit = xlsread(fullfile(folderloc,'UBRFit.xlsx'));
PitchEqns = xlsread(fullfile(folderloc,'PitchEqns.xlsx'));
%PitchDef = xlsread(fullfile(folderloc, 'PitcherDefense.xlsx'));

tabnamesD = {'Pitcher','FirstBase','SecondBase','ThirdBase','ShortStop','LeftField','CenterField','RightField'};
for i = 1:length(tabnamesD) %Read each position data
  Def(i).Fits = xlsread(fullfile(folderloc,'DefEqns.xlsx'),tabnamesD{i});
endfor
AvgRatings = xlsread(fullfile(folderloc,'DefEqns.xlsx'),'AvgRatings'); %Average Fielding Ratings at each Position from Calculations

RatingFile = fullfile('C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports', 'ETHSRatings.xlsx'); %UPDATE HERE WITH YOUR RATING FILE
Rat = xlsread(RatingFile,'Batter Ratings','J3:AX1000'); %Batter Ratings
[blah txt blah2] = xlsread(RatingFile,'Batter Ratings','A3:I1000'); %Text based inputs
h = xlsread(RatingFile,'Batter Ratings','E3:E1000'); %Height

PitchRat = xlsread(RatingFile,'Pitcher Ratings','J3:AG2000'); %Pitcher Ratings
[blah txtP blah2] = xlsread(RatingFile,'Pitcher Ratings','A3:I2000'); %Text based inputs

OBAData = xlsread('OBAData.xlsx','A2:N152'); %OBAData

%OUTPUT FOLDER IMPORTANT!
outfolder = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\PredOutput';

%%CAN UPDATE NUMBERS BELOW IF YOU DESIRE
Year = 1975; %Year to use for OBA Factors
OBADataYear = OBAData(find(OBAData(:,1) == Year),:);
PA = 360; %Typical Plate Appearances
IP = 90*9; %Typical Innings Played
CatchIP = 72*9; %Typical Catcher Innings Played
SPIP = 110; %Starting Pitcher Innings Pitched?
AvgERA = 4.00; %Average ERA for this year
SBAtt = 14822/1712057; %SB Attempts per inning (2020 Data)
LeftIP = 188547/972167; %Percentage of PAs against Lefties
RightBF = 523443; LeftBF = 448728; LeftPct = LeftBF/(LeftBF + RightBF);

% Text Inputs
Pos = txt(:,1);
Hand = txt(:,6);
Rind = strcmp(Hand, 'R'); %Indexes of batter handedness
Lind = strcmp(Hand, 'L');
Sind = strcmp(Hand, 'S');


%% Batter Calcs
vROut = zeros(size(Rat,1),11);%WAR Total, bWAR, wOBA, OBP, AVG, SLG, K%, SB%, wGDP, UBR, BSR
vLOut = vROut;

vROut = BatterPred(vROut, Rat(:, 11:15), Rind, BatEqns, 1:5, Rat(:,39:41), UBRFit, OBADataYear, PA); %RvR
vLOut = BatterPred(vLOut, Rat(:, 6:10), (Rind|Sind), BatEqns, 6:10, Rat(:,39:41), UBRFit, OBADataYear, PA); %RvL
vROut = BatterPred(vROut, Rat(:,11:15), (Lind|Sind), BatEqns, 11:15, Rat(:,39:41), UBRFit, OBADataYear, PA); %LvR
vLOut = BatterPred(vLOut, Rat(:,6:10), Lind, BatEqns, 16:20, Rat(:,39:41), UBRFit, OBADataYear, PA); %LvL
OvrBatting = LeftIP*vLOut + (1-LeftIP)*vROut;

vROutPot = zeros(size(Rat,1),11);%WAR Total, bWAR, wOBA, OBP, AVG, SLG, K%, SB%, wGDP, UBR, BSR
vLOutPot = vROutPot;
%Batting Potential
vROutPot = BatterPred(vROutPot, Rat(:,16:20), Rind, BatEqns, 1:5, Rat(:,39:41), UBRFit, OBADataYear, PA); %RvR
vLOutPot = BatterPred(vLOutPot, Rat(:,16:20), (Rind|Sind), BatEqns, 6:10, Rat(:,39:41), UBRFit, OBADataYear, PA); %RvL
vROutPot = BatterPred(vROutPot, Rat(:,16:20), (Lind|Sind), BatEqns, 11:15, Rat(:,39:41), UBRFit, OBADataYear, PA); %LvR
vLOutPot = BatterPred(vLOutPot, Rat(:,16:20), Lind, BatEqns, 16:20, Rat(:,39:41), UBRFit, OBADataYear, PA); %LvL
OvrBattingPot = LeftIP*vLOutPot + (1-LeftIP)*vROutPot;

%%Defense CalcOutput (INDICES(2:length(tabnamesD)) represents the positions we're running)
%DefOut = DefPredold(Rat(:,21:29), DefEqns, BatEqns(25:27,:), h, OBADataYear, IP, CatchIP);
iruncatch = true; %Run Catcher Values
RowHeadBat = txt(:,[1,2,6]); %Need to figure out how to use names
[DefOuttemp CatchOut] = DefPred(Rat(:,21:29), Def, BatEqns(25:27,:), h, OBADataYear, IP, CatchIP, tabnamesD, AvgRatings, [2:length(tabnamesD)], outfolder,iruncatch, RowHeadBat); %Defensive calcs besides Pitcher
DefOut = [CatchOut, DefOuttemp, zeros(size(Rat,1),1)]; %Combine defensive values

%%Overall Ratings
vROverall = DefOut/OBADataYear(13) + vROut(:,1)*ones(1,size(DefOut,2));
vLOverall = DefOut/OBADataYear(13) + vLOut(:,1)*ones(1,size(DefOut,2));
CombOverall = DefOut/OBADataYear(13) + OvrBatting(:,1)*ones(1,size(DefOut,2));
PotOverall = DefOut/OBADataYear(13) + OvrBattingPot(:,1)*ones(1,size(DefOut,2));

%% Pitcher Calcs

%txt Inputs
HandP = txtP(:,7);
RindP = strcmp(HandP, 'R'); %Indexes of Pitcher handedness
LindP = strcmp(HandP, 'L');

vRPOut = zeros(size(PitchRat,1),9);
vLPOut = vRPOut;

vRPOut = PitcherPred(vRPOut, PitchRat(:,7:9), RindP, PitchEqns(1:3,:), OBADataYear); %RvR
vLPOut = PitcherPred(vLPOut, PitchRat(:,4:6), RindP, PitchEqns(4:6,:), OBADataYear); %RvL
vRPOut = PitcherPred(vRPOut, PitchRat(:,7:9), LindP, PitchEqns(7:9,:), OBADataYear); %LvR
vLPOut = PitcherPred(vLPOut, PitchRat(:,4:6), LindP, PitchEqns(10:12,:), OBADataYear); %RvR

%Pitching Potential
vRPOutPot = zeros(size(PitchRat,1),9);
vLPOutPot = vRPOutPot;

vRPOutPot = PitcherPred(vRPOutPot, PitchRat(:,10:12), RindP, PitchEqns(1:3,:), OBADataYear); %RvR
vLPOutPot = PitcherPred(vLPOutPot, PitchRat(:,10:12), RindP, PitchEqns(4:6,:), OBADataYear); %RvL
vRPOutPot = PitcherPred(vRPOutPot, PitchRat(:,10:12), LindP, PitchEqns(7:9,:), OBADataYear); %LvR
vLPOutPot = PitcherPred(vLPOutPot, PitchRat(:,10:12), LindP, PitchEqns(10:12,:), OBADataYear); %RvR


%Combine Pitching Values
vRPOut = PDef(vRPOut, PitchRat(:,[13,18:23]), PitchEqns(13:14,:), SPIP, OBADataYear, AvgRatings, Def); %Pitcher Stam, Pitches, Hold, Def
vLPOut(:,[3:6]) = vRPOut(:,[3:6]);

[OvrPitching, vRPOut, vLPOut] = CombPitching(vRPOut, vLPOut, SPIP, LeftPct, AvgERA, OBADataYear); %Calc Final Values

vRPOutPot = PDef(vRPOutPot, PitchRat(:,[13,18:23]), PitchEqns(13:14,:), SPIP, OBADataYear, AvgRatings, Def); %Pitcher Stam, Pitches, Hold, Def
vLPOutPot(:,[3:6]) = vRPOutPot(:,[3:6]);

[OvrPitchingPot, vRPOutPot, vLPOutPot] = CombPitching(vRPOutPot, vLPOutPot, SPIP, LeftPct, AvgERA, OBADataYear); %Calc Final Values



%Output (NEED TO REMOVE ANY ACCENTS FROM PLAYER NAMES IN PLAYER RATINGS TAB. IT WILL CAUSE ERROR WHEN WRITING)
BFileName = 'BatterPredictionsOut.xlsx';
RowHeadBat = txt(:,[1,2,6]); %Need to figure out how to use names
ColHeadBat = {'Pos','Name','Bats','WAR Total','bWAR','wOBA','OBP','AVG','SLG','K%','wSB','wGDP','UBR','BSR'};
ColHeadDef = {'Pos','Name','Bats','C','1B','2B','3B','SS','LF','CF','RF','DH'};
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Comb Ovr',CombOverall, ColHeadDef,RowHeadBat); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Comb vR',vROverall, ColHeadDef,RowHeadBat); %vs Right Total
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Comb vL',vLOverall, ColHeadDef,RowHeadBat); %vs Left Total
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Bat Ovr',OvrBatting, ColHeadBat,RowHeadBat); %Overall Batting
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Bat vR',vROut, ColHeadBat,RowHeadBat); %vs Right Batting
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Bat vL',vLOut, ColHeadBat,RowHeadBat); %vs Left Batting
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Defense',DefOut, ColHeadDef,RowHeadBat); %Defense
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Comb Potential',PotOverall, ColHeadDef,RowHeadBat); %Potential Total
NoOutput = WritePredOutput(fullfile(outfolder,BFileName), 'Batting Potential',OvrBattingPot, ColHeadDef,RowHeadBat); %Potential Batting


PFileName = 'PitcherPredictionsOut.xlsx';
RowHeadPit = txtP(:,[1,2,7]);
ColHeadPit = {'Pos','Name','Throws','WAR','FIP','Stam','Pitches','wSB','wDef','SO/9','HR/9','BB/9'};
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'Overall',OvrPitching, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'vR Pitch',vRPOut, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'vL Pitch',vLPOut, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'Pot Pitch',OvrPitchingPot, ColHeadPit,RowHeadPit); %Overall Total
