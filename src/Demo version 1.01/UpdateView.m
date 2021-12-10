function UpdateView(individuals,A,v,graphicDetail,awarenessTypeStr)
    
    %INTERPOLATE!!!!
    individualsInterpolated = individuals;
    linVec = linspace(1,0,graphicDetail+2);
    for interpolIndex = linVec(2:end-1)
        for i = 1:length(individuals)
            individual = individuals{i};
            if individual.queueTime == 0 %If it's moving, interpolate
                individual.roadProgress = individual.roadProgress-interpolIndex;
            end
            individualsInterpolated{i} = individual;
        end
        UpdateView(individualsInterpolated,A,v,0,awarenessTypeStr)
    end

    clf
    adjMat = A(:,:,1);
    capacityMat = A(:,:,2);
    G = graph(adjMat(:,:,1));
    capG = graph(capacityMat);
    LW = capG.Edges.Weight;
    p = plot(G,'LineWidth',LW,'Edgecolor','black','Nodelabel',{},'Marker','none');
    X = p.XData;
    Y = p.YData;
    hold on
    
    xPlotVecBlack = zeros(1,length(individuals));
    yPlotVecBlack = xPlotVecBlack;
    xPlotVecRed = xPlotVecBlack;
    yPlotVecRed = xPlotVecBlack;
    for i = 1:length(individuals)
        %The order here should be based on queue, so that cars in front of
        %the list are the first to get on the next road.
        individual = individuals{i};
        route = individual.route;
        routeStep = individual.routeStep;
        roadProgress = individual.roadProgress;
        queueTime = individual.queueTime;
        identifier = individual.identifier;
        tol = 0.002;
        laneWidth = 0.04;
        if routeStep + 1 <= length(route)
            fromNode = route(routeStep);
            toNode = route(routeStep + 1);
            vecToNode = [X(toNode) - X(fromNode),Y(toNode) - Y(fromNode)];
            ab = sign(vecToNode(1)*vecToNode(2));
            laneVec = [ab*1/vecToNode(1),-ab*1/vecToNode(2)];
            laneVec = laneVec/sqrt(laneVec(1).^2+laneVec(2).^2)*laneWidth;
            roadProgressNorm = roadProgress / adjMat(toNode,fromNode);
            point = [X(fromNode)+vecToNode(1)*roadProgressNorm,Y(fromNode)+vecToNode(2)*roadProgressNorm]+0.6*laneVec;
            
            goAgain = 1;
            while goAgain
                goAgain = 0;
                for j = 1:length(xPlotVecBlack)
                    if all(abs(point-[xPlotVecBlack(j),yPlotVecBlack(j)]) < tol)
                        point = point + laneVec;
                        goAgain = 1;
                        break
                    end
                    
                    if all(abs(point-[xPlotVecRed(j),yPlotVecRed(j)]) < tol)
                        point = point + laneVec;
                        goAgain = 1;
                        break
                    end
                end
            end
            
            if queueTime > 0
                xPlotVecBlack(i) = point(1);
                yPlotVecBlack(i) = point(2);
                xPlotVecRed(i) = NaN;
                yPlotVecRed(i) = NaN;
            else
                xPlotVecRed(i) = point(1);
                yPlotVecRed(i) = point(2);
                xPlotVecBlack(i) = NaN;
                yPlotVecBlack(i) = NaN;
            end
        else
            xPlotVecBlack(i) = NaN;
            yPlotVecBlack(i) = NaN;
            xPlotVecRed(i) = NaN;
            yPlotVecRed(i) = NaN;
        end
    end
    
    plot(xPlotVecBlack,yPlotVecBlack,'o','Color',[0.8,0,0],'MarkerSize',3)
    hold on
    plot(xPlotVecRed,yPlotVecRed,'o','Color',[0,0.5,0],'MarkerSize',3)
    title(num2str(length(individuals)) + " cars on the road. " + awarenessTypeStr)
    drawnow
    frame = getframe(gcf);
    writeVideo(v,frame)
    
end