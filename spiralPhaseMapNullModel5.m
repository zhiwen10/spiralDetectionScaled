function [trace2d,traceAmp,tracePhase] = spiralPhaseMapNullModel5(U1,dV1,t1,params,rate,rp)
lowpass = params.lowpass;
gsmooth = params.gsmooth;
% rate = params.rate;
%%
nSV = size(U1,3);
Fs = (1/median(diff(t1)))*(1/rate);
x = size(U1,1); y = size(U1,2);
%%
Ur = reshape(U1, size(U1,1)*size(U1,2), size(U1,3));
%% trace re-construction
meanTrace = Ur*dV1;
meanTrace = double(meanTrace);
tsize = size(meanTrace,2);
%%
if gsmooth
    meanTrace = reshape(meanTrace,x,y,tsize);
    for kk = 1:tsize
        I = squeeze(meanTrace(:,:,kk));
        meanTrace(:,:,kk) =  medfilt2(I,[20 20]);
    end
    meanTrace = reshape(meanTrace,x*y,tsize);
end
%%
if rate ~= 1
    tq = 1:rate:tsize;
    meanTrace = interp1(1:tsize,meanTrace',tq);
    meanTrace = meanTrace';
    tsize = numel(tq);
end
%% phase scramble
meanTrace = reshape(meanTrace,x,y,tsize);
%%
frNums = size(meanTrace,3);
for k = 1:frNums
    im1 = squeeze(meanTrace(:,:,k));    
    img_fft = fft2(im1);
    mag = abs(img_fft);
    phase = angle(img_fft); 
    if k == 1
        phasePerm = reshape(phase(rp), size(im1));
        oldPhase = phase;
        oldPermPhase = phasePerm;
    elseif k>1
        phaseUpdate = phase-oldPhase;
        phasePerm = oldPermPhase+phaseUpdate;
        oldPhase = phase;
        oldPermPhase = phasePerm;
    end
    meanTrace1(:,:,k) = real(ifft2(mag .* exp(sqrt(-1)* phasePerm)));    
end
%%
meanTrace1 = reshape(meanTrace1,x*y, tsize);
%% filter 2-8Hz
meanTrace1 = meanTrace1 -mean(meanTrace1 ,2);
% filter and hilbert transform work on each column
meanTrace1 = meanTrace1';
if lowpass
    [f1,f2] = butter(2, 0.2/(Fs/2), 'low');
else
    [f1,f2] = butter(2, [2 8]/(Fs/2), 'bandpass');
end
%%
meanTrace1 = filtfilt(f1,f2,meanTrace1);
%%
traceHilbert =hilbert(meanTrace1);
tracePhase = angle(traceHilbert);
traceAmp = abs(traceHilbert);
%%
tracePhase = reshape(tracePhase,tsize,x,y);
traceAmp = reshape(traceAmp,tsize,x,y);
trace2d = reshape(meanTrace1,tsize,x,y);
%%
tracePhase = permute(tracePhase,[2,3,1]);
traceAmp = permute(traceAmp,[2,3,1]);
trace2d = permute(trace2d,[2,3,1]);
end