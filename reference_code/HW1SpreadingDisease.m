% Homework 1: Numerical Modelling of Disease Spreading 
% Provided to the students of the course 'Simulation of Complex Systems' 

clear all; close all; clc; 
%% Parameters:
N=1000;     % Number of agents
infect=10;  % Number of infected agents at the beginning
n=100;      % Number of Grid Size
d=0.3;      % Probability of random walk
B=0.8;      % Infection rate
g=0.01;    % Recovery rate

%% CREATE VIDEO
v = VideoWriter('diseasespread.mp4','MPEG-4');
v.FrameRate = 10;
v.Quality = 100;
open(v);

%% CREATE FIGURE
h=figure; set(h,'Color','w','Units','Pixels','Position',[0 0 600 310]);
a1=axes('Units','Pixels','Position',[50 50 230 230]); box on;  hold on;
xlabel('$x$','FontSize',20,'Interpreter','Latex');
ylabel('$y$','FontSize',20,'Interpreter','Latex');
a2=axes('Units','Pixels','Position',[360 50 230 230]); box on; hold on;
xlabel('Time Steps','FontSize',18,'Interpreter','Latex');
ylabel('Number of agents','FontSize',18,'Interpreter','Latex');
title(['\bf{$d=$' num2str(d) ', $\beta=$' num2str(B) ', $\gamma=$' num2str(g) '}'],'FontSize',12,'Interpreter','Latex')
ylim([0 999]);

%% Initialize the variables: 
x=randi(n,1,N)-1;                       % Random Location along x
y=randi(n,1,N)-1;                       % Random Location along y
[~,I]=sort((x-n/2).^2+(y-n/2).^2);      % Find closest ones to the center
A=zeros(1,N);                       
A(I(1:infect))=1; I=logical(A);         % Infection status array
R=false(1,N);                           % Recovered status array
S=logical(1-I);                         % Susceptible status array
t=0;                                    % Time of the simulation 
tic;
while sum(I)>0 
%% SIMULATION    
    dx=2*sign(randn(1,N)).*(rand(1,N)<d);     % Random Walks along x
    dy=2*sign(randn(1,N)).*(rand(1,N)<d);     % Random Walks along x
    x=mod(x+dx,n); y=mod(y+dy,n);             % Performing walks, Periodic Boundary Conditions, Alternative -solid walls- would be x(x>n)=n;
    for i=find(I)                           
        if rand<B
        infection=(x==x(i))&(y==y(i));      % Determine the indices for those who sit at the site of infection
        S(infection)=false;                 % There are no longer any susceptibles at infection area
        I(infection)=not(R(infection));     % All non-recovered agents will turn infected at infection site
        end
    end
    recovery=(rand(1,N)<g);         % Recovery array
    R = R | (I&recovery);           % Recovery operation
    I = I & not(recovery);          % The ones recovered are no longer infected
    II(t+1)=sum(I); RR(t+1)=sum(R); SS(t+1)=sum(S); % Keep track of number of susceptible, infected and recorevered agents 
%% UPDATING THE FIGURE  
axes(a1); cla;                          % clearing axes is important for preventing huge memmory stacks, if you plot something in a for loop
plot(x(I),y(I),'r.','MarkerSize',7);    % You need to choose a suitable markersize 
plot(x(R),y(R),'g.','MarkerSize',7);
plot(x(S),y(S),'b.','MarkerSize',7);
title(['t= ' num2str(t)]);              % Time display
xlim([-1 n]); ylim([-1 n]);             
set(a1,'xTick',[],'yTick',[]);
axes(a2); cla;
plot(II,'r','LineWidth',2); plot(RR,'g','LineWidth',2); plot(SS,'b','LineWidth',2);     
xlim([0 max(990,t)])
drawnow();
% pause(0.1);
%% UPDATING THE VIDEO
H=getframe(h);
writeVideo(v,H); 
t=t+1;
end
toc;