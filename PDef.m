function POut = PDef (POut, PRat, PEqn, SPIP, OBAData, AvgRatings, Def)
%PRat is Pitches, Stam, Hold, IF Fielding Ratings
POut(:,3) = PRat(:,2); %Stamina
POut(:,4) = PRat(:,1); %Number of Pitches

Outs = 3*SPIP;

StatCalc = zeros(size(PRat,1),size(PEqn,1));
for i = 1:size(PEqn,1)
  A = [PRat(:,3), ones(size(PRat,1),1)]; %Hold Rating
  x = PEqn(i,:).';
  StatCalc(:,i) = A*x;
endfor

SBA = StatCalc(:,1)*Outs;
wHold = -1*(OBAData(11)*SBA.*(StatCalc(:,2)) + OBAData(10)*SBA.*(1-StatCalc(:,2))); %Runs from stolen bases
POut(:,5) = wHold/OBAData(13); %Convert runs to WAR

[POut(:,6), CatchOut] = DefPred(PRat(:,4:7), Def, 0, 0, OBAData, SPIP, 0, 0, AvgRatings, 1, 0,false, 0); %Defensive calcs Pitcher

%Old Method
%A2 = [PRat(:,4:7), PRat(:,4).*PRat(:,5), PRat(:,4).*PRat(:,7), ones(size(PRat,1),6)];
%POut(:,6) = Outs * A2*(PDEqn.')/OBAData(13); %WAR from defensive play


endfunction