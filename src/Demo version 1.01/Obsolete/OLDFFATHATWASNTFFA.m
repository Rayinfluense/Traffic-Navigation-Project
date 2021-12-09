%OBSOLETE
function individuals = OLDFFATHATWASNTFFA(nIndividuals,nRoutes, A)
    %This function should be based on the AdjMatrix so and somehow depend
    %on the city layout. For now it is hardcoded. 
    citySize = 4;
    adjMat = A(:,:,1);
    route = [1,2]; %Individual 1 wants to go form 1 to 2, then back to 1.
    routeStep = 1;
    roadProgress = 1;
    totTravelTime = 0;
    queueTime = 0;
    identifier = 1;
    haveDibs = 0;
    individual1 = struct('route',route,'routeStep',routeStep,'roadProgress',roadProgress,'totTravelTime', totTravelTime,'identifier',identifier,'queueTime',queueTime,'haveDibs',haveDibs);
    
    for i = 1:nIndividuals
        route = zeros(1,nRoutes);
        route(1) = randi(citySize);
        for j = 2:nRoutes
            if route(j-1) == 3
                r = 1;
            else
                r = randi(citySize);
                while r == route(j-1)
                   r = randi(citySize); 
                end
            end
            
            if j > 2
                while route(j-2) == r || route(j-1) == r
                    r = randi(citySize);
                end
            end
            route(j) = r;
        end
        individual1.route = route;
        individual1.identifier = i;
        individual1.roadProgress = 1;
        individuals{i} = individual1;
    end
end