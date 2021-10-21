function [error, T, D, tau] = draw_T(omega, x, bat_list, mot_list, vh, ah, av)
rho = 1.225;  % density of the air
CD_body = 0.47;  % the drag coefficient of smooth sphere
g = 9.81;  % the gravitational acceleration
A = 0.06;  % the approximation of the prohected area
% fprintf('f');
theta = x(3)/180*pi;
n = floor(x(4));
r = x(5)/1000;
w = x(6)/1000;

bat_weight = 4*bat_list.Weight_g_(floor(x(1)));
mot_weight = 4*mot_list.weight_g_(floor(x(2)));

m = (400 + bat_weight + mot_weight)/1000;  % kg

A_disk = pi*r^2;
vin = sqrt(m*sqrt((g+av)^2+ah^2)/4/(2*rho*A_disk));
r_dist = 0:0.001:r;

% psi = linspace(0,2*pi,100);
psi = [-0.5*pi, 0.5*pi];
T = 0;
D = 0;
tau = 0;

for ii = 1:length(r_dist)
    y = r_dist(ii);
    fd = 0.5*rho*CD_body*A*vh^2;
    beta = atan((m*g)/fd);
    Ut = omega*y+vh*sin(beta).*sin(psi);
    Up = vh*cos(beta)+vin;
    phi = atan(Up./Ut);
    alpha = theta-phi;
    U = sqrt(Up.^2+Ut.^2);
    
    CL = 2.0.*sin(alpha).*cos(alpha);
    CD = 3.7.*sin(alpha).^2+2*1.02*1.328./sqrt(rho.*U*w/1.983e-5)+0.01;
    dL = 0.5*rho*U.^2.*CL*w*0.0001;
    dD_ = 0.5*rho*U.^2.*CD*w*0.0001;
    
    dT = n*(dL.*cos(phi)-dD_.*sin(phi));
%     dD = n*((dL.*sin(phi)+dD_.*cos(phi)).*sin(psi));
    dD = n*(dL.*sin(phi)+dD_.*cos(phi));
    dtau = y*n*sum(dL.*sin(phi)+dD_.*cos(phi));
    T = T + sum(dT);
    D = D + sum(dD);
    tau = tau + dtau;
    
    figure(1)
    plot([-y, y], dT, 'b*')
    hold on
    
    figure(2)
    plot([-y, y], dD, 'b*')
    hold on
end

figure(1)
grid on
title(['thrust distribution: vh = ', num2str(vh)])
xlabel('r')
ylabel('thrust')
saveas(gcf, ['T_', num2str(vh), '.png'])

figure(2)
grid on
title(['drag distribution: vh = ', num2str(vh)])
xlabel('r')
ylabel('drag')
saveas(gcf, ['D_', num2str(vh), '.png'])

error = abs(T - sqrt((m*g+m*av)^2+(fd+D+m*ah)^2)/4);
% error = abs(T-m*g/4);
% fprintf('error = %6.7f\n',error);
% fprintf('T = %6.7f\n',T);
% fprintf('D = %6.7f\n',D);
% fprintf('tau = %6.7f\n',tau);
end