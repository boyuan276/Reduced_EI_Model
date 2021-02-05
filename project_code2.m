

global genout
global genview
global mpc

% load scale fraction arrays
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

%Enter the PV penetration scenario in New York state
PVpen = input('Enter a PV penetration scenario (0,4500,6000,9000):\n');
 
%Input the episode start date (mm/dd/yy): \n','s'),'dd-mmm-yyyy');
st_day = datestr('07/18/13','dd-mmm-yyyy');

define_constants;
mpc.version = '2';
mpc.baseMVA = 100;
mpc = loadcase('case_ei5k_v10_g524');

%%%%% US/CA load scale 
mpc_add = xlsread('load_region.xlsx'); % contains bus type (1) and Pd =0  
mpc.bus = [mpc.bus,mpc_add(:,2:3)]; % add the two columns of mpc_add to column 14 and 15 of mpc.bus


%define the load_zones to be scaled
for i=1:11
    load_zone(mpc.bus(:,15)==i) = i; % copies load_zones from load_region file
end

if PVpen == 0
    load_file = sprintf('Test_Input_Data/episode_%s_profiles',st_day); 
    load(load_file)
    load_zonal = episode_Load;  %7/19/2013
else
    load_file1 = sprintf('Test_Input_Data/2030NetEpisodeProfiles_ZoneSplit_%dMW_%s',PVpen,st_day);
    load(load_file1)
    load_file2 = sprintf...
        ('Test_Input_Data/2030NetEpisodeProfiles_ZoneSplit_%dMW_%s',PVpen,st_day);
    load(load_file2)
    header = {'A' ,  'B' ,   'C'  ,  'D' ,  'E' ,   'F' ,   'G'  ,  'H'  ,  'I'  , 'J'  , 'K'};
    data = [zoneAepisode zoneBepisode zoneCepisode zoneDepisode... % loaded data for each zones
        zoneEepisode zoneFepisode zoneGepisode zoneHepisode...
        zoneIepisode zoneJepisode zoneKepisode];
    load_zonal = data; %[header ; num2cell(data)]
end

%%
% scale load and ramp generation

ndays = 3; % number of days for load and generation data
gen = cell(length(mpc.gen),24*ndays); % size = length(mpc.gen) x 24*ndays

for j=1:24*ndays
    load_zonal2= load_zonal(j,:); % new zonal loads for each zone per hr
    opt = struct('pq','P','scale','QUANTITY');
   
    % compute the new load _zones for each hour
    % distribute the load in load_zonal2 across the buses in each zone
     new_zone1_load = scale_fraction1(:,1)*load_zonal2(1);
     new_zone2_load = scale_fraction2(:,1)*load_zonal2(2);
     new_zone3_load = scale_fraction3(:,1)*load_zonal2(3);
     new_zone4_load = scale_fraction4(:,1)*load_zonal2(4);
     new_zone5_load = scale_fraction5(:,1)*load_zonal2(5);
     new_zone6_load = scale_fraction6(:,1)*load_zonal2(6);
     new_zone7_load = scale_fraction7(:,1)*load_zonal2(7);
     new_zone8_load = scale_fraction8(:,1)*load_zonal2(8);
     new_zone9_load = scale_fraction9(:,1)*load_zonal2(9);
     new_zone10_load = scale_fraction10(:,1)*load_zonal2(10);
     new_zone11_load = scale_fraction11(:,1)*load_zonal2(11);
        
   % assign the new loads to the corresponding index in mpc.bus
       
    mpc.bus (scale_fraction1(:,2),3) = new_zone1_load;
    mpc.bus (scale_fraction2(:,2),3) = new_zone2_load;
    mpc.bus (scale_fraction3(:,2),3) = new_zone3_load;
    mpc.bus (scale_fraction4(:,2),3) = new_zone4_load;
    mpc.bus (scale_fraction5(:,2),3) = new_zone5_load;
    mpc.bus (scale_fraction6(:,2),3) = new_zone6_load;
    mpc.bus (scale_fraction7(:,2),3) = new_zone7_load;
    mpc.bus (scale_fraction8(:,2),3) = new_zone8_load;
    mpc.bus (scale_fraction9(:,2),3) = new_zone9_load;
    mpc.bus (scale_fraction10(:,2),3)= new_zone10_load;
    mpc.bus (scale_fraction11(:,2),3)= new_zone11_load;
      

    mpc.genfuel(strcmp(mpc.genfuel,'coal'))={'1'};
    mpc.genfuel(strcmp(mpc.genfuel,'ng'))={'2'};
    mpc.genfuel(strcmp(mpc.genfuel,'oil'))={'3'};
    mpc.genfuel(strcmp(mpc.genfuel,'wind'))={'4'};
    mpc.genfuel(strcmp(mpc.genfuel,'solar'))={'5'};
    mpc.genfuel(strcmp(mpc.genfuel,'hydro'))={'6'};
    mpc.genfuel(strcmp(mpc.genfuel,'biomass'))={'7'};
    mpc.genfuel(strcmp(mpc.genfuel,'nuclear'))={'8'};
    mpc.genfuel(strcmp(mpc.genfuel,'unknown'))={'9'};
    mpc.genfuel(strcmp(mpc.genfuel,'refuse'))={'10'};
    mpc.genfuel(strcmp(mpc.genfuel,'storage'))={'11'};
    gentype=str2double(mpc.genfuel);
    
    mpopt = mpoption('opf.dc.solver','GUROBI','verbose',0,'out.all',0);
    results(j) = rundcopf(mpc, mpopt);
    genout(:,j) = results(j).gen(:,2);
    
     %%%%%%%%%%%%%%%%% ADDING RAMPING CONSTRAINTS %%%%%%%%%%%%%%%%%%%
    if j>1
        ramping(:,j)= genout(:,j)-genout(:,j-1); % the ramping is the difference between current and previous generation level
        %one hour ramping rate assumptions
        %          Rcoal=20;
        %          Rng=30;
        %          Roil=30;
        %          Rwind=1000;
        %          Rsolar=1000;
        %          Rhydro=100;
        for k=1:13617
            %%%%%%%%coal ramping
            if gentype(k)==1
                R=20;                        %ramping constraint
                % R=mpc.gen(k,PMAX)*0.25;
                if ramping(k,j)>R
                    genout(k,j)=genout(k,j-1)+R;
                elseif ramping(k,j)<-R
                    genout(k,j)=genout(k,j-1)-R;
                end
            end
            %%%%%%%%natural gas ramping
            if gentype(k)==2
                R=30;                 %ramping constraint
                % R=mpc.gen(k,PMAX)*0.3;
                if ramping(k,j)>R
                    genout(k,j)=genout(k,j-1)+R;
                elseif ramping(k,j)<-R
                    genout(k,j)=genout(k,j-1)-R;
                end
            end
            %%%%%%%oil ramping
            if gentype(k)==3
                R=30;                 %ramping constraint
                % R=mpc.gen(k,PMAX)*0.3;
                if ramping(k,j)>R
                    genout(k,j)=genout(k,j-1)+R;
                elseif ramping(k,j)<-R
                    genout(k,j)=genout(k,j-1)-R;
                end
            end
            
            %%%%%%%%hydro ramping
            if gentype(k)==6
                R=100;                 %ramping constraint
                % R=mpc.gen(k,PMAX)*0.5;
                if ramping(k,j)>R
                    genout(k,j)=genout(k,j-1)+R;
                elseif ramping(k,j)<-R
                    genout(k,j)=genout(k,j-1)-R;
                end
            end
            %%%%%%%%%%%%%%%%%%%%test wind solar availability
            if gentype(k)==4 || gentype(k)==5 % changed && to ||
                mpc.gen(k,PMAX)= mpc.gen(k,PMAX)*0.3;      %set output to 30% of max capacity
            end
            mpc.gen(mpc.gen(:, PMIN)>0, PMIN) = 0; % set the minimum generation to zero if greater than zero
        end
    end
end
%%
% organize output
size = size(genout);
row = size(1); % get the number of generators

genstate=load('genstate'); % state location
gentype=load('gentype'); % hydro, ng, solar ...
genview_header= {'generator#' ,  'state' ,   'generator type'};
genview_header(1,4:27)= {'gen output'};
genview_header(1,28)= {'static?'};
genview_header(1,29)= {'max_gen_change'};
genview = [genview_header; num2cell(results(1).gen(:,1)) genstate.genstate(:) gentype.gentype(:) num2cell(genout(:,1:24)) num2cell(zeros(row,1)) num2cell(zeros(row,1)) ];

%% determine the buses which are in New York State
counter = 0;
mpc2 = mpc;
for i=1:length(mpc_add(:,1))
    if(mpc_add(i,3)~= 0)
        counter = counter + 1;
    end
end
mpc_tempbus = zeros(counter,15);
mpc_tempisland = zeros(counter,1);
mpc_tempbusname = zeros(counter,1);
mpc_tempbusname = string(mpc_tempbusname);
counter = 0;
for i=1:length(mpc2.bus(:,1))
    if(mpc2.bus(i,15)~= 0)
        counter = counter + 1;
        mpc_tempbus(counter,:)= mpc2.bus(i,:);
        mpc_tempisland(counter,1)= mpc2.bus_island(i);
        mpc_tempbusname(counter,1)= mpc2.bus_name(i);
    end
end

mpc2.bus = mpc_tempbus;
mpc2.bus_island = mpc_tempisland;
mpc2.bus_name = mpc_tempbusname;
load_zone= zeros(counter, 1);% scaling zone for each individual bus in New York state

%%