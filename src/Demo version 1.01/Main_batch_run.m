clear all
clc
seedVec = 1:2;
citySizeVec = [7,13,17];
avgTravelTimeMultRuns = zeros(length(citySizeVec),3); %An avg for each awarenessType.
seedLength = length(seedVec);
normalizeMat = ones(length(citySizeVec),3)*seedLength;
progress = 0;
for seed = seedVec
    for citySizeCount = 1:length(citySizeVec)
        cityLength = citySizeVec(citySizeCount);
        progress = progress + 1;
        disp("Progress: " + num2str(progress/(length(seedVec)*length(citySizeVec))))
        for awarenessType = 0:2
            %close all
            rng('default');
            rng(seed);
            %Parameters to edit:
            %---------------------------------------
            %Graphic detail = 3 or 15 is recommended.
            graphicDetail = -1; %-1 is no graphics, 0 Is simple mode, 1 is advanced printout, 2 + is advanced printout with interpolation for graphicDetail interpolation steps.
            %set(gcf, 'Position', [50,50,1600,900])
            %citySize = 17; %MUST BE ODD APPARENTLY
            nIndividuals = round((cityLength^2)*(3.8+1*rand));
            spawnFunction = @(t) (cityLength)*(rand/4+1.4)*exp(-t/20);
            %awarenessType = 0; %I'm guessing this will be set once for the entire simulation.
            %---------------------------------------

            v = NaN;
            %v.FrameRate = max(4,2*graphicDetail);
            %open(v);
            [adjMat,capacityMat] = RS_RoadGen(cityLength);
            citySize = length(adjMat);
            G = graph(adjMat(:,:,1));
            capg = graph(capacityMat);
            LW = capg.Edges.Weight;
            A = [];
            A(:,:,1) = adjMat;
            A(:,:,2) = capacityMat;
            nodeList = GenerateAdjacencyList(adjMat); %Simply calculated once. Can still be moved to a dedicated summoning function.
            globalEventQueue = PriorityQueue(1); %Magic function. No need to update.
            [routes ,liveMap]= SpawnBatch(A, nIndividuals, awarenessType, nodeList, globalEventQueue, citySize);
            individuals = cell(1,nIndividuals); 
            for i = 1:nIndividuals
                individuals{i} = struct('route',routes(i),'routeStep',1,'roadProgress',1,'totTravelTime',0,'identifier',1,'queueTime',0,'haveDibs',0);
            end
            disp("For citySize: " + num2str(cityLength))
            avgTravelTime = RunSim(individuals,A,v,graphicDetail,awarenessType,nodeList,globalEventQueue,citySize,liveMap,spawnFunction);
            title("Average travel time was: " + num2str(avgTravelTime) + " units.")
            %drawnow
            %frame = getframe(gcf);
            %for i = 1:2*v.FrameRate
            %    writeVideo(v,frame)
            %end
            %close(v);
            avgTravelTimeMultRuns(citySizeCount,awarenessType+1) = avgTravelTimeMultRuns(citySizeCount,awarenessType+1) + avgTravelTime;
            if avgTravelTime == 0 %If the run got stuck.
                normalizeMat(citySizeCount,awarenessType+1) = normalizeMat(citySizeCount,awarenessType+1) - 1;
            end
        end
    end
end

avgTravelTimeMultRuns = avgTravelTimeMultRuns ./ normalizeMat;

for i = 1:length(citySizeVec)
    subplot(1,length(citySizeVec),i)
    bar(avgTravelTimeMultRuns(i,:))
    xlabel('Awareness Type')
    ylabel("Average Travel Time")
    title("City size: " + num2str(citySizeVec(i)))
    axis([0 4 40 150])
end
