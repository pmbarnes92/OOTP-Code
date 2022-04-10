%Calc Batter Outputs (MAKE SURE TO REMOVE CM FROM HEIGHT MEASUREMENT ON RATING PAGE)
clear all; close all;

Rat = xlsread(fullfile('C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports','MLBCalcs.xlsx'),'Batter Ratings','J3:AX1000');
coeffs = xlsread('BattingParams.xlsx');
OBAData = xlsread('OBAData.xlsx','A2:N152');

Year = 2020; %Year to use for OBA Factors
PA = 600; %Typical Plate Appearances
IP = 150*9; %Typical Innings Played
SBAtt = 3142/42207; %SB Attempts per inning (2020 Data)
LeftIP = 10760.5/40051.2; %Percentage of innings pitched by lefties (2020 Data)

BatterPred = zeros(size(Rat,1),24);

%Batting and Running Calcs
Range = 1:12;
RHPRats = Rat(:,[11:12,39,13:15,39:40,39,39,41,39]);
MultMat = ones(size(RHPRats,1),1)*(coeffs(Range,1).');
ScaleMat = ones (size(RHPRats,1),1)*(coeffs(Range,2).');
BatterPred(:,Range) = MultMat.*RHPRats+ScaleMat;

Range2 = 13:24;
LHPRats = Rat(:,[6:7,39,8:10,39:40,39,39,41,39]);
BatterPred(:,Range2) = MultMat.*LHPRats+ScaleMat;

%CalcMaxPositionRatings (WOULD NEED TO REDO THIS SECTION IF USING 0-100 scale..would be easier. update excel sheet as well)
FieldRats = [Rat(:,21:27), ones(size(Rat,1),1)];
PosCalcMat = xlsread('PosCalcs.xlsx','B2:G9');

PosRatingstemp = FieldRats * PosCalcMat;

Ratings1B = zeros(size(Rat,1),1);
heights = xlsread(fullfile('C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports','MLBCalcs.xlsx'),'Batter Ratings','E3:E1000');
for i = 1:length(Ratings1B)
  IA = (Rat(i,22)-20)/80;
  TDP = (Rat(i,23)-20)/80;
  Tip = (50-(100-90)*6/20);
  if(Rat(i,21) <= Tip)
    IR = (Rat(i,21)-20)/3;
  else
    IR = (Tip-20)/3 + (Rat(i,21)-Tip)*2/25;
  endif
  
  
  Tip = (50-(100-95)*6/20);
  if(Rat(i,24) <= Tip)
    IE = (Rat(i,24)-20)/5.25;
  else
    IE = (Tip-20)/5.25 + (Rat(i,24)-Tip)/25;
  endif
  
  HA = 1 + (heights(i)-155)/15;
  SkillRating = IA + TDP + IR + IE;
  Ratings1B(i) = 20 + SkillRating * HA;
endfor

PosRatings = [Ratings1B, PosRatingstemp];
