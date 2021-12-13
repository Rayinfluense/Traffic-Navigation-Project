clear all
clc
close all
rng('default');
rng(5);

%Parameters to edit:
%---------------------------------------
%Graphic detail = 3 or 15 is recommended.
graphicDetail = 15; %-1 is no graphics, 0 Is simple mode, 1 is advanced printout, 2 + is advanced printout with interpolation for graphicDetail interpolation steps.
set(gcf, 'Position', [0,50,640,1080])
citySize = 13; %MUST BE ODD APPARENTLY
nIndividuals = round((citySize^2)*(4+1*rand));
spawnFunction = @(t) (citySize)*(rand/4+1.5)*exp(-t/25);
awarenessType = 0; %I'm guessing this will be set once for the entire simulation.
%---------------------------------------

v = VideoWriter('hej','MPEG-4');
v.FrameRate = max(4,2*graphicDetail);
open(v);
[adjMat,capacityMat] = RS_RoadGen(citySize);
citySize = length(adjMat);
G = graph(adjMat(:,:,1));
capg = graph(capacityMat);
LW = capg.Edges.Weight;
A(:,:,1) = adjMat;
A(:,:,2) = capacityMat;
nodeList = GenerateAdjacencyList(adjMat); %Simply calculated once. Can still be moved to a dedicated summoning function.
globalEventQueue = PriorityQueue(1); %Magic function. No need to update.
[routes ,liveMap]= SpawnBatch(A, nIndividuals, awarenessType, nodeList, globalEventQueue, citySize);
individuals = cell(1,nIndividuals); 
for i = 1:nIndividuals
    individuals{i} = struct('route',routes(i),'routeStep',1,'roadProgress',1,'totTravelTime',0,'identifier',1,'queueTime',0,'haveDibs',0);
end
avgTravelTime = RunSim(individuals,A,v,graphicDetail,awarenessType,nodeList,globalEventQueue,citySize,liveMap,spawnFunction);
title("Average travel time was: " + num2str(avgTravelTime) + " units.")
drawnow
frame = getframe(gcf);
for i = 1:2*v.FrameRate
    writeVideo(v,frame)
end
close(v);
