function NoOutput = YearConstants (StatOvr, StatR, StatL, PitchOvr, PStatR, PStatL, Def, Teams, Games, OutputFolder)

%PA, IP, CatchIP, SPIP, AvgERA, SBAtt/Inn, LeftIP, LeftBF
Outarray = zeros(8,1);
PA = sort(StatOvr(:,2),'descend');
incl = round(Teams*9/2);
Outarray(1,1) = mean(PA(1:incl)); %PA's

Outs = mod(PitchOvr(:,2),1)*10 + floor(PitchOvr(:,2))*3;%Convert IP to Outs (PITCHER OUTS)
IPpPA = sum(Outs)/sum(PA)/3;

##IPs = 0;
##for i = 3:length(Def)
##  Outs = mod(Def(i).Data(:,31),1)*10 + floor(Def(i).Data(:,31))*3;%Convert IP to Outs
##  Outsort = sort(Outs,'descend');
##  IPs = IPs + sum(Outsort(1:(Teams/2)))/3; %IP's
##endfor
##IPs = IPs/(Teams*7/2);
##Outarray(2,1) = IPs;
Outarray(2,1) = 9*IPpPA*Outarray(1,1); %Multiply by 9 because there are 9 fielders IP for each pitcher IP

%Catcher
##Outs = mod(Def(1).Data(:,31),1)*10 + floor(Def(1).Data(:,31))*3;%Convert IP to Outs
##Outsort = sort(Outs,'descend');
##CatchIP = mean(Outsort(1:(Teams/2)))/3;
##Outarray(3,1) = CatchIP;
Outarray(3,1) = Outarray(2,1);

Outs = mod(PitchOvr(:,2),1)*10 + floor(PitchOvr(:,2))*3;%Convert IP to Outs
SPIP = sort(Outs,'descend');
incl = Teams * 2.5;
Outarray(4,1) = mean(SPIP(1:incl))/3; %SPIP

AvgERA = 9*3*sum(PitchOvr(:,10))/sum(Outs);
Outarray(5,1) = AvgERA;

SBatt = 3*sum(sum(PitchOvr(:,20:21)))/sum(Outs);
Outarray(6,1) = SBatt;

LeftIP = sum(StatL(:,2));
RightIP = sum(StatR(:,2));
Outarray(7,1) = LeftIP/(LeftIP + RightIP); %Pct of left handed pitchers based on PA

LeftBF = sum(PStatL(:,3));
RightBF = sum(PStatR(:,3));
Outarray(8,1) = LeftBF/(LeftBF + RightBF); %Pct of left handed Batters based on BF

xlswrite(fullfile(OutputFolder,'YearConstants.xlsx'),Outarray);

NoOutput = 1; %Return

endfunction
