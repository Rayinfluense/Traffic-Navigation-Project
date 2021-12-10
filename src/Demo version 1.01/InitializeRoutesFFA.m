function individuals = InitializeRoutesFFA(nIndividuals, A)
    %This function should be based on the AdjMatrix so and somehow depend
    %on the city layout. For now it is hardcoded. 
    individuals = {};
    for i = 1:nIndividuals
        %We want to change this to some sort of distribution that depends
        %on the city itself. For now it's completely random.
        start = randi(length(A(:,:,1)));
        finish = randi(length(A(:,:,1)));
        
        individual = struct()
    end
end