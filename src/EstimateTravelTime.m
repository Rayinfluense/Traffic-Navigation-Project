function travelTime = EstimateTravelTime(tail,head,awarenessType,liveMap,liveMapInCarsHead,edgeMatrix)
    % Constants
    NO_AWARENESS = 0;
    PRESENT_AWARENESS = 1;
    FUTURISTIC_AWARENESS = 2;

    LENGTH = 1;
    CAPACITY = 2;

    if awarenessType == NO_AWARENESS
        travelTime = edgeMatrix(head,tail,LENGTH);
    elseif awarenessType == PRESENT_AWARENESS
        waitingTime = max(0,(liveMap(head,tail)-edgeMatrix(head,tail,CAPACITY)));
        travelTime = edgeMatrix(head,tail,LENGTH) + waitingTime;
    elseif awarenessType == FUTURISTIC_AWARENESS
        waitingTime = max(0,(liveMapInCarsHead(head,tail)-edgeMatrix(head,tail,CAPACITY)));
        travelTime = edgeMatrix(head,tail,LENGTH) + waitingTime;
        edgeMatrix(:,:,LENGTH)
        fprintf('travelTime = %d, head = %d, tail = %d\n',travelTime,head,tail)
    else
        error('ERROR: Invalid awareness type!')
    end
end
                        