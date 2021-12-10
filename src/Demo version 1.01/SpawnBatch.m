function [routes ,liveMap]= SpawnBatch(A, nCars, awarenessType, nodeList, globalEventQueue, citySize)
    rngSeed = randi(citySize,2,nCars);
    
    for i = 1:nCars
        while rngSeed(1,i) == rngSeed(2,i)
            rngSeed(2,i) = randi(citySize);
        end
    end
    
    routes = cell(1,nCars);
    liveMap = zeros(size(A(:,:,1)));
    for i = 1:nCars
        %Spawnpoint and goal needs to be more intelligently determined based on
        %city layout.
        spawnPoint = rngSeed(1,i); 
        goal = rngSeed(2,i);
        car = struct('spawnPoint',spawnPoint,'goal',goal,'route',[]);
        route = GetCarPath(0,car,awarenessType,nodeList,liveMap,A,globalEventQueue);
        routes{i} = route;
        liveMap(route(2),spawnPoint) = liveMap(route(2),spawnPoint)+ 1;
    end
end