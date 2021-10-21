function [current, T] = cal_power(x, bat_list, mot_list, vh, ah, av)
R = 50;  % approximation of the total resistor
i0 = 0;  % ideal assumption?  1/3*????
% fprintf("s")
mot_Kv = mot_list.Kv(floor(x(2)));  % rpm/V

options = optimoptions('fmincon','Display','off');
% options = optimoptions('particleswarm','SwarmSize',100,'MaxTime',3600*20);
% fprintf("c");
fun = @(omega)cal_T(omega, x, bat_list, mot_list, vh, ah, av);
omega_0 = fmincon(fun, 30, [], [], [], [], 0, 2000, [], options);
draw_T(omega_0, x, bat_list, mot_list, vh, ah, av)
% fprintf('1');
% omega_0 = particleswarm(fun,1,0,2000,options);
% fprintf('omega_0 = %6.7f\n',omega_0);
[error, T, D, tau] = cal_T(omega_0, x, bat_list, mot_list, vh, ah, av);
% fprintf('error = %6.7f\n',error);
% fprintf('T = %6.7f\n',T);
% fprintf('D = %6.7f\n',D);
% fprintf('tau = %6.7f\n',tau);

if error < 0.01 && tau > 0
    current = (2*pi/60*mot_Kv*tau + i0)*4;
%     fprintf('currentc = %6.7f\n',current);
else
    current = 100000;
end
end
