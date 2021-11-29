clear, clc;

% rng default;
x = rand([1 60]);
y = rand([1 60]);
voronoi(x, y)
axis equal

x = [];
y = [];

% X = linspace(1, 2*pi - 1, 18);
% Y = linspace(1, 2*pi - 1, 18);
% x = 70 + 110*cos(X);
% y = -70 + 110*sin(Y);



% Grid
% for i = 1:20
%     for j = 1:20
%         x = [x i];
%         y = [y j];
%     end
% end

% Grid angled
% deltaY = 0;
% for i = 1:10
%     r = 0.5*rand;
%     deltaR = r;
%     for j = 1:10
%         x = [x 6*j];
%         y = [y (-deltaY - i - r)];
%         r = r + deltaR;
%     end
%     deltaY = deltaY + r;
% end
% 
% deltaY = 0;
% for i = 1:5
%     r = 0.5*rand;
%     deltaR = r;
%     for j = 1:20
%         x = [x (70 + 3*j)];
%         y = [y (-40 + deltaY + i + r)];
%         r = r + deltaR;
%     end
%     deltaY = deltaY + r;
% end

% x = [x -4];
% y = [y 4];
% x = [x -4];
% y = [y -4];
% x = [x 14];
% y = [y 4];
% x = [x 14];
% y = [y -4];

voronoi(x, y)
axis equal


[vx,vy] = voronoi(x,y);

V = cell(2, numel(vx)/2);

for i = 1:numel(vx)
    V{i} = [vx(i) vy(i)];
end

verts = [];
verts(1, 1) = V{1}(1);
verts(1, 2) = V{1}(2);

Vnr = vx*0;
n = 1;
for i = 1:numel(vx)
    for j = 1:(numel(verts)/2)
        if (V{i}(1) == verts(j, 1) && V{i}(2) == verts(j, 2))
            Vnr(i) = j;
            break;
        end
        
    end
    
    if (j == numel(verts)/2)
        Vnr(i) = n;
        verts(n, 1) = V{i}(1);
        verts(n, 2) = V{i}(2);
        n = n + 1;
    end
    
end


% Make A
