function [trace2d,traceAmp,tracePhase] = spiralPhaseMapNullModel4(U,dV,t,params,rate,rpAll)
lowpass = params.lowpass;
gsmooth = params.gsmooth;
% rate = params.rate;
%%
if not(isempty(rpAll))
    rpAll1 = rpAll;
end
%%
nSV = size(U,3);
Fs = (1/median(diff(t)))*(1/rate);
x = size(U,1); y = size(U,2);
%%
Ur = reshape(U, size(U,1)*size(U,2), size(U,3));
%% trace re-construction
meanTrace = Ur*dV;
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
    if isempty(rpAll)
        rp2 = randperm(x*y);
        rpAll1(k,:) = rp2;
    else
        rp2 = rpAll1(k,:);
    end
    img_fft = fft2(im1);
    mag = abs(img_fft);
    phase = angle(img_fft); 
    phase = phase(rp2);
%     phase(indx) = phase(rp2);
    phasePerm  = reshape(phase,size(im1)); 
    meanTrace(:,:,k) = real(ifft2(mag .* exp(sqrt(-1)* phasePerm)));    
end
meanTrace = reshape(meanTrace,x*y, tsize);
%% filter 2-8Hz
meanTrace = meanTrace -mean(meanTrace ,2);
% filter and hilbert transform work on each column
meanTrace = meanTrace';
if lowpass
    [f1,f2] = butter(2, 0.2/(Fs/2), 'low');
else
    [f1,f2] = butter(2, [2 8]/(Fs/2), 'bandpass');
end
%%
meanTrace = filtfilt(f1,f2,meanTrace);
%%
traceHilbert =hilbert(meanTrace);
tracePhase = angle(traceHilbert);
traceAmp = abs(traceHilbert);
%%
tracePhase = reshape(tracePhase,tsize,x,y);
traceAmp = reshape(traceAmp,tsize,x,y);
trace2d = reshape(meanTrace,tsize,x,y);
%%
tracePhase = permute(tracePhase,[2,3,1]);
traceAmp = permute(traceAmp,[2,3,1]);
trace2d = permute(trace2d,[2,3,1]);
end