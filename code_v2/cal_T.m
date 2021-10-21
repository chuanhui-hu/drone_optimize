% calculate the thruat, drag on propeller, and toruqe with angular velocity

function [error, T, D, tau] = cal_T(omega, x, bat_list, mot_list, vh, ah, av)
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
r_dist = 0:0.01:r;

psi = linspace(0,2*pi,100);
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
    
    dT = n*sum(dL.*cos(phi)-dD_.*sin(phi));
    dD = n*sum((dL.*sin(phi)+dD_.*cos(phi)).*sin(psi));
    dtau = y*n*sum(dL.*sin(phi)+dD_.*cos(phi));
    T = T + dT;
    D = D + dD;
    tau = tau + dtau;
end
error = abs(T - sqrt((m*g+m*av)^2+(fd+D+m*ah)^2)/4);
% error = abs(T-m*g/4);
% fprintf('error = %6.7f\n',error);
% fprintf('T = %6.7f\n',T);
% fprintf('D = %6.7f\n',D);
% fprintf('tau = %6.7f\n',tau);
end