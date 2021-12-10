function UpdateViewFast(individuals,A,v)
    clf
    adjMat = A(:,:,1);
    capacityMat = A(:,:,2);
    G = graph(adjMat(:,:,1));
    p = plot(G, 'EdgeLabel', G.Edges.Weight);
    hold on
    X = p.XData;
    Y = p.YData;
    
    xPlotVec = zeros(1,length(individuals));
    yPlotVec = xPlotVec;
    for i = 1:length(individuals)
        %The order here should be based on queue, so that cars in front of
        %the list are the first to get on the next road.
        individual = individuals{i};
        route = individual.route;
        routeStep = individual.routeStep;
        roadProgress = individual.roadProgress;
        queueTime = individual.queueTime;
        identifier = individual.identifier;
        
        if routeStep + 1 <= length(route)
            fromNode = route(routeStep);
            toNode = route(routeStep + 1);
            vecToNode = [X(toNode) - X(fromNode),Y(toNode) - Y(fromNode)];
            roadProgressNorm = roadProgress / adjMat(toNode,fromNode);
            
            xPlotVec(i) = X(fromNode)+vecToNode(1)*roadProgressNorm;
            yPlotVec(i) = Y(fromNode)+vecToNode(2)*roadProgressNorm;
        else
            xPlotVec(i) = NaN;
            yPlotVec(i) = NaN;
        end
    end
    plot(xPlotVec,yPlotVec,'o')
    drawnow
    frame = getframe(gcf);
    writeVideo(v,frame)
end