function n = individualsOnRoute(toNode,fromNode,roadProgress,individuals)
    n = 0;
    for i = 1:length(individuals)
        individual = individuals{i};
        if ~isempty(individual)
            route = individual.route;
            routeStep = individual.routeStep;

            if routeStep + 1 <= length(route)
                fromNodeCompare = route(routeStep);
                toNodeCompare = route(routeStep + 1);
                roadProgressCompare = individual.roadProgress;
                if fromNodeCompare == fromNode && toNodeCompare == toNode && roadProgressCompare == roadProgress
                   n = n + 1;
                end
            end    
        end
    end
end