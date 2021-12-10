function travelTime = EstimateTravelTime(awarenessType,numCars,futuristicNumCars,roadInfo)
    % Constants
    NO_AWARENESS = 0;
    PRESENT_AWARENESS = 1;
    FUTURISTIC_AWARENESS = 2;

    LENGTH = 1;
    CAPACITY = 2;

    if awarenessType == NO_AWARENESS
        travelTime = roadInfo(LENGTH);
    elseif awarenessType == PRESENT_AWARENESS
        waitingTime = max(0,(numCars-roadInfo(CAPACITY)));
        travelTime = roadInfo(LENGTH) + waitingTime;
    elseif awarenessType == FUTURISTIC_AWARENESS
        waitingTime = max(0,(futuristicNumCars-roadInfo(CAPACITY)));
        travelTime = roadInfo(LENGTH) + waitingTime;
        %fprintf('travelTime = %0.1f, head = %d, tail = %d\n',travelTime,head,tail)
    else
        error('ERROR: Invalid awareness type!')
    end
end
                        