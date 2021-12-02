function path = GetCarPath(car, awarenessType, nodeList, liveMap, edgeMatrix, globalEventQueue)
    % Constants
    TIME = 1;
    TYPE = 2;
    NODE_INDEX = 3;
    TAIL = 3;
    HEAD = 4;
    MIDDLE = 5;  
    
    EXPLORE_NODE = 0;   % Explore node event: [time 0 nodeIndex]
    SPAWN_CAR = 1;      % Spawn car event : [time 1 tail head]
    MOVE_CAR = 2;       % Move car event: [time 2 tail head middle]
    END_CAR = 3;        % End car event: [time 3 tail head]

    PREVIOUS_NODE = 2;
    EXPLORED = 3;

    path = [];
    n = size(edgeMatrix,1);
    liveMapInCarsHead = zeros(n,n); % Local map of current number of cars at each edge
    notebook = [-ones(n,2) zeros(n,1)]; % Row index of node found, column index: [timeWhenFound previousNode bool:explored]

    for carIndex = 1 : 1
        eventQueue = globalEventQueue.getCopy();
        notebook(car.spawnPoint,EXPLORED) = 1;
        eventQueue.insert([car.spawnTime EXPLORE_NODE car.spawnPoint]);
    
        while eventQueue.size() > 0 
            event = eventQueue.remove();
            tCarsMind = event(TIME);
    
            if event(TYPE) == EXPLORE_NODE
                currentNode = event(NODE_INDEX);
                
                if currentNode == car.goal % Goal found. From here no further exploring is needed.
                    time = notebook(currentNode,TIME);
                    previousNode = notebook(currentNode,PREVIOUS_NODE);
                    % Recordings
                    path = [previousNode currentNode];
                    globalEventQueue.insert([time END_CAR previousNode currentNode])

                    % Update values for "iteration 2"
                    frontNode = currentNode;
                    currentNode = previousNode;

                    % Backpropagate out the winning path from here
                    while currentNode ~= car.spawnPoint
                        time = notebook(currentNode,TIME);
                        previousNode = notebook(currentNode,PREVIOUS_NODE);
                        if time < 0
                            error("ERROR: Spawnpoint not found. Propagated backwards to negative time!")
                        end
                        % Recordings
                        path = [previousNode path];
                        globalEventQueue.insert([time MOVE_CAR previousNode frontNode currentNode])

                        % Update values for the next iteration
                        frontNode = currentNode;
                        currentNode = previousNode;
                    end
                    globalEventQueue.insert([0 SPAWN_CAR currentNode frontNode])

                    break; % Now the path should be extracted and we don't have to do more.

                else % If this node was not the goal
                    % Add outgoing nodes to the event queue
                    for i = 1 : length(nodeList(currentNode).outgoingNodes)
                        head = nodeList(currentNode).outgoingNodes(i);
                        if ~notebook(head,EXPLORED)
                            timeToGetThere = tCarsMind + EstimateTravelTime(currentNode,head,awarenessType,liveMap,liveMapInCarsHead,edgeMatrix);
                            eventQueue.insert([timeToGetThere EXPLORE_NODE head])
                            if notebook(head,TIME) > timeToGetThere || notebook(head,TIME) == -1 % If we found a shorter path to here or node unexplored.
                                notebook(head,TIME:PREVIOUS_NODE) = [timeToGetThere currentNode]; % To enable backpropagation when goal found.
                            end 
                        end
                    end
                    notebook(currentNode,EXPLORED) = 1; % Mark node as explored
                end
            % Code to move other cars
            elseif event(TYPE) == SPAWN_CAR
                liveMapInCarsHead(event(HEAD),event(TAIL)) = liveMapInCarsHead(event(HEAD),event(TAIL)) + 1;
            elseif event(TYPE) == MOVE_CAR
                liveMapInCarsHead(event(MIDDLE),event(TAIL)) = liveMapInCarsHead(event(MIDDLE),event(TAIL)) - 1;
                liveMapInCarsHead(event(HEAD),event(MIDDLE)) = liveMapInCarsHead(event(HEAD),event(MIDDLE)) + 1;
            elseif event(TYPE) == END_CAR
                liveMapInCarsHead(event(HEAD),event(TAIL)) = liveMapInCarsHead(event(HEAD),event(TAIL)) - 1;
            else
                error('Invalid event type!')
            end
        end
    end
end

