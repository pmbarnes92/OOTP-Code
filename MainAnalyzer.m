%Depth Chart Analyzer
clear all; close all;

%%Inputs
pkg load io;
folderloc = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\PredOutput';
filename = 'BatterPredictionsOut.xlsx';

CombOvr = xlsread(fullfile(folderloc,filename),'Comb Ovr','D2:L2000');
CombvR = xlsread(fullfile(folderloc,filename),'Comb vR','D2:L2000');
CombvL = xlsread(fullfile(folderloc,filename),'Comb vL','D2:L2000');
CombPot = xlsread(fullfile(folderloc,filename),'Comb Potential','D2:L2000');
[blah txt blah2] = xlsread(fullfile(folderloc,filename),'Comb Ovr');
Names = txt(2:end,2);

numlineup = 3;
[Results, WARList, indList] = DepthAnalyze(CombOvr, numlineup);
[ResultsvR, WARListvR, indListvR] = DepthAnalyze(CombvR, numlineup);
[ResultsvL, WARListvL, indListvL] = DepthAnalyze(CombvL, numlineup);
[ResultsPot, WARListPot, indListPot] = DepthAnalyze(CombPot, numlineup);

OutFolder = 'C:\Users\pmbar\OneDrive\Documents\OOTP\Code\AnalyzeOut';
fileout = 'AnalyzeOut.xlsx';
NoOutput = PrintRes(fullfile(OutFolder,fileout), Results, WARList, indList, Names, 'Comb Depth','Comb Sort');
NoOutput = PrintRes(fullfile(OutFolder,fileout), ResultsvR, WARListvR, indListvR, Names, 'vR Depth','vR Sort');
NoOutput = PrintRes(fullfile(OutFolder,fileout), ResultsvL, WARListvL, indListvL, Names, 'vL Depth','vL Sort');
NoOutput = PrintRes(fullfile(OutFolder,fileout), ResultsPot, WARListPot, indListPot, Names, 'Pot Depth','Pot Sort');



