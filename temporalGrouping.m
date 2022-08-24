%% temporal grouping
%%
pwAll =unique(pwAll, 'rows');
pwAll = sortrows(pwAll,5);
%%
allFrames = unique(pwAll(:,end));
firstFrame = allFrames(1);
lastFrame = allFrames(end);
frameIterator =  lastFrame -firstFrame+1;
%%
% indx1 = find(allFrames == 65009);
indx1  = 1;
archiveCell = {};

cell1 = {};
cFrame = allFrames(indx1);
tic
for i = 1:frameIterator 
% for i = 1:100      
%     if cFrame == 9640
%         fprintf('pause');
%     end
    if isempty(cell1) 
        if numel(archiveCell)>100
            tempSpirals = cell2mat(archiveCell(end-100:end));
        else
            tempSpirals = cell2mat(archiveCell);
        end
        currentSpirals = pwAll(pwAll(:,end)==cFrame,:);
        if not(isempty(currentSpirals)) 
            % check if the currentSpiral has been grouped previously already
            % if not, then iterate through the remaining spirals, otehrwise skip.
            if not(isempty(tempSpirals)) 
            a = ismember(currentSpirals,tempSpirals,'rows');
                if sum(a)>0
                    currentSpirals = currentSpirals(~a,:);
                end
            end
%             if not(isempty(nextSpirals)) & isempty(remain) 
%                 currentSpirals = [];
%             end
        end
        if not(isempty(currentSpirals)) 
            % initialize cell1, newRound and newAdd
            rowDist = ones(1,size(currentSpirals,1));
            cell1 = mat2cell(currentSpirals,rowDist);
            newRound = zeros(numel(cell1),1);
            newAdd = zeros(numel(cell1),1);
        end
    elseif not(isempty(cell1)) & not(isempty(currentSpirals))  
        rowDist = ones(1,size(currentSpirals,1));
        cell2 = mat2cell(currentSpirals,rowDist);
        cell1 = [cell1;cell2];
        newRound = [newRound;zeros(size(currentSpirals,1),1)];
        newAdd = [newAdd;zeros(size(currentSpirals,1),1)];
        currentSpirals = [];
    end 
    % fprintf('Cells %g; newRound %g; newAdd %g\n', [numel(cell1),numel(newRound),numel(newAdd)]);
    newRound = newRound+1;
    %%
    nextFrame = cFrame+1;
    nextSpirals = pwAll(pwAll(:,end)==nextFrame,:);
    if not(isempty(nextSpirals)) & not(isempty(cell1))
        [archiveCell,cell1,currentSpirals,newRound,newAdd] = groupSpirals(archiveCell,cell1,nextSpirals,newRound,newAdd);
        % currentSpirals = currentSpirals;
    else
        currentSpirals = [];
    end   
    cFrame = cFrame+1;  
    T(i) = toc;
    if mod(i,1000)==0
        fprintf('Frame %g / totalFrame %g ; time elapsed %g seconds \n', [i,frameIterator,T(i)-T(i-999)]);
    end   
end
%% expected spirals numbers
% [pwIndx] = ismember(pwAll(:,end),allFrames(indx1):allFrames(indx1)+numel(allFrames)-1);
[pwIndx] = ismember(pwAll(:,end),allFrames(indx1):allFrames(indx1)+frameIterator);
epochSpirals = pwAll(pwIndx,:);
% grouped + ungrouped spiral numbers
groupedSpirals = [cell2mat([archiveCell;cell1]);currentSpirals];
groupedSpirals = sortrows(groupedSpirals,4);
%% check duplicates
[u,I,J] = unique(groupedSpirals, 'rows', 'first');
ixDupRows = setdiff(1:size(groupedSpirals,1), I);
dupRowValues = groupedSpirals(ixDupRows,:);
%% check missed spirals
[a,b] = ismember(pwAll,groupedSpirals,'rows');
missed = pwAll(~a,:);
%%
indx4 = cellfun(@(x) size(x,1), archiveCell);
figure; 
histogram(indx4)
%%
% figure; 
% for i = 1:150
%     subplot(15,10,i)
%     pwAllEpoch1 = archiveCell{i};
%     scatter(pwAllEpoch1(:,1),pwAllEpoch1(:,2),[],pwAllEpoch1(:,4),'filled');   
%     set(gca,'Ydir','reverse');
%     % set(gca, 'XTickLabel', '', 'YTickLabel', '')
%     xlim([0 512]); ylim([0 512]);
%     % axis equal;
%     % axis off; 
%     % box off;
% end
%%
indx2 = cellfun(@(x) size(x,1)>2, archiveCell);
groupedCells = archiveCell(indx2);
%%
filteredSpirals = cell2mat(groupedCells);
figure; histogram(filteredSpirals(:,3));
% ylim([0,30000]);
%% kernel density plot
figure; 
ax2 = subplot(1,1,1);
% imagesc(mimg);
% hold on
scatter_kde(filteredSpirals(:,1),filteredSpirals(:,2),'filled', 'MarkerSize', 5')
set(gca,'Ydir','reverse')
set(ax2, 'XTickLabel', '', 'YTickLabel', '');
xlim([0 512]); ylim([0 512]);
axis off; axis image
box off
colormap(ax2,parula)
%%
meanSpirals = cellfun(@(x) mean(x,1), groupedCells,'UniformOutput',false);
meanSpirals = cell2mat(meanSpirals);
indx5 = cellfun(@(x) size(x,1), groupedCells);
%% kernel density plot
figure; 
ax2 = subplot(1,1,1);
% imagesc(mimg);
% hold on
scatter_kde(meanSpirals (:,1),meanSpirals (:,2),'filled', 'MarkerSize', 5')
set(gca,'Ydir','reverse')
set(ax2, 'XTickLabel', '', 'YTickLabel', '');
xlim([0 512]); ylim([0 512]);
axis off; axis image
box off
colormap(ax2,parula)
%% scatter size plot
indx5 = log10(indx5-min(indx5)+1);
figure; 
ax2 = subplot(1,1,1);
scatter(meanSpirals (:,1),meanSpirals (:,2),3,meanSpirals (:,3),'filled')
% scatter(meanSpirals(:,1),meanSpirals(:,2),3,indx5,'filled')
set(gca,'Ydir','reverse')
set(ax2, 'XTickLabel', '', 'YTickLabel', '');
xlim([0 512]); ylim([0 512]);
axis off; axis image
box off
colormap(ax2,parula)
%%
roi1 = drawpolygon;
%%
tf = inROI(roi1,meanSpirals(:,1),meanSpirals(:,2));
selectedSpirals = groupedCells(tf);
%%
selectedSpirals = groupedCells(:);
%%
indx3 = cellfun(@(x) size(x,1)>10, selectedSpirals);
selectedSpirals3 = selectedSpirals(indx3);
%%
figure; 
for i = 1:numel(selectedSpirals3)
    subplot(10,9,i)
    pwAllEpoch1 = selectedSpirals3{i};
    scatter(pwAllEpoch1(:,1),pwAllEpoch1(:,2),5,pwAllEpoch1(:,5)-pwAllEpoch1(1,5),'filled');   
    set(gca,'Ydir','reverse');
    % set(gca, 'XTickLabel', '', 'YTickLabel', '')
    xlim([0 512]); ylim([0 512]);
    % axis equal;
    % axis off; 
    % box off;
end
%%
frameID2 = 197:213;
rate1 = 0.1;
[tracePhase, pwAllEpoch, cells] = upsampleEpoch(U1,dV,t,frameID2,params,rate1);
% pwAllEpoch1 = pwAllEpoch(pwAllEpoch(:,3)>50,:);
frameID = 1:size(tracePhase,3);
% save('frame197to213upsampled.mat','frameID','-append')
%%
frameID2 = 6804:6819;
rate1 = 0.1;
[tracePhase, pwAllEpoch, cells] = upsampleEpoch(U1,dV,t,frameID2,params,rate1);
% pwAllEpoch1 = pwAllEpoch(pwAllEpoch(:,3)>50,:);
frameID = 1:size(tracePhase,3);
% save('frame197to213upsampled.mat','frameID','-append')
%%
function  [archiveCell,cell1,remain,newRound,newAdd] = groupSpirals(archiveCell,cell1,nextSpirals,newRound,newAdd)
grouped = [];
% only use the spiral in the lastest frame for each group
lastSpiralsG = cell2mat(cellfun(@(x) x(end,:),cell1,'UniformOutput',false));
indx1 = (lastSpiralsG(:,end) < nextSpirals(1,end)-2);
lastSpiralsG(indx1,:)=nan;
if not(all(isnan(lastSpiralsG)))
    for j = 1:size(nextSpirals,1)
        tSpirals = nextSpirals(j,:); 
        if not(isnan(tSpirals))
            distance = vecnorm(lastSpiralsG(:,1:2)-tSpirals(1:2),2,2);
            [minV,indx] = min(distance,[],'omitnan');
            if minV<30
                cell1{indx} = [cell1{indx};tSpirals];
                newAdd(indx) = newAdd(indx)+1;
                grouped = [grouped;j];
            end 
        end
    end       
end
remain = nextSpirals(setdiff(1:end,grouped),:);
% lastSpiral = remain;
%%
newMiss = newRound-newAdd;
indxG =  (newRound>=3 & newMiss>=3);
if any(indxG)
    archiveCell = [archiveCell;cell1(indxG)];
    cell1 = cell1(~indxG);
    newRound = newRound(~indxG);
    newAdd = newAdd(~indxG);
end
end