function nodeList = GenerateAdjacencyList(adjacencyMatrix)
    nodeList = [];
    n = size(adjacencyMatrix,1);
    for i = 1 : n
        nodeList = [nodeList struct('outgoingNodes',[])];
        for j = 1 : n
            if adjacencyMatrix(i,j)
                nodeList(i).outgoingNodes = [nodeList(i).outgoingNodes j];
            end
        end
    end
end