function [RatSys, Rat, txt, txtP, StatOvr, StatR, StatL, h, PitchRat, PitchOvr, PStatR, PStatL, filename, filenamed NewRun] = CalcReadFile ()
 
answer = questdlg('Run Previous Settings or Start by Selecting Rating System','Calc Run Setup','Run Previous','20-80','1-100 PT','Run Previous');
NewRun = 1;
switch answer
  case 'Run Previous'
    load('CalcPresets');
    NewRun = 0;
  case '20-80'
    RatSys = 1;
  case '1-100 PT'
    RatSys = 2;
end
  

%% Read Stat + general variables
pkg load io;
if (NewRun)
  [fname, fpath] = uigetfile('*.xlsx','Choose Hitter and Pitcher Export');
  filename = fullfile(fpath, fname);
  %filename = fullfile('C:\Users\pmbar\OneDrive\Documents\OOTP\Code\Exports','MLBCalcs23.xlsx');
  
  [fnamed, fpathd] = uigetfile('*.xlsx','Choose Defense Export');
  filenamed = fullfile(fpathd, fnamed);
endif

Rat = xlsread(filename,'Batter Ratings','G3:AN2000'); %Batter Ratings
[blah txt blah2] = xlsread(filename,'Batter Ratings','A3:F2000'); %Text based inputs
StatOvr = xlsread(filename,'Batter Stats','E3:AB2000'); %Total Batting Stats (just used for steals?)
StatR = xlsread(filename,'Batter Split R','E3:AB2000'); %Batter split stats vs R
StatL = xlsread(filename,'Batter Split L','E3:AB2000'); %Batter split stats vs L
h = xlsread(filename,'Batter Ratings','D3:D2000'); %Height

PitchRat = xlsread(filename,'Pitcher Ratings','G3:AD2000'); %Pitcher Ratings
[blah txtP blah2] = xlsread(filename,'Pitcher Ratings','A3:F2000'); %Text based inputs
PitchOvr = xlsread(filename,'Pitcher Stats','E3:AA2000'); %Total Pitching Stats (Just used for steals?)
PStatR = xlsread(filename,'Pitcher Split R','E3:AA2000'); %Pitcher split stats vs R
PStatL = xlsread(filename,'Pitcher Split L','E3:AA2000'); %Pitcher split stats vs L

endfunction
