%DefenseCalcs Main file for second method
pkg load io; %Just in case we haven't already loaded

%Rating Scale used for regressions (Need these in case this isn't called from main hits function
RV = (20:5:80).';
xvec = [RV, ones(length(RV),1)];

tabnamesD = {'Pitcher','FirstBase','SecondBase','ThirdBase','ShortStop','LeftField','CenterField','RightField'};
filelocationD = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports';
filenameD = 'FieldingExport.xlsx';

OutfileLocD = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';
OutfileNameD = 'DefEqns.xlsx';

PosD = {'P','1B','2B','3B','SS','LF','CF','RF'};

for i = 1:length(tabnamesD) %Read each position data
  Def(i).Data = xlsread(fullfile(filelocationD,filenameD),tabnamesD{i},'F3:AO2000');
endfor
H1B = xlsread(fullfile(filelocationD,filenameD),'FirstBase','C3:C2000');

AvgRatings = zeros(8,5);

%Infield
iPlot = zeros(1,6); %[1,1,1,1,1, 1]; %Range, Arm, Range vs Arm, Double Play, Error, 1B height
for j = 1:5
  [Def(j).Fits, AvgRatings(j,:)] = InfieldFits(Def(j).Data, H1B, RV, xvec, PosD{j}, iPlot,  OutfileLocD, OutfileNameD, tabnamesD{j});% All Fits are scaled to per out played based on average chances per out played of the entire league.
endfor

%Outfield
iPlot = zeros(1,3); %[1,1,1]; %Range, Assist, Error
for j = 6:8
  [Def(j).Fits, AvgRatings(j,:)] = OutfieldFits(Def(j).Data, RV, xvec, PosD{j}, iPlot, OutfileLocD, OutfileNameD, tabnamesD{j}); % All Fits are scaled to per out played based on average chances per out played of the entire league.
endfor

xlswrite(fullfile(OutfileLocD, OutfileNameD),AvgRatings, 'AvgRatings');
