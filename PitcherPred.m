function PitchOut = PitcherPred (PitchOut, PRat, Handind, PEqn, OBAData)
 
StatCalc = zeros(size(PRat,1),size(PEqn,1));
for i = 1:size(PEqn,1)
  A = [PRat(:,i), ones(size(PRat,1),1)];
  x = PEqn(i,:).';
  StatCalc(:,i) = A*x;
endfor

PitchOut(Handind,2) = sum(3*StatCalc(Handind,:).*(ones(sum(Handind),1)*[-2,13,3]),2) + OBAData(14); %FIP
PitchOut(Handind,7:9) = StatCalc(Handind,:)*27; %K/9, HR/9, BB/9
  
endfunction