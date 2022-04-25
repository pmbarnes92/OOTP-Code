function [Def, AvgRatings] = MainDefCalc (filenamed, RV, xvec, RatSys, divisor)

tabnamesD = {'Catcher','Pitcher','FirstBase','SecondBase','ThirdBase','ShortStop','LeftField','CenterField','RightField'};

OutfileLocD = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\CalcOutput';
OutfileNameD = 'DefEqns.xlsx';

PosD = {'C','P','1B','2B','3B','SS','LF','CF','RF'};

for i = 1:length(tabnamesD) %Read each position data
  Def(i).Data = xlsread(filenamed,tabnamesD{i},'G3:BE2000');
  if (RatSys > 1) %not 50-80
    Def(i).Data(:,1:18) = divisor*round(Def(i).Data(:,1:18)/divisor); %Adjust Ratings to increments of 5
  endif
endfor
H1B = xlsread(filenamed,'FirstBase','D3:D2000');

AvgRatings = zeros(9,5);

%Catcher Calcs
iPlot = true;
[Def(1).Fits, AvgRatings(1,:)] = CatcherCalcs(Def(1).Data, RV, xvec, PosD{1}, iPlot, OutfileLocD, OutfileNameD, tabnamesD{1});

%Infield
iPlot = ones(1,6); % %Range, Arm, Range vs Arm, Double Play, Error, 1B height
iPlot([2,3]) = 1;
for j = 2:6
  [Def(j).Fits, AvgRatings(j,:)] = InfieldFits(Def(j).Data, H1B, RV, xvec, PosD{j}, iPlot,  OutfileLocD, OutfileNameD, tabnamesD{j});% All Fits are scaled to per out played based on average chances per out played of the entire league.
endfor

%Outfield
iPlot = ones(1,3); %[1,1,1]; %Range, Assist, Error
for j = 7:9
  [Def(j).Fits, AvgRatings(j,:)] = OutfieldFits(Def(j).Data, RV, xvec, PosD{j}, iPlot, OutfileLocD, OutfileNameD, tabnamesD{j}); % All Fits are scaled to per out played based on average chances per out played of the entire league.
endfor

xlswrite(fullfile(OutfileLocD, OutfileNameD),AvgRatings, 'AvgRatings');

endfunction
