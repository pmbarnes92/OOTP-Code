function Output = BatterPred (Output, BatRat, Bind, BatEqns, Range, RunRat, UBRFit, OBAData, PA)

StatCalc = zeros(size(BatRat,1),length(Range));
for i = 1:length(Range)
  A = [BatRat(:,i), ones(size(BatRat,1),1)];
  x = BatEqns(Range(i),:).';
  StatCalc(:,i) = A*x;
endfor

RunEqnind = 21:24; %Make sure this stays true if you do any monkeying
RunRatind = [1,1,1,2];
RunCalc = zeros(size(RunRat,1),length(RunEqnind));
for i = 1:length(RunEqnind)
  Arun = [RunRat(:,RunRatind(i)), ones(size(RunRat,1),1)];
  xrun = BatEqns(RunEqnind(i),:).';
  RunCalc(:,i) = Arun*xrun;
endfor

SlgPct = StatCalc(:,1) + StatCalc(:,2).*(1+RunCalc(:,1)) + 3*StatCalc(:,3); %Second term accounts for doubles and triples (1 + triple rate)
wOBA = OBAData(4)*StatCalc(:,4) + (1-StatCalc(:,4)).*(OBAData(6)*StatCalc(:,1) + (OBAData(7)-OBAData(6))*StatCalc(:,2) + (OBAData(8)-OBAData(7))*(StatCalc(:,2).*RunCalc(:,1)) + (OBAData(9)-OBAData(6))*StatCalc(:,3));
wRAA = ((wOBA - OBAData(2))/OBAData(3))*PA;
WAR = wRAA/OBAData(13); %Divide runs by runs per WAR

%Stolen Base
On1BpPA = StatCalc(:,4) + (1-StatCalc(:,4)).*(StatCalc(:,1) -StatCalc(:,2) - StatCalc(:,3));
SBApPA = On1BpPA.*RunCalc(:,3); %SB Attempt per plate appearance
SBA = PA*SBApPA; %SB Attempts
RpSBA = OBAData(10)*RunCalc(:,4) + OBAData(11)*(1-RunCalc(:,4)); %Runs per SB Attempts
wSB = SBA.*RpSBA/OBAData(13); %Divide runs by runs per WAR

%Double Play
AvgDPpPA = 0.02; %Use this as a typical number
GDPpPA = (1 - StatCalc(:,4) - ((1-StatCalc(:,4)).*(StatCalc(:,5)+StatCalc(:,1)))).*RunCalc(:,2); %Balls in play times rate of double play
DPRV = (.489-.095+.214)/2; %From Run Value Expectancy Matrix
wGDP = PA*DPRV*(GDPpPA-AvgDPpPA)/OBAData(13); %use caught stealing as negative value for double play

%UBR
AUBR = [RunRat(:,[1, 3]), ones(size(RunRat,1),1)];
Avgval = [50,50,1];
UBRDiff = AUBR*UBRFit-Avgval*UBRFit;
OnbasepPA = StatCalc(:,4) + (1-StatCalc(:,4)).*(StatCalc(:,1)-StatCalc(:,3)) - SBApPA.*(1-RunCalc(:,4)); %Walks plus avg - HR - CS
UBRruns = PA*OnbasepPA.*UBRDiff;
wUBR = UBRruns/OBAData(13);


Output(Bind, 2) = WAR(Bind);
Output(Bind, 3) = wOBA(Bind);
Output(Bind, 4) = StatCalc(Bind, 1).*(1-StatCalc(Bind, 4)) + StatCalc(Bind, 4); %OBP
Output(Bind, 5) = StatCalc(Bind, 1); %Avg
Output(Bind, 6) = SlgPct(Bind);
Output(Bind, 7) = StatCalc(Bind, 5); %K%
Output(Bind, 8) = wSB(Bind);
Output(Bind, 9) = wGDP(Bind);
Output(Bind, 10) = wUBR(Bind);
Output(Bind, 11) = wSB(Bind) + wGDP(Bind) + wUBR(Bind); %BSR
Output(Bind, 1) = Output(Bind, 2) + Output(Bind, 11); %Total WAR combining hitting and running



endfunction
