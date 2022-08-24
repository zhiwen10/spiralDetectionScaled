function [pwAll3] = spiralRadiusCheck(tracePhase,pwframe,params)
th = params.th;
spiralRange = params.spiralRange;
rsRCheck = params.rsRCheck;

pwAll3 = [];
for ixy = 1:size(pwframe,1)
    px = pwframe(ixy,1); py = pwframe(ixy,2);
    % rs1 = 10:10:100;
    spiralR = zeros(numel(rsRCheck),1);
    for ii = 1:numel(rsRCheck)
            r = rsRCheck(ii);
            cx = round(r*cosd(th)+px);
            cy = round(r*sind(th)+py); 
            %%
            ph = tracePhase(sub2ind(size(tracePhase),cy, cx));
            phdiff = angdiff(ph);
            ph2(1) = ph(1);
            for i = 2:numel(ph)                
                ph2(i) = [ph2(i-1)+phdiff(i-1)];
            end 
            ph2 = ph2-ph2(1);
            ph3 = abs(ph2);                
            [N,edges] = histcounts(ph,spiralRange);
            AngleRange = ph3(end);       
            if AngleRange>4 & AngleRange<8 & all(N)
                spiralR(ii) = 1;
            end
    end
    if sum(spiralR)>0
        maxR = max(rsRCheck(logical(spiralR)));
        pwTemp = [px,py,maxR];
        pwAll3 = [pwAll3;pwTemp];
    end
end