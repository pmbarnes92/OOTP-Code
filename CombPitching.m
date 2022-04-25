function [OvrPitching, vRPOut, vLPOut] = CombPitching (vRPOut, vLPOut, SPIP, LeftPct, AvgERA, OBAData, DScale)

vRPOut(:,1) = DScale*((-1*(vRPOut(:,2)-AvgERA)*(SPIP/9)/OBAData(13)) + vRPOut(:,5) + vRPOut(:,6)); %WAR scaled by DScale set at top of MainPred
vLPOut(:,1) = DScale*((-1*(vLPOut(:,2)-AvgERA)*(SPIP/9)/OBAData(13)) + vLPOut(:,5) + vLPOut(:,6)); %WAR

OvrPitching = vRPOut;
Range = [1,2,7:9];
OvrPitching(:,Range) = LeftPct*vLPOut(:,Range) + (1-LeftPct)*vRPOut(:,Range);

endfunction