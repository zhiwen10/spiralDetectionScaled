%%
th = [1:36:360]; 
%%
frameTemp = frame2(1)-35:frame2(end)+35; % extra 2*35 frames before filter data 
dV1 = dV(1:50,frameTemp);
t1 = t(frameTemp);    
[trace2d2,traceAmp2,tracePhase2] = spiralPhaseMapNullModel5(U1,dV1,t1,params,rate1,rp);
tracePhase2 = tracePhase2(:,:,1+35:end-35); % reduce 2*35 frames after filter data 
%%
figure;
imagesc(squeeze(tracePhase2(:,:,framei)));
colormap(hsv)
hold on; 
framei = frame2(framei);
pwi = pwAll(pwAll(:,end)==framei,:);
hold on;
scatter(pwi(:,1),pwi(:,2),32,'w','filled');
for i = 1:size(pwi,1)
    px = pwi(i,1);
    py = pwi(i,2);
    cx = round(pwi(i,3)*cosd(th)+px);
    cy = round(pwi(i,3)*sind(th)+py); 
    if pwi(i,4)==1
        c = 'k';
    else
        c = 'r';
    end
    hold on;
    scatter(cx,cy,16,c,'filled')
end
    
