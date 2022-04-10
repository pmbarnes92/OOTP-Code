function  NoOutput = PrintRes (Outfile, Results, WARList, indList, Names, TabName1,TabName2)

Table1 = cell(size(Results,1),size(Results,2)+1);
Table1(:,1) = {'Pos';'C';'1B';'2B';'3B';'SS';'LF';'CF';'RF';'DH'};

for i = 1:(size(Results,2)/2)
  Table1(1,2*i) = 'Name';
  Table1(2:end,2*i) = Names(Results(2:end,2*i-1));
  Table1(:,2*i+1) = num2cell(Results(:,2*i));
endfor
xlswrite(Outfile, Table1, TabName1);
pause(1);

Table2 = cell(size(indList,1)+1,size(indList,2)*2);
Table2(1,:) = {'Names','C','Names','1B','Names','2B','Names','3B','Names','SS','Names','LF','Names','CF','Names','RF','Names','DH'};
for j = 1:(size(indList,2))
  Table2(2:end,2*j-1) = Names(indList(:,j));
  Table2(2:end,2*j) = num2cell(WARList(:,j));
endfor
xlswrite(Outfile,Table2,TabName2);

NoOutput = 1;
endfunction
