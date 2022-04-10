function NoOutput = WritePredOutput (file, sheet, Data, ColHead, RowHead)
  
  %Writes Standard Output with row and column headers (uses 3 spaces for row header (Pos, Name, Hand))
  xlswrite(file,Data,sheet,'D2');
  xlswrite(file,ColHead,sheet,'A1');
  xlswrite(file,RowHead,sheet,'A2');
  pause(1);
  NoOutput = 1;

endfunction
