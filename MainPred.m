%% Generate Predictions
clear all; close all;
pkg load io;

DScale = 1.1;

Year = 2021; %Used for OBAData
OBAData = xlsread('OBAData.xlsx','A2:N152'); %OBAData
OBADataYear = OBAData(find(OBAData(:,1) == Year),:);

%%Inputs
[pname, ppath] = uigetfile('*.xlsx','Choose Player Ratings File for Predictions');
RatingFile = fullfile(ppath, pname);

Rat = xlsread(RatingFile,'Batter Ratings','G3:AN2000'); %Batter Ratings
[blah txt blah2] = xlsread(RatingFile,'Batter Ratings','A3:F2000'); %Text based inputs
h = xlsread(RatingFile,'Batter Ratings','D3:D2000'); %Height
PitchRat = xlsread(RatingFile,'Pitcher Ratings','G3:AD2000'); %Pitcher Ratings
[blah txtP blah2] = xlsread(RatingFile,'Pitcher Ratings','A3:F2000'); %Text based inputs

%Read Calc Outputs
folderloc = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';
BatEqns = xlsread(fullfile(folderloc,'BatEqns.xlsx'));
UBRFit = xlsread(fullfile(folderloc,'UBRFit.xlsx'));
PitchEqns = xlsread(fullfile(folderloc,'PitchEqns.xlsx'));

tabnamesD = {'Catcher','Pitcher','FirstBase','SecondBase','ThirdBase','ShortStop','LeftField','CenterField','RightField'};
for i = 1:length(tabnamesD) %Read each position data
  Def(i).Fits = xlsread(fullfile(folderloc,'DefEqns.xlsx'),tabnamesD{i});
endfor
AvgRatings = xlsread(fullfile(folderloc,'DefEqns.xlsx'),'AvgRatings'); %Average Fielding Ratings at each Position from Calculations

%OUTPUT FOLDER IMPORTANT!
outfolder = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\PredOutput';

%%READ YEARLY CONSTANTS FROM FILE
YC = xlsread(fullfile(folderloc, 'YearConstants.xlsx'));
PA = YC(1); %Typical Plate Appearances
IP = YC(2); %Typical Innings Played
CatchIP = YC(3); %Typical Catcher Innings Played CURRENTLY CHOOSING TO HAVE CATCHER INNINGS MATCH REG IP FOR PARITY WITH PA (in YearConstants.m)
SPIP = YC(4); %Starting Pitcher Innings Pitched?
AvgERA = YC(5); %Average ERA for this year
SBAtt = YC(6); %SB Attempts per inning (2020 Data)
LeftIP = YC(7); %Percentage of PAs against Lefties
LeftPct = YC(8); %Percentage of Left handed Batters faced

% Text Inputs
Pos = txt(:,1);
Hand = txt(:,5);
Rind = strcmp(Hand, 'R'); %Indexes of batter handedness
Lind = strcmp(Hand, 'L');
Sind = strcmp(Hand, 'S');


%% Batter Calcs
vROut = zeros(size(Rat,1),11);%WAR Total, bWAR, wOBA, OBP, AVG, SLG, K%, SB%, wGDP, UBR, BSR
vLOut = vROut;

RunRange = 32:34;
vROut = BatterPred(vROut, Rat(:, 6:10), Rind, BatEqns, 1:5, Rat(:,RunRange), UBRFit, OBADataYear, PA); %RvR
vLOut = BatterPred(vLOut, Rat(:, 1:5), (Rind|Sind), BatEqns, 6:10, Rat(:,RunRange), UBRFit, OBADataYear, PA); %RvL
vROut = BatterPred(vROut, Rat(:,6:10), (Lind|Sind), BatEqns, 11:15, Rat(:,RunRange), UBRFit, OBADataYear, PA); %LvR
vLOut = BatterPred(vLOut, Rat(:,1:5), Lind, BatEqns, 16:20, Rat(:,RunRange), UBRFit, OBADataYear, PA); %LvL
OvrBatting = LeftIP*vLOut + (1-LeftIP)*vROut;

vROutPot = zeros(size(Rat,1),11);%WAR Total, bWAR, wOBA, OBP, AVG, SLG, K%, SB%, wGDP, UBR, BSR
vLOutPot = vROutPot;
%Batting Potential
vROutPot = BatterPred(vROutPot, Rat(:,11:15), Rind, BatEqns, 1:5, Rat(:,RunRange), UBRFit, OBADataYear, PA); %RvR
vLOutPot = BatterPred(vLOutPot, Rat(:,11:15), (Rind|Sind), BatEqns, 6:10, Rat(:,RunRange), UBRFit, OBADataYear, PA); %RvL
vROutPot = BatterPred(vROutPot, Rat(:,11:15), (Lind|Sind), BatEqns, 11:15, Rat(:,RunRange), UBRFit, OBADataYear, PA); %LvR
vLOutPot = BatterPred(vLOutPot, Rat(:,11:15), Lind, BatEqns, 16:20, Rat(:,RunRange), UBRFit, OBADataYear, PA); %LvL
OvrBattingPot = LeftIP*vLOutPot + (1-LeftIP)*vROutPot;

iruncatch = true; %Run Catcher Values
RowHeadBat = txt(:,[1,2,5]); %Need to figure out how to use names
DefOuttemp = DefPred(Rat(:,15:23), Def, h, OBADataYear, IP, CatchIP, tabnamesD, AvgRatings, [1, 3:length(tabnamesD)], outfolder,iruncatch, RowHeadBat); %Defensive calcs besides Pitcher
DefOut = DScale*[DefOuttemp, zeros(size(Rat,1),1)]; %Combine defensive values with a DScale set by user at top

%%Overall Ratings
vROverall = DefOut/OBADataYear(13) + vROut(:,1)*ones(1,size(DefOut,2));
vLOverall = DefOut/OBADataYear(13) + vLOut(:,1)*ones(1,size(DefOut,2));
CombOverall = DefOut/OBADataYear(13) + OvrBatting(:,1)*ones(1,size(DefOut,2));
PotOverall = DefOut/OBADataYear(13) + OvrBattingPot(:,1)*ones(1,size(DefOut,2));


%% Pitcher Calcs

%txt Inputs
HandP = txtP(:,6);
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

[OvrPitching, vRPOut, vLPOut] = CombPitching(vRPOut, vLPOut, SPIP, LeftPct, AvgERA, OBADataYear, DScale); %Calc Final Values

vRPOutPot = PDef(vRPOutPot, PitchRat(:,[13,18:23]), PitchEqns(13:14,:), SPIP, OBADataYear, AvgRatings, Def); %Pitcher Stam, Pitches, Hold, Def
vLPOutPot(:,[3:6]) = vRPOutPot(:,[3:6]);

[OvrPitchingPot, vRPOutPot, vLPOutPot] = CombPitching(vRPOutPot, vLPOutPot, SPIP, LeftPct, AvgERA, OBADataYear, DScale); %Calc Final Values



%Output (NEED TO REMOVE ANY ACCENTS FROM PLAYER NAMES IN PLAYER RATINGS TAB. IT WILL CAUSE ERROR WHEN WRITING)
BFileName = 'BatterPredictionsOut.xlsx';
RowHeadBat = txt(:,[1,2,5]); %Need to figure out how to use names
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
RowHeadPit = txtP(:,[1,2,6]);
ColHeadPit = {'Pos','Name','Throws','WAR','FIP','Stam','Pitches','wSB','wDef','SO/9','HR/9','BB/9'};
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'Overall',OvrPitching, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'vR Pitch',vRPOut, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'vL Pitch',vLPOut, ColHeadPit,RowHeadPit); %Overall Total
NoOutput = WritePredOutput(fullfile(outfolder,PFileName), 'Pot Pitch',OvrPitchingPot, ColHeadPit,RowHeadPit); %Overall Total
