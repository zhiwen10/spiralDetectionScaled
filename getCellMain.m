%%
function [cells] = getCellMain(tracePhase,pwAll,frameID,halfpadding)
%%
xn = size(tracePhase,1); yn = size(tracePhase,2);
nframe = numel(frameID);
tracePhase1 = padZeros(tracePhase,halfpadding);
%%
k=1;
for i = 1:numel(frameID)
        frame = frameID(i);
        cellTemp = pwAll(pwAll(:,end) == frame,:);
        if ~isempty(cellTemp)
        %% first, pad zeros around the edges of the image       
            tracePhase2 = squeeze(tracePhase1(:,:,i));
            for j = 1:size(cellTemp,1)
                x = cellTemp(j,1); x1 = x+halfpadding; 
                y = cellTemp(j,2); y1 = y+halfpadding;
                cells(:,:,k) = tracePhase2(y1-halfpadding:y1+halfpadding,x1-halfpadding:x1+halfpadding); 
                k = k+1;
            end
        end
end
