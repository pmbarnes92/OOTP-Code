function [PosFitOvr, Err] = DefenseCalcs (DefRats, Pos, h, DefStats, iPos, iIFOF, RV, xvec)
  
if (strcmp(iPos{1},'P'))
  Outind = 9;
else
  Outind = 11;
endif
Outs = mod(DefStats(:,Outind),1)*10 + floor(DefStats(:,Outind))*3; %Convert IP to Outs

PosFitOvr = zeros(length(iPos),12);
Err = zeros(length(iPos),2); %mse and then R2

## % Range vs Total Chances Work
##TC = zeros(length(RV),1); 
##OP = TC;
##TCFit = zeros(length(iPos),2);
for j = 1:length(iPos)
    if (iIFOF(j) == 1) %Check if position is infield or outfield
      Rind = 1; %Range index
      Aind = 1:4; %All infield indices
    else
      Rind = 5;
      Aind = 5:7;
    endif
    

    %Overall regression
    if (strcmp(iPos{j},'P'))
      indreg = Outs > 0.25*max(Outs);
    else
      indreg = (strcmp(iPos{j},Pos) & Outs > 0.25*max(Outs)); %match pos and remove players with few outs played
    endif
    if (strcmp(iPos{j}, '1B')) %if first base normalize values by height
      normalizer1B = 1+(h(indreg)-155)/15;
      Vars = [(DefRats(indreg,Aind)-20).*normalizer1B, [(DefRats(indreg,Aind(1))-20).*(DefRats(indreg,Aind(2))-20), (DefRats(indreg,Aind(1))-20).*(DefRats(indreg,Aind(end))-20)].*(normalizer1B.^2), ones(sum(indreg),1)];
    else
      Vars = [DefRats(indreg,Aind), [DefRats(indreg,Aind(1)).*DefRats(indreg,Aind(2)), DefRats(indreg,Aind(1)).*DefRats(indreg,Aind(end))], ones(sum(indreg),1)];
    endif
    
    ZRpO = DefStats(indreg, 7)./Outs(indreg); %Zone Rating per Out
    Storvec = [Aind+(iIFOF(j)-1)*2,[(Aind(end)+1):(Aind(end)+2)]+(iIFOF(j)-1)*2, 12];
    PosFitOvr(j,Storvec) = lscov(Vars, ZRpO, Outs(indreg));
    Err(j,1) = sum((((Vars*(PosFitOvr(j,Storvec).')-ZRpO).*Outs(indreg))/mean(Outs(indreg))).^2)/length(ZRpO);
    Variance = sum((((ZRpO-mean(ZRpO)).*Outs(indreg))/mean(Outs(indreg))).^2)/length(ZRpO);
    %Err(j,2) = 1-Err(j,1)/(var(ZRpO)*(length(ZRpO)-1)/length(ZRpO));
    Err(j,2) = 1-Err(j,1)/Variance;
    
##    %Range vs Total Chances Work
##    for i = 1:length(RV)
##        ind = (DefRats(:,Rind) == RV(i) & strcmp(iPos{j},Pos));
##        TC(i) = sum(DefStats(ind,1)); %Total Chances
##        OP(i) = sum(Outs(ind)); %Outs Played      
##    end
##    TCpO = TC./OP;
##    valid = ~isnan(TCpO);
##    TCFit(j,:) = lscov(xvec(valid,:),TCpO(valid),OP(valid));
##    
##    if(iPlot == true)
##      figure;
##      scatter(RV,TCpO)
##      xlabel('Range Rating')
##      ylabel('TC')
##      title([iPos{j} ': Total Chances vs Range Rating'])
##      hold on;
##      plot(RV,TCFit(j,2)+RV.*TCFit(j,1));
##      legend('Data','WeightFit','Location','NorthWest')
##      hold off;
##    endif
end
  
## % Original Positional Rating vs Zone Rating Work from a while ago
##ZR = zeros(length(RV),1);
##IP = ZR;
##ZRFit = zeros(length(P),2);
##for j = 1:length(P)
##    for i = 1:length(RV)
##        ind = (Rat(:,30) == RV(i) & strcmp(P{j},Pos));
##        ZR(i) = sum(Stat(ind,37)); %Zone Rating
##        IP(i) = sum(Stat(ind,41)); %IP
##    end
##    ZRpO = ZR./IP;
##    figure;
##    scatter(RV,ZRpO)
##    xlabel('Position Rating')
##    ylabel('ZR')
##    title([P{j} ': ZR vs Position Rating'])
##    
##    valid = ~isnan(ZRpO);
##    ZRFit(j,:) = lscov(xvec(valid,:),ZRpO(valid),IP(valid));
##    hold on;
##    plot(RV,ZRFit(j,2)+RV.*ZRFit(j,1));
##    legend('Data','WeightFit','Location','NorthWest')
##    hold off;
##end
  
endfunction
