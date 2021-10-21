tic
rng(0,'twister');  % fix the seed for random

bat_list = readtable('battery.xlsx');
mot_list = readtable('motor.xlsx');

fun = @(x)simulator(x, bat_list, mot_list);

label_bat = 1;
label_mot = 3;
theta = 50;  % propeller pitch angle in degree, [30, 90]
n = 3;  % number of blades, {2, 3, 4}
r = 140;  % propeller radius, [80, 200]
w = 20;  % chord length, [15, 40]
a_asc_acc = 1;  % ascend acceleration, [0.5, 2]
a_asc_dec = 1;  % ascend deceleration, [0.5, 2]
a_des = 1;  % descend, [0.5, 2]
a_trans = 2;  % translation acceleration, [0.5, 4]
dt4 = 20*60/100;  % scaled time

% x0 = [label_bat, label_mot, theta, n, r, w, a_asc_acc, a_asc_dec, a_des, a_trans, dt4];
x0 = [14.0950538, 3.9415818, 39.5678162, 2.2148346, 129.5640308, 19.8007087, 2.6652770, 0.9808429, 3.2235033, 3.7248149, 13.3913236];
lb = [1, 1, 30, 2, 80, 15, 0.5, 0.5, 0.5, 0.5, 6];
ub = [19.99, 9.99, 90, 4.99, 200, 40, 4, 4, 4, 4, 24];

initial_population = (ub-lb).*rand(100, 11)+lb;  % for ga
initial_population(1,:) = x0;

A = [];
b = [];
Aeq = [];
beq = [];
% nonlcon = @(x)constraints(x, bat_list, mot_list);
nonlcon = [];

% options = optimoptions('ga','PopulationSize',100, 'MaxGenerations', 11*50, 'MaxTime', 3600*10,...
%     'InitialPopulationMatrix', initial_population,'Display','iter');
% [x,fval,exitflag,output,population,scores] = ga(fun, 11, A, b, Aeq, beq, lb, ub, nonlcon, options);
options = optimoptions('particleswarm', 'SwarmSize', 100, 'MaxTime', 3600 * 20, 'MinNeighborsFraction', 1, 'InitialSwarmMatrix', initial_population,'FunctionTolerance',1e-20, 'Display', 'Iter');
[x, fval, exitflag, output] = particleswarm(fun, 11, lb, ub, options);
fprintf('x=%6.7f',x);
fprintf('fval=%6.7f',fval);
% disp(fval);
% fprintf('x=%6.4f\n',x);
% [fval, t_list, v_list, h_list, drag_list, thrust_list, acc_list, dist_list] = simulator(x, bat_list, mot_list);

toc