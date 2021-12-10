function a = NotAllFinished(individuals)
    a = 0;
    for i = 1:length(individuals)
        individual = individuals{i};
        route = individual.route;
        routeStep = individual.routeStep;
        if routeStep ~= length(route)
            a = 1;
            break
        end
    end
end