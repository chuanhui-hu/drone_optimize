% function [fval, t_list, v_list, h_list, drag_list, thrust_list, acc_list, dist_list] = simulator(x, bat_list, mot_list)

function time_sec = simulator(x, bat_list, mot_list)
% bat_list = readtable('battery.xlsx');
% mot_list = readtable('motor.xlsx');

rho = 1.225;  % density of the air
CD_body = 0.47;  % the drag coefficient of smooth sphere
g = 9.81;  % the gravitational acceleration
A = 0.06;  % the approximation of the prohected area

hh = 50;  % max height
vc = 4;  % max horizontal speed

h = 0;  % height
vh = 0;  % horizontal speed
vv = 0;  % vertical speed

R = 50;  % approximation of the total resistor
i0 = 0;  % ideal assumption?

% disp(x);

theta = x(3)/180*pi;
n = floor(x(4));
r = x(5)/1000;
w = x(6)/1000;
a_asc_acc = round(x(7)*100)/100;
a_asc_dec = round(x(8)*100)/100;
a_des = round(x(9)*100)/100;
a_trans = round(x(10)*100)/100;

dt1 = sqrt(2*a_asc_acc*a_asc_dec*hh/(a_asc_acc+a_asc_dec))/a_asc_acc;
dt2 = sqrt(2*a_asc_acc*a_asc_dec*hh/(a_asc_acc+a_asc_dec))/a_asc_dec;
dt3 = vc/a_trans;
dt4 = x(11)*100;  % scaling
% dt4 = 30*60;
dt5 = vc/a_trans;
dt6 = sqrt(2*hh/2/a_des);
dt7 = dt6;

t_span = 0:0.1:3600;

bat_weight = 4*bat_list.Weight_g_(floor(x(1)))/1000;  % kg
bat_cap = 4*bat_list.Capacity_mAh_(floor(x(1)));  % mAh
mot_weight = 4*mot_list.weight_g_(floor(x(2)))/1000;  % kg
mot_Kv = mot_list.Kv(floor(x(2)));  % rpm/V

m = (400 + bat_weight + mot_weight)/1000;  % kg

energy_consumption = 0;
% fprintf("a");
[current0, T0] = cal_power(x, bat_list, mot_list, vc, 0, 0);
% fprintf("b");
% fprintf('current0=%6.1f\n',current0);

vh_list = zeros(size(t_span));
vv_list = zeros(size(t_span));
h_list = zeros(size(t_span));
drag_list = zeros(size(t_span));
thrust_list = zeros(size(t_span));
current_list = zeros(size(t_span));
acc_list = zeros(size(t_span));
dist_list = zeros(size(t_span));

for i = 1:length(t_span)
    if t_span(i) < dt1  % upward, accelerate
        vv = vv + a_asc_acc*0.1;
        vh = 0;
        h = h + vv*0.1;
        ah = 0;
        av = a_asc_acc;
    elseif t_span(i) < dt1+dt2  % upward, decelerate
        vv = vv - a_asc_dec*0.1;
        vh = 0;
        h = h + vv*0.1;
        ah = 0;
        av = -a_asc_dec;
    elseif t_span(i) < dt1+dt2+dt3  % forward, accelerate
        vh = vh + 0.1*a_trans;
        vv = 0;
        av = 0;
        ah = a_trans;
        h = h;
    elseif t_span(i) < dt1+dt2+dt3+dt4  % forward
        ah = 0;
        av = 0;
        vh = 4;
        vv = 0;
        h = h;
    elseif t_span(i) < dt1+dt2+dt3+dt4+dt5  % forward, decelerate
        vh = vh - 0.1*a_trans;
        vv = 0;
        ah = -a_trans;
        av = 0;
        h = h;
    elseif t_span(i) < dt1+dt2+dt3+dt4+dt5+dt6  % downward, accelerate
        vh = 0;
        vv = vv - a_des*0.1;
        h = h + vv*0.1;
        ah = 0;
        av = -a_des;
    elseif t_span(i) < dt1+dt2+dt3+dt4+dt5+dt6+dt7  % downward, decelerate
        vh = 0;
        vv = vv + a_des*0.1;
        h = h + vv*0.1;
        ah = 0;
        av = a_des;
    end
    
    if current0 > 50  % if current is too high, stop early
        break
    end
    
    if (ah == 0) && (av == 0)  % in the forward phase
        current = current0;
        T = T0;
%         fprintf('currentf=%6.1f',current);
    else
        [current, T] = cal_power(x, bat_list, mot_list, vh, ah, av);
%         fprintf('current1=%6.1f',current);
        
    if current > 100
        current = past;
    end
    past = current;
    
    end
    vh_list(i) = vh;
    vv_list(i) = vv;
    h_list(i) = h;
    drag_list(i) = cal_fd(rho, CD_body, A, vh);
    thrust_list(i) = T;
    current_list(i) = current;
    energy_consumption = energy_consumption + current*0.1;

    if energy_consumption > bat_cap*60*60/1000
        break
    end
end

time_sec = -t_span(i);  % in seconds
t_list = t_span(1:i);
vh_list = vh_list(1:i);
vv_list = vv_list(1:i);
current_list = current_list(1:i);
h_list = h_list(1:i);
drag_list = drag_list(1:i);
thrust_list = thrust_list(1:i);

figure(1)
plot(t_list, vh_list)
title('horizontal speed')
xlabel('t (s)')
ylabel('vh (m/s)')
saveas(gcf, 'vh.png')

figure(2)
plot(t_list, vv_list)
title('vertical speed')
xlabel('t (s)')
ylabel('vv (m/s)')
saveas(gcf, 'vv.png')

figure(3)
plot(t_list, current_list)
title('current')
xlabel('t (s)')
ylabel('current (A)')
saveas(gcf, 'current.png')

figure(4)
plot(t_list, h_list)
title('height')
xlabel('t (s)')
ylabel('h (m)')
saveas(gcf, 'h.png')

figure(5)
plot(t_list, drag_list)
title('horizontal drag')
xlabel('t (s)')
ylabel('fd (N)')
saveas(gcf, 'fd.png')

figure(6)
plot(t_list, thrust_list)
title('thrust')
xlabel('t (s)')
ylabel('T (N/rotor)')
saveas(gcf, 'T.png')

end