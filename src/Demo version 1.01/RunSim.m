function avgTravelTime = RunSim(individuals,A,v,graphicDetail,awarenessType,nodeList,globalEventQueue,citySize,liveMap,spawnFunction)
    %Could maybe make this parallell? Otherwise, I think it might be enough
    %to make the pathfinding parallell if it will be using this function.
    adjMat = A(:,:,1);
    capacityMat = A(:,:,2);
    nCarsTraveled = 0;
    avgTravelTime = 0;
    spawnTime = 0;
    if awarenessType == 0
        awarenessTypeStr = "Shortest distance only. ";
    elseif awarenessType == 1
        awarenessTypeStr = "Shortest travel time for self. ";
    elseif awarenessType == 2
        awarenessTypeStr = "Shortest collective travel time. ";
    end
    while ~isempty(individuals)
        spawnTime = spawnTime + 1;
        spawnRate = spawnFunction(spawnTime);
        spawnRate = floor(spawnRate) + (rand < (spawnRate-floor(spawnRate)));
        for i = 1:spawnRate
            [individuals{end+1},liveMap] = SpawnSingle(A, awarenessType, nodeList, globalEventQueue, citySize, liveMap, spawnTime);
        end
        batchTravelTime = zeros(1,length(individuals));
        %Used so that all cars look at the same time step regardeless of order in the list. Also good for parallellisation.
        illegalPoints = [0;0;0]; %In order to follow the queue, cars later in the queue are not allowed to drive where a car earlier in the queue wasn't, even though someone has made way in the middle of the time step.
        for i = 1:length(individuals) %Update all individuals
            if i > length(individuals)
                break
            end
            individual = individuals{i};
            route = individual.route;
            routeStep = individual.routeStep;
            totTravelTime = individual.totTravelTime;
            roadProgress = individual.roadProgress;
            queueTime = individual.queueTime;
            haveDibs = individual.haveDibs;
            %Check if the car has finied and will be removed from the list,
            %or if it needs to calculate another time step.
            if routeStep < length(route) %Car still traveling
                fromNode = route(routeStep);
                toNode = route(routeStep + 1);
                if roadProgress >= adjMat(toNode,fromNode) %Reached end of road.
                    if routeStep >= length(route) - 1 %Next step is finish. No need to check capacity.
                        routeStep = routeStep + 1;
                    else
                        dibs = [toNode; route(routeStep+2) ;1]; %Unique identifier for point we wish to go to.
                        if individualsOnRoute(route(routeStep+2),toNode,1,individuals) + sum(all(illegalPoints == dibs))*(1-haveDibs) < capacityMat(route(routeStep + 2),toNode)
                            %Room on next time step
                            liveMap(toNode,fromNode) = liveMap(toNode,fromNode) - 1;
                            liveMap(route(routeStep+1),toNode) = liveMap(route(routeStep+1),toNode) + 1;
                            routeStep = routeStep + 1;
                            roadProgress = 1;
                            queueTime = 0;
                            haveDibs = 0;
                        else
                            %2^"fromNode" + 3^"toNode" + 5^"roadStep", but
                            %here we are checking next part of the route
                            if sum(all(illegalPoints == dibs)) < capacityMat(route(routeStep + 2),toNode)
                                illegalPoints(:,end+1) = dibs; %Unique identifier for combinations of nodes and progress.
                                haveDibs = 1;
                            else
                                haveDibs = 0;
                            end
                            queueTime = queueTime + 1;
                        end
                    end
                else
                    %Case where car wants to progress on current road, not
                    %yet at the end of it.
                    dibs = [fromNode ;toNode; roadProgress+1];
                    if individualsOnRoute(toNode,fromNode,roadProgress+1,individuals) + sum(all(illegalPoints == dibs))*(1-haveDibs) < capacityMat(toNode,fromNode)
                        roadProgress = roadProgress + 1;
                        queueTime = 0;
                        haveDibs = 0;
                    else
                        if sum(all(illegalPoints == dibs)) < capacityMat(toNode,fromNode)
                            illegalPoints(:,end+1) = dibs; %Unique identifier for combinations of nodes and progress.
                            haveDibs = 1;
                        else
                            haveDibs = 0;
                        end
                        queueTime = queueTime + 1;
                    end
                end
                %Individual has been moved and needs to be updated.
                individual.totTravelTime = totTravelTime + 1;
                individual.routeStep = routeStep;
                individual.roadProgress = roadProgress;
                individual.queueTime = queueTime;
                individual.haveDibs = haveDibs;
                individuals{i} = individual;
            else
                batchTravelTime(i) = individual.totTravelTime;
                individuals(i) = []; %Car is done and is removed from the list.
            end
        end
        
        avgTravelTime = avgTravelTime + sum(batchTravelTime);
        nCarsThisTimeStep = nnz(batchTravelTime);
        nCarsTraveled = nCarsTraveled + nCarsThisTimeStep;

        individualsPruned = cell(1,length(individuals)-nCarsThisTimeStep);
        queueTimes = zeros(1,length(individuals)-nCarsThisTimeStep);
        individualsRearranged = cell(1,length(individuals)-nCarsThisTimeStep);
        
        prunedEndIndex = 1;
        for i = 1:length(individuals)
            if ~isempty(individuals{i})
                individual = individuals{i};
                queueTimes(prunedEndIndex) = individual.queueTime;
                individualsPruned{prunedEndIndex} = individual;
                
                prunedEndIndex = prunedEndIndex + 1;
            end
        end
    
        prunedEndIndex = 1;
        for i = fliplr(0:max(queueTimes))
            [queueBool,index] = ismember(i,queueTimes);
            while queueBool
                individualsRearranged{prunedEndIndex} = individualsPruned{index};
                prunedEndIndex = prunedEndIndex + 1;
                queueTimes(index) = -1;
                [queueBool,index] = ismember(i,queueTimes);
            end
        end
        
        individuals = individualsRearranged;
        if graphicDetail == -1
            %No printout
        elseif graphicDetail == 0
            UpdateViewFast(individuals,A,v);
        elseif graphicDetail == 1
            UpdateView(individuals,A,v,0,awarenessTypeStr);
        elseif graphicDetail > 1
            UpdateView(individuals,A,v,graphicDetail,awarenessTypeStr);
        end
    end
    avgTravelTime = avgTravelTime / nCarsTraveled;
    
    disp("The average travel time was: " + num2str(avgTravelTime))
    
end