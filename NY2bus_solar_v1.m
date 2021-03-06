function solar = NY2bus_solar_v1( PVpen )
%EI5K_SOLAR_V1  Solar data file for unit commitment from spatial mapping.

%
%
%
%   Updated by Jeff on 7.23.2018

%% solar generator data
% Define constant parameters
Vg = 1;
mBase = 100;
status = 1;
CommitKey = 2;
CommitSched = 1;
PositiveActiveReservePrice = 1e-8;
NegativeActiveReservePrice = 2e-8;
PositiveActiveDeltaPrice = 1e-9;
NegativeActiveDeltaPrice = 1e-9;
PositiveLoadFollowReservePrice = 1e-6;
NegativeLoadFollowReservePrice = 1e-6;
inst_dens = 39; % Installation density (MW/km^2)

% Import solar units Pmax values & assign to upstate or downstate bus
load('NY_Bus_info.mat','bus_ID','bus_zone','bus_lat','bus_lon')
bus_ID_cell = num2cell(bus_ID);
if isunix == 0
    infile1 = sprintf('D:/Jeff/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
else
    infile1 = sprintf('/Users/swardy9230/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
end
load(infile1)
n_sites = length(Solar_PMAX);
% Identify the closest bus to the solar farm
[ bus_closest ] = ClosestMS( lat_site, lon_site, bus_lat, bus_lon, bus_ID_cell );
% Assign the solar farm to the upstate or downstate region
region_bus = zeros(n_sites,1);
for i = 1:n_sites
    farm_bus = bus_closest(i);
    idx = find(farm_bus == bus_ID);
    zone = bus_zone(idx);
    if zone == 'A'
        region_bus(i) = 1;
    elseif zone == 'B'
        region_bus(i) = 1;
    elseif zone == 'C'
        region_bus(i) = 1;
    elseif zone == 'D'
        region_bus(i) = 1;
    elseif zone == 'E'
        region_bus(i) = 1;
    else
        region_bus(i) = 2;
        
    end
end

%	bus          Pg                  Qg                  Qmax                Qmin                Vg                 mBase                   status              Pmax           Pmin             Pc1                 Pc2                 Qc1min              Qc1max              Qc2min              Qc2max              ramp_agc            ramp_10        ramp_30      ramp_q              apf
solar.gen = [
	region_bus	 zeros(n_sites,1)    zeros(n_sites,1)	 zeros(n_sites,1)	 zeros(n_sites,1)    ones(n_sites,1)	100*ones(n_sites,1)     ones(n_sites,1)     Solar_PMAX     zeros(n_sites,1) zeros(n_sites,1)    zeros(n_sites,1)	zeros(n_sites,1)	zeros(n_sites,1)    zeros(n_sites,1)    zeros(n_sites,1)    zeros(n_sites,1)    Solar_PMAX     Solar_PMAX   zeros(n_sites,1)    zeros(n_sites,1);
];
%% xGenData
solar.xgd_table.colnames = {
	'CommitKey', ...
                        'CommitSched', ...
                                      'InitialPg', ...
                                                           'RampWearCostCoeff', ...
                                                                                'PositiveActiveReservePrice', ...
                                                                                                      'PositiveActiveReserveQuantity', ...
                                                                                                                    'NegativeActiveReservePrice', ...
                                                                                                                                            'NegativeActiveReserveQuantity', ...
                                                                                                                                                        'PositiveActiveDeltaPrice', ...
                                                                                                                                                                                'NegativeActiveDeltaPrice', ...
                                                                                                                                                                                                        'PositiveLoadFollowReservePrice', ...
                                                                                                                                                                                                                                'PositiveLoadFollowReserveQuantity', ...
                                                                                                                                                                                                                                            'NegativeLoadFollowReservePrice', ...
                                                                                                                                                                                                                                                                    'NegativeLoadFollowReserveQuantity', ...
};

solar.xgd_table.data = [
	2*ones(n_sites,1)	ones(n_sites,1)	zeros(n_sites,1)	zeros(n_sites,1)	1e-8*ones(n_sites,1)	Solar_PMAX	2e-8*ones(n_sites,1)	Solar_PMAX	1e-9*ones(n_sites,1)	1e-9*ones(n_sites,1)	1e-6*ones(n_sites,1)	Solar_PMAX	1e-6*ones(n_sites,1)	Solar_PMAX;
];
end
