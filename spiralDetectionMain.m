githubdir2 = 'C:\Users\Steinmetz lab\Documents\git';
addpath(genpath(fullfile(githubdir2, 'spikes')))
addpath(genpath(fullfile(githubdir2, 'Pipelines')))
addpath(genpath(fullfile(githubdir2, 'NeuroPattToolbox'))) %https://github.com/BrainDynamicsUSYD/NeuroPattToolbox
addpath(genpath(fullfile(githubdir2, 'widefield')))
addpath(genpath(fullfile(githubdir2, 'npy-matlab')))
addpath(genpath('C:\Users\Steinmetz lab\Documents\MATLAB\widefield_DIY\spiralDetection'))
%% SVD, plot example trace, overlay with pupil and stim time
% specify folder for widefield image data
% mn = 'ZYE_0012'; td = '2020-10-16'; en = 5;
mn = 'AB_0004'; td = '2021-03-30'; en = 1;
serverRoot = expPath(mn, td, en);
wf_svd;
%%
params.downscale = 1; % downscale factor for each frame to process faster, by sacrificing resolution
params.lowpass = 0; % 1 is low pass filter <0.2Hz, 0 is bandpass filter between 2-8Hz
params.Fs = 35; % frame sampling rate
params.halfpadding = 120; % half padding shoudl be the max spiral detection radius 
params.padding = 2*params.halfpadding;
params.th = 1:36:360; 
params.rs = 10:5:20;
params.gridsize = 10;
params.spiralRange = linspace(-pi,pi,5);
params.gsmooth = 0;
params.epochL = 100;
params.nt = numel(t);
frameN1 = round((params.nt-70)/100)*100;
params.frameRange = 36:params.epochL:(36+frameN1-1);
params.dThreshold = 15;
params.rsRCheck = 10:10:100;
%% roi grid
% only look around roi with gridsize radius
[params.pgridx,params.pgridy] = meshgrid(21-10:21+10, 21-10:21+10);
%%
U1 = U(1:params.downscale:end,1:params.downscale:end,1:50);
params.xsize = size(U1,1);
params.ysize = size(U1,2);
xsizePadded = params.xsize+params.padding; ysizePadded = params.ysize+params.padding;
[xx,yy] = meshgrid(min(params.rs)+1:params.gridsize:xsizePadded-min(params.rs)-1, ...
    min(params.rs)+1:params.gridsize:ysizePadded-min(params.rs)-1);
params.xx = xx; params.yy = yy;
%% apply mask, this helps speed up spiral detection later
mimg1 = mimg(1:params.downscale:end,1:params.downscale:end);
mimg2 = padZeros(mimg1,params.halfpadding);
figure; 
ax1 = imagesc(mimg2);
roi = drawpolygon;
tf = inROI(roi,xx(:),yy(:));
params.xxRoi = xx(tf); 
params.yyRoi =yy(tf);
rate = 1;
%%
pwAll = [];
for kk = 1:numel(params.frameRange)-1
% for kk=1:2
    tic
    pwAll1 = []; pwAll2 = []; pwAll3 = []; pwAll4 = []; pwAll5 = [];
    frameStart = params.frameRange(kk);
    frameEnd = frameStart+params.epochL-1;
    frameTemp = frameStart-35:frameEnd+35; % extra 2*35 frames before filter data 
    dV1 = dV(1:50,frameTemp);
    t1 = t(frameTemp);
    [trace2d1,traceAmp1,tracePhase1] = spiralPhaseMap4(U1,dV1,t1,params,rate);
    tracePhase1 = tracePhase1(:,:,1+35:end-35); % reduce 2*35 frames after filter data 
    tracePhase = padZeros(tracePhase1,params.halfpadding); % pad tracephase with edge zeros
    %%
    nframe = size(tracePhase,3);
    for frame = 1:nframe
        A = squeeze(tracePhase(:,:,frame));
        [pwAll1] = spiralAlgorithm(A,params);
        frameN = frame+frameStart-1;
        pwAll2 = checkClusterXY(pwAll1,params.dThreshold);
        [pwAll3] = doubleCheckSpiralsAlgorithm(A,pwAll2,params);
        [pwAll4] = spatialRefine(A,pwAll3,params);
        [pwAll5] = spiralRadiusCheck2(A,pwAll4,params);
        if not(isempty(pwAll5))
            pwAll5(:,end+1) = frameN; 
        end
        pwAll = [pwAll;pwAll5];
    end
    fprintf('Frame %g/%g; time elapsed %g seconds \n', [frameStart,frameN1, toc])
end
%%
% pwAll = pwAll(pwAll(:,1)>0 & pwAll(:,2)>0,:);
pwAll(:,1:2) = pwAll(:,1:2)-params.halfpadding;
%% sanity check
frame2 = 36:236; framei = 150;
rate1 = 1;
spiralSanityCheck;
%% kernel density plot
figure; 
ax2 = subplot(1,1,1);
% imagesc(mimg);
% hold on
scatter_kde(pwAll(:,1),pwAll(:,2),'filled', 'MarkerSize', 5')
set(gca,'Ydir','reverse')
set(ax2, 'XTickLabel', '', 'YTickLabel', '');
xlim([0 512]); ylim([0 512]);
axis off; axis image
box off
colormap(ax2,parula)
%% epoch spirals
tStart = 1860; tEnd = 1870; % find spirals between time tStart:tEnd
frameS = find(t>tStart,1,'first'); frameE = find(t>tEnd,1,'first');
frameID = frameS:frameE;
rate1 = 1;
[tracePhase, pwAllEpoch, cells] = upsampleEpoch(U1,dV,t,frameID,params, rate1);
%% epoch spirals upsampled
frameID2 = frameID(228:236);
rate1 = 0.1;
[tracePhase, pwAllEpoch, cells] = upsampleEpoch(U1,dV,t,frameID2,params, rate1);
pwAllEpoch1 = pwAllEpoch(pwAllEpoch(:,3)>50,:);
%%
figure; scatter(pwAllEpoch1(:,1),pwAllEpoch1(:,2),pwAllEpoch1(:,3),pwAllEpoch1(:,4),'filled');
set(gca,'Ydir','reverse')
set(gca, 'XTickLabel', '', 'YTickLabel', '');
xlim([0 512]); ylim([0 512]);
axis off; axis image
box off;