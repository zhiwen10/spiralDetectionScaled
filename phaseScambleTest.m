%%
img_fft = fft2(mimg);
mag = abs(img_fft);
phase = angle(img_fft); 
%%
cmin = min(mimg(:));
cmax = max(mimg(:));
%%
% indx = find(BW);
% rp1 = randperm(numel(indx));
% rp2 = indx(rp1); 
% phasePerm = phase;
% phasePerm(indx) = phase(rp2);

rp2 = randperm(size(mimg,1)*size(mimg,2));
phasePerm = phase(rp2);
phasePerm  = reshape(phasePerm,size(mimg));   

meanTrace2 = real(ifft2(mag .* exp(sqrt(-1) * phasePerm)));  
%%
figure; 
subplot(1,2,1)
histogram(phase(:))
subplot(1,2,2)
histogram(phasePerm(:))
%%
figure; 
subplot(1,2,1)
imagesc(phase)
colormap(hsv)
subplot(1,2,2)
imagesc(phasePerm)
colormap(hsv)
%%
figure; 
subplot(1,3,1)
imagesc(mimg)
caxis([cmin, cmax]);
subplot(1,3,2)
imagesc(meanTrace2)
caxis([cmin, cmax]);
% subplot(1,3,3)
% imshow(mag,[])