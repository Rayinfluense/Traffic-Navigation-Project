
function [AdjMat,CapMat] = RS_RoadGen(gridSize)
%gridSize = 11; % Must be an odd number

% Defines the grid
[X, Y] = meshgrid(-3:3/((gridSize - 1)/2):3, -3:3/((gridSize - 1)/2):3);

% Defines the underlying vector field
U = -abs(sin(X + Y));
V = abs(cos(X - Y));

% Plots the underlying vector field for debugging
% quiver(X,Y,U,V,'r')
% hold on;

% Shifts the grid along the vector field and randomly with probability p
p = 0.1;
for i = 1:gridSize
    for j = 1:gridSize
        X(i, j) = X(i, j) + 0.4*U(i, j);
        Y(i, j) = Y(i, j) + 0.4*V(i, j);
        r = rand;
        if (r < p)
            X(i, j) = X(i, j) + 0.1*rand;
        end
        r = rand;
        if (r < p)
            Y(i, j) = Y(i, j) + 0.1*rand;
        end
    end
end

% Defines occupied nodes and edges
occupiedNodes = X*0;
boundaryNodes = X*0;
boundaryNodes(1, :) = 1;
boundaryNodes(end, :) = 1;
boundaryNodes(:, 1) = 1;
boundaryNodes(:, end) = 1;

%%%%%%%%%%%%%%%%%%%%%% Generates first large road (highway)
X1 = (gridSize - 1)/2;
Y1 = (gridSize - 1)/2;
x1 = X(X1, Y1);
y1 = Y(X1, Y1);

p = 0.99;

newOccupiedNodes = occupiedNodes;
for i = 2:(3*gridSize)
    r = rand;
    if (p > r)
        r2 = randi([0 1]);
        if (boundaryNodes(X1 + 2*r2 - 1, Y1) == 0)
            X1 = X1 + 2*r2 - 1;
            p = 0.99;
        end
    else
        r2 = randi([0 1]);
        if (boundaryNodes(X1, Y1 + 2*r2 - 1) == 0)
            Y1 = Y1 + 2*r2 - 1;
            p = 0.01;
        end
    end
    x1(i) = X(X1, Y1);
    y1(i) = Y(X1, Y1);
    newOccupiedNodes(X1, Y1) = 1;
end

occupiedNodes = newOccupiedNodes;

 %   plot(x1, y1, 'black', 'LineWidth', 3);
    hold on;
    road1xCoordinates{1} = x1;
    road1yCoordinates{1} = y1;

%%%%%%%%%%%%%%%%%%%%%% Generates more large roads (highways)
for q = 1:2

X1 = 1 + randi(gridSize - 2);
Y1 = 1 + randi(gridSize - 2);
x2 = X(X1, Y1);
y2 = Y(X1, Y1);

p = 0.99;

newOccupiedNodes = occupiedNodes;
i = 1;
while(true)
    i = i + 1;
    r = rand;
    if (p > r)
        r2 = randi([0 1]);
        if (boundaryNodes(X1 + 2*r2 - 1, Y1) == 0)
            X1 = X1 + 2*r2 - 1;
            p = 0.99;
        end
    else
        r2 = randi([0 1]);
        if (boundaryNodes(X1, Y1 + 2*r2 - 1) == 0)
            Y1 = Y1 + 2*r2 - 1;
            p = 0.01;
        end
    end
    x2(i) = X(X1, Y1);
    y2(i) = Y(X1, Y1);
    newOccupiedNodes(X1, Y1) = 1;
    if (occupiedNodes(X1, Y1) == 1)
        break;
    end
end

occupiedNodes = newOccupiedNodes;

%    plot(x2, y2, 'black', 'LineWidth', 2);
    hold on;
    road2xCoordinates{q} = x2;
    road2yCoordinates{q} = y2;
end

%%%%%%%%%%%%%%%%%%%%%% Generates many small roads (streets)
for q = 1:(38*gridSize)

X1 = 1 + randi(gridSize - 2);
Y1 = 1 + randi(gridSize - 2);
x3 = X(X1, Y1);
y3 = Y(X1, Y1);

newOccupiedNodes = occupiedNodes;
i = 1;
while(true)
    i = i + 1;
    r = randi([0 1]);
    if (r == 1)
        r2 = randi([0 1]);
        if ((X1 + 2*r2 - 1) > 0 && (X1 + 2*r2 - 1) < gridSize + 1)
            X1 = X1 + 2*r2 - 1;
        end
    else
        r2 = randi([0 1]);
        if ((Y1 + 2*r2 - 1) > 0 && (Y1 + 2*r2 - 1) < gridSize + 1)
            Y1 = Y1 + 2*r2 - 1;
        end
    end
    x3(i) = X(X1, Y1);
    y3(i) = Y(X1, Y1);
    newOccupiedNodes(X1, Y1) = 1;
    if (occupiedNodes(X1, Y1) == 1)
        break;
    end
end

occupiedNodes = newOccupiedNodes;
%    plot(x3, y3, 'black', 'LineWidth', 1);
    hold on;
    road3xCoordinates{q} = x3;
    road3yCoordinates{q} = y3;
end

axis([-2 2 -2 2]);

clc;
ln = length(occupiedNodes);
nodeCoords = zeros(ln,ln,2);

x1Cds = [road1xCoordinates{:,:}]; y1Cds = [road1yCoordinates{:,:}];
x2Cds = [road2xCoordinates{:,:}]; y2Cds = [road2yCoordinates{:,:}];
x3Cds = [road3xCoordinates{:,:}]; y3Cds = [road3yCoordinates{:,:}];
xCds = [x1Cds, x2Cds, x3Cds];
yCds = [y1Cds, y2Cds, y3Cds];
pathRoad1 = transpose([x1Cds;y1Cds]);
pathRoad2 = transpose([x2Cds;y2Cds]);
pathRoad3 = transpose([x3Cds;y3Cds]);
xny = [xCds;yCds];
allPaths = transpose(xny);
xny = transpose(xny);
xny = unique(xny,"rows");

nNodes = length(xny);
AdjMat = zeros(nNodes,nNodes);

allLe = [];
allLe(1) = length(road1xCoordinates{1}); 
allLe(2) = length(road2xCoordinates{1}); 
allLe(3) = length(road2xCoordinates{2}); 
for k=1:length(road3xCoordinates)
    allLe(k+3) = length(road3xCoordinates{k});
end
cursedL = length(road1xCoordinates)+length(road2xCoordinates)+length(road3xCoordinates);
cursedIdx = zeros(cursedL,1);
idxCtr = 0;
for i=1:length(allLe)
    idxCtr = idxCtr + allLe(i);
    cursedIdx(i) = idxCtr;
end
CapMat = zeros(size(AdjMat));

for node=1:nNodes
    cnode = xny(node,:);
    cnPos = find(ismember(allPaths,cnode,'rows'));
    for j=1:length(cnPos)
        if (cnPos(j)~=length(allPaths) && ~any(cursedIdx==cnPos(j)) )
            
            nextNode = allPaths(cnPos(j)+1,:);    
            spd = 3*norm(transpose(nextNode-cnode));
            cap = 1;

            if (cnPos(j) <= cursedIdx(length(road1xCoordinates)))
                spd = norm(transpose(nextNode-cnode));
                cap = 4;
            elseif (cnPos(j) <= cursedIdx(length(road1xCoordinates)+...
                    length(road2xCoordinates)))
                cap = 2;
                spd = 2*norm(transpose(nextNode-cnode));
            end

            nNAdj = find(ismember(xny,nextNode,'rows'));
            if (AdjMat(node,nNAdj)==0)
                CapMat(node,nNAdj) = cap;
                CapMat(nNAdj,node) = cap;
            
                AdjMat(node,nNAdj) = spd;
                AdjMat(nNAdj,node) = spd;
            end
        end
        if (cnPos(j) ~= 1 && ~any(cursedIdx==(cnPos(j)-1)) )
            
            prevNode = allPaths(cnPos(j)-1,:);
            spd = 3*norm(transpose(prevNode-cnode));
            cap = 1;

            if (cnPos(j) <= cursedIdx(length(road1xCoordinates)))
                spd = norm(transpose(prevNode-cnode));
                cap = 4;
            elseif (cnPos(j) <= cursedIdx(length(road1xCoordinates)+...
                    length(road2xCoordinates)))
                spd =  2*norm(transpose(prevNode-cnode));
                cap = 2;
            end
            
            pNAdj = find(ismember(xny,prevNode,'rows'));
            if (AdjMat(node,pNAdj)==0)
                CapMat(node,pNAdj) = cap;
                CapMat(pNAdj,node) = cap;
            
                AdjMat(node,pNAdj) = spd;
                AdjMat(pNAdj,node) = spd;
            end
        end
    end
end

AdjMat = AdjMat - diag(diag(AdjMat));
AdjMat = ceil(AdjMat.*4);
CapMat = CapMat - diag(diag(CapMat));
G = graph(AdjMat);
capG = graph(CapMat);
%figure;
LW = capG.Edges.Weight;

plot(G,'XData',xny(:,1),'YData',xny(:,2),'LineWidth',LW,'Edgecolor','black','Nodelabel',{},'Marker','none')

end