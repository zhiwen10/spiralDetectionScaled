%%
function [tracePhase1, pwAllEpoch, cells] = upsampleEpoch(U1,dV,t,frameID2,params, rate1)
% frameID2 = frameID(228:236);
pwAll = [];
%%
pwAll1 = []; pwAll2 = []; pwAll3 = []; pwAll4 = []; pwAll5 = [];
frameStart = frameID2(1);
frameEnd = frameID2(end);
frameTemp = frameStart-35:frameEnd+35; % extra 2*35 frames before filter data 
dV1 = dV(1:50,frameTemp);
t1 = t(frameTemp);
% rate1 = 0.1;
[trace2d1,traceAmp1,tracePhase1] = spiralPhaseMap4(U1,dV1,t1,params,rate1);
tracePhase1 = tracePhase1(:,:,1+35/rate1:end-35/rate1); % reduce 2*35 frames after filter data 
tracePhase = padZeros(tracePhase1,params.halfpadding); % pad tracephase with edge zeros
%%
nframe = size(tracePhase,3);
frameStart = 1;
pwAllEpoch = [];
for frame = 1:nframe
    pwAll1 = []; pwAll2 = []; pwAll3 = []; pwAll4 = []; pwAll5 = [];
    A = squeeze(tracePhase(:,:,frame));
    [pwAll1] = spiralAlgorithm(A,params);
    frameN = frame+frameStart-1;
    pwAll2 = checkClusterXY(pwAll1,params.dThreshold);
    [pwAll3] = doubleCheckSpiralsAlgorithm(A,pwAll2,params);
    [pwAll4] = spatialRefine(A,pwAll3,params);
    [pwAll5] = spiralRadiusCheck(A,pwAll4,params);
    pwAll5(:,4) = frameN; 
    pwAllEpoch = [pwAllEpoch;pwAll5];
end
pwAllEpoch = pwAllEpoch(pwAllEpoch(:,1)>0 & pwAllEpoch(:,2)>0,:);
pwAllEpoch(:,1:2) = pwAllEpoch(:,1:2)-params.halfpadding;
%%
frameID3 = 1:nframe;
rpadding = 20;
[cells] = getCellMain(tracePhase1,pwAllEpoch,frameID3,rpadding);
end