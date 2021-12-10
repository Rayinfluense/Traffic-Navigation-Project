clear, clc;

gridSize = 31; % Must be an odd number

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
for i = 2:100
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

    plot(x1, y1, 'black', 'LineWidth', 3);
    hold on;
    road1xCoordinates{1} = x1;
    road1yCoordinates{1} = y1;

%%%%%%%%%%%%%%%%%%%%%% Generates more large roads (highways)
for q = 1:2

X1 = randi(gridSize);
Y1 = randi(gridSize);
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

    plot(x2, y2, 'black', 'LineWidth', 2);
    hold on;
    road2xCoordinates{q} = x2;
    road2yCoordinates{q} = y2;
end

%%%%%%%%%%%%%%%%%%%%%% Generates many small roads (streets)
for q = 1:1200

X1 = randi(gridSize);
Y1 = randi(gridSize);
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
    plot(x3, y3, 'black', 'LineWidth', 1);
    hold on;
    road3xCoordinates{q} = x3;
    road3yCoordinates{q} = y3;
end

axis([-2 2 -2 2]);
