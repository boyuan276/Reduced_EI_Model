clear
clc

ex = 3;

if  ex == 1
    % In this case 'load' represents the scale factor (i.e. the load at each
    % is simply multiplied by this factor).
    load = 0.1; %scale factor
    mpc = loadcase('case5');
    mpc = scale_load(load, mpc);
    
elseif ex == 2
    % In this case 'load' represents the scale quantity (i.e. the load at each
    % is simply multiplied by this factor).
    load = 2000; %scale quantity 
    load_zone = ones(5, 1);
    opt.scale = 'QUANTITY';
    mpc = loadcase('case5');
    mpc = scale_load(load, mpc, load_zone, opt);
    
elseif ex == 3
    % In this case, I want to scale by two different zones.
    load = [100,500]; %target quantities for each zone
    mpc = loadcase('case_ny2bus_v3');
    load_zone = ones(2,1);
    load_zone(2) = 2;
    opt.scale = 'QUANTITY';
    mpc = scale_load(load, mpc, load_zone, opt);
    
end

