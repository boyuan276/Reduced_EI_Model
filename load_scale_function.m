
clear
close all
clc
global mpc
mpc = loadcase('case_ei5k_v10_g524');
mpc_add = xlsread('load_region.xlsx'); % contains bus type (1) and Pd = 0  
mpc.bus = [mpc.bus,mpc_add(:,2:3)]; % add the two columns of mpc_add to column 14 and 15 of mpc.bus
% scaling factor and index position for loads in each zone in mpc.bus
global scale_fraction1 
global scale_fraction2 
global scale_fraction3 
global scale_fraction4 
global scale_fraction5 
global scale_fraction6 
global scale_fraction7 
global scale_fraction8 
global scale_fraction9 
global scale_fraction10 
global scale_fraction11 

scale_fraction1 = scale_factor(1);
scale_fraction2 = scale_factor(2);
scale_fraction3 = scale_factor(3);
scale_fraction4 = scale_factor(4);
scale_fraction5 = scale_factor(5);
scale_fraction6 = scale_factor(6);
scale_fraction7 = scale_factor(7);
scale_fraction8 = scale_factor(8);
scale_fraction9 = scale_factor(9);
scale_fraction10 = scale_factor(10);
scale_fraction11 = scale_factor(11);

% zonal scaling of loads
% grab all buses in mpc.bus in zone zone_number
% sum all loads in zone zone_number
% create a scaling factor and index
% distribute new load across different buses in the node in main code
function s  = scale_factor(zone_number)
    global mpc
    global zone_loads
    
    total_load = 0;
    numOfload = 0;
   % count the number of loads and total load value for zone zone_number
    for i=1:length(mpc.bus(:,1))
        if ((mpc.bus(i,15) == zone_number) && (mpc.bus(i,3) >= 0))
            numOfload=numOfload+1;
            total_load= total_load + mpc.bus(i,3);
        end
        
    end
    zone_loads = zeros(numOfload,1);
    index = zeros(numOfload,1);
    
    numOfload = 0; % reset number of loads
    for i=1:length(mpc.bus(:,1))
        if (mpc.bus(i,15) == zone_number && mpc.bus(i,3) >= 0)
            numOfload = numOfload + 1;
            index(numOfload)=i;
            zone_loads(numOfload) = mpc.bus(i,3);
        end
        
        load_fraction  = zone_loads/total_load;
        load_frac_check = sum(load_fraction); % check if load fractions sum to 100% (1)
        if load_frac_check ~= 1
            fprintf(2,'Warning: load fractions do not sum to 1 at bus %d\n', mpc.bus(i,1))
        end
    end
    s = [load_fraction ,index];
end