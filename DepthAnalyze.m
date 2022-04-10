function [Results, WARList, indList] = DepthAnalyze (Data, numlineup)

Data(isnan(Data)) = -99; %Replace isnan values with -99

Listsize = max(numlineup,9);
indList = zeros(Listsize, size(Data,2)); %Store indices of players to check
WARList = zeros(Listsize, size(Data,2)); %Store WAR of players we care about

for k = 1:size(Data,2)
  [Sort, ind] = sort(Data(:,k),'descend');
  indList(:,k) = ind(1:Listsize);
  WARList(:,k) = Sort(1:Listsize);
endfor

Results = zeros(10,2*numlineup); %Store lineup results and war
ResStored = ones(9,1);

for a=1:Listsize
  if (ResStored(1) == 0)
     break;
  endif
  ResStored(1) = 0;
  ResStored(2) = 1;
  
  indvec = zeros(10,1);
  WARvec = indvec;
  indvec(2) = indList(a,1);
  WARvec(2) = WARList(a,1);
  for b = 1:Listsize
    if (ResStored(2) == 0)
       break;
    endif
    if (isempty(find(indvec(2) == indList(b,2))) == 0) %Check for repeated player
        ResStored(1) = 1;
       continue;
    endif
    ResStored(2) = 0;
    ResStored(3) = 1;
    
    indvec(3) = indList(b,2);
    WARvec(3) = WARList(b,2);
    for c = 1:Listsize
      if (ResStored(3) == 0)
         break;
      endif
      if (isempty(find(indvec(2:3) == indList(c,3))) == 0) %Check for repeated player
          Resind = find(indvec(2:3) == indList(c,3));
          ResStored(Resind) = 1;
          continue;
      endif
      ResStored(3) = 0;
      ResStored(4) = 1;
      
      indvec(4) = indList(c,3);
      WARvec(4) = WARList(c,3);
      for d = 1:Listsize
        if (ResStored(4) == 0)
           break;
        endif
        if (isempty(find(indvec(2:4) == indList(d,4))) == 0) %Check for repeated player
            Resind = find(indvec(2:4) == indList(d,4));
            ResStored(Resind) = 1;
           continue;
        endif
        ResStored(4) = 0;
        ResStored(5) = 1;
        
        indvec(5) = indList(d,4);
        WARvec(5) = WARList(d,4);
        for e = 1:Listsize
          if (ResStored(5) == 0)
             break;
          endif
          if (isempty(find(indvec(2:5) == indList(e,5))) == 0) %Check for repeated player
              Resind = find(indvec(2:5) == indList(e,5));
              ResStored(Resind) = 1;
             continue;
          endif
          ResStored(5) = 0;
          ResStored(6) = 1;
          
          indvec(6) = indList(e,5);
          WARvec(6) = WARList(e,5);
          for f = 1:Listsize
            if (ResStored(6) == 0)
               break;
            endif
            if (isempty(find(indvec(2:6) == indList(f,6))) == 0) %Check for repeated player
                Resind = find(indvec(2:6) == indList(f,6));
                ResStored(Resind) = 1;
              continue;
            endif
            ResStored(6) = 0;
            ResStored(7) = 1;
            
            indvec(7) = indList(f,6);
            WARvec(7) = WARList(f,6);
            for g = 1:Listsize
              if (ResStored(7) == 0)
                break;
              endif
              if (isempty(find(indvec(2:7) == indList(g,7))) == 0) %Check for repeated player
                  Resind = find(indvec(2:7) == indList(g,7));
                  ResStored(Resind) = 1;
                 continue;
              endif
              ResStored(7) = 0;
              ResStored(8) = 1;
              
              indvec(8) = indList(g,7);
              WARvec(8) = WARList(g,7);
              for h = 1:Listsize
                if (ResStored(8) == 0)
                  break;
                endif
                if (isempty(find(indvec(2:8) == indList(h,8))) == 0) %Check for repeated player
                    Resind = find(indvec(2:8) == indList(h,8));
                    ResStored(Resind) = 1;
                   continue;
                endif
                ResStored(8) = 0;
                ResStored(9) = 1;
                
                indvec(9) = indList(h,8);
                WARvec(9) = WARList(h,8);
                for i = 1:Listsize %Designated Hitter
                  if (ResStored(9) == 0)
                    break;
                  endif
                  if (isempty(find(indvec(2:9) == indList(i,9))) == 0) %Check for repeated player
                    Resind = find(indvec(2:9) == indList(i,9));
                    ResStored(Resind) = 1;
                    continue;
                  endif
                  ResStored(9) = 0;
                  
                  indvec(10) = indList(i,9);
                  WARvec(10) = WARList(i,9);
                  
                  WARval = sum(WARvec(2:10));
                  
                  for j = 1:numlineup
                    if (Results(1,2*j) < WARval)
                      if (j == numlineup) %Stored in Last Place
                        Results(:,[2*j-1,2*j]) = [indvec, WARvec]; %Set new results
                        Results(1,2*j) = WARval;
                      else
                        ResStored(:) = 1;
                        Results(:,(2*j+1):end) = Results(:,(2*j-1):(end-2)); %Push results back
                        Results(:,[2*j-1,2*j]) = [indvec, WARvec]; %Set new results
                        Results(1,2*j) = WARval;
                        break; %Don't check lower values
                      endif
                    endif
                  endfor
                  
                endfor
              endfor
            endfor
          endfor
        endfor
      endfor
    endfor
  endfor
endfor

endfunction
