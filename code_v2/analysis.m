bat_list = readtable('battery.xlsx');
mot_list = readtable('motor.xlsx');
x = [14.0950538, 3.9415818, 39.5678162, 2.2148346, 129.5640308, 19.8007087, 2.6652770, 0.9808429, 3.2235033, 3.7248149, 4.9869848];

fval = simulator(x, bat_list, mot_list)