function [individual ,liveMap] = SpawnSingle(A, awarenessType, nodeList, globalEventQueue, citySize, liveMap, spawnTime)
    rngSeed = randi(citySize,2,1);
    
    while rngSeed(1,1) == rngSeed(2,1)
        rngSeed(2,1) = randi(citySize);
    end
    
    route = [];

    %Spawnpoint and goal needs to be more intelligently determined based on
    %city layout.
    spawnPoint = rngSeed(1,1); 
    goal = rngSeed(2,1);
    car = struct('spawnPoint',spawnPoint,'goal',goal,'route',[]);
    route = GetCarPath(spawnTime,car,awarenessType,nodeList,liveMap,A,globalEventQueue);
    liveMap(route(2),spawnPoint) = liveMap(route(2),spawnPoint)+ 1;
    individual = struct('route',route,'routeStep',1,'roadProgress',1,'totTravelTime',0,'identifier',1,'queueTime',0,'haveDibs',0);

end