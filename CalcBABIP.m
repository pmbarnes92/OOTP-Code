%Currently programmed for 20-80 rating scale. Could be modified to fit other scales. SEE SGT Mushroom sheet for contstants used. They should be the same constants for other ratings, but would need to replace 50 etc.
function BABIPRat = CalcBABIP (Con, Pow, AvK, divisor, iround)
  BABIPnum = Con - 50*ones(size(Con,1),1); %Numerator for Babip Calc (Need to sum to Contact Rating)
  Kadj = zeros(size(Con,1),1);
  Padj = Kadj;
  BABIPden = Kadj;
  BABIPRat = Kadj;
  
  case1 = Con < 50;
  case2 = Con == 50;
  case3 = Con > 50;
  
  indK1 = AvK < 50;
  indK2 = AvK == 50;
  indK3 = AvK > 50;
  
  indP1 = Pow < 50;
  indP2 = Pow == 50;
  indP3 = Pow > 50;
  
  Kadj(case1 & indK1) = 0.33*(AvK(case1 & indK1) - 50);
  Kadj(case1 & indK2) = 1.25*(0.2-0.33); %Slight negative since average contribution will be negative right at 50 rating
  Kadj(case1 & indK3) = 0.2*(AvK(case1 & indK3) - 50);
  
  Kadj(case2 & indK1) = mean([0.33,0.7])*(AvK(case2 & indK1) - 50);
  Kadj(case2 & indK2) = 1.25*(mean([0.2,0.45]) - mean([0.33,0.7])); %Slight negative since average contribution will be negative right at 50 rating
  Kadj(case2 & indK3) = mean([0.2,0.45])*(AvK(case2 & indK3) - 50);
  
  Kadj(case3 & indK1) = 0.7*(AvK(case3 & indK1) - 50);
  Kadj(case3 & indK2) = 1.25*(0.45-0.7); %Slight negative since average contribution will be negative right at 50 rating
  Kadj(case3 & indK3) = 0.45*(AvK(case3 & indK3) - 50);
  
  Padj(case1 & indP1) = 0.1*(Pow(case1 & indP1) - 50);
  Padj(case1 & indP2) = 1.25*(0.2525-0.1); %Slight positive since average contribution will be positive right at 50 rating
  Padj(case1 & indP3) = 0.2525*(Pow(case1 & indP3) - 50);
  
  Padj(case2 & indP1) = mean([0.1,0.2])*(Pow(case2 & indP1) - 50);
  Padj(case2 & indP2) = 1.25*(mean([0.2525,0.44])-mean([0.1,0.2])); %Slight positive since average contribution will be positive right at 50 rating
  Padj(case2 & indP3) = mean([0.2525,0.44])*(Pow(case2 & indP3) - 50);
  
  Padj(case3 & indP1) = 0.2*(Pow(case3 & indP1) - 50);
  Padj(case3 & indP2) = 1.25*(0.44-0.2); %Slight positive since average contribution will be positive right at 50 rating
  Padj(case3 & indP3) = 0.44*(Pow(case3 & indP3) - 50);
  
  BABIPnum = BABIPnum - Kadj - Padj; %Solve for remaining contact rating accounted for with BABIP Rating
  
  BAB1 = BABIPnum > 0; %Babip will be above 50
  BAB2 = BABIPnum <= 0; %Babip will be below 50
  
  BABIPRat(case1 & BAB1) = BABIPnum(case1 & BAB1)/0.7;
  BABIPRat(case1 & BAB2) = BABIPnum(case1 & BAB2)/0.6;
  
  BABIPRat(case2 & BAB1) = BABIPnum(case2 & BAB1)/mean([0.7, 0.8]);
  BABIPRat(case2 & BAB2) = BABIPnum(case2 & BAB2)/mean([0.6, 1.3]);
  
  BABIPRat(case3 & BAB1) = BABIPnum(case3 & BAB1)/0.8;
  BABIPRat(case3 & BAB2) = BABIPnum(case3 & BAB2)/1.3;
  
  if (iround) %Round to nearest 5?
    BABIPRat = divisor*round((BABIPRat + 50)/divisor);
  else
    BABIPRat = BABIPRat + 50;
  endif
endfunction
