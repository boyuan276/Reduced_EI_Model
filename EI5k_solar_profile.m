function solarprofile = EI5k_solar_profile(ST_DATE,N_Days,PVpen)
%EI5K_SOLAR_PROFILE Solar profile data for unit commitment from PVSAM.

%   This program was developed for the 5k bus model of the eastern
%   interconnection, but since profiles are pulled based upon PVSAM data
%   run at each NY weather station, this script also pertains to the
%   NY-only model.
%
%   Should I choose to integrate WRF met data into this framework, I would
%   need a new script or set of scripts. At some furture point this model 
%   should a) read PV farm locations from an input file, b) run PVSAM based 
%   upon WRF outputs where farm locations are specified in WRF (so data at
%   these locations are written to an output file), then the proper power
%   profile can be extracted for use in optimal generator scheduling.
%
%
%   Updated by Jeff on 7.23.2018

%% Define constants
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;
ST_DATE = datenum(ST_DATE);
capacity = 1.997899; %In MW

%% Import data
if isunix == 0
    infile1 = sprintf('D:/Jeff/Box Sync/01_Research/Matlab_functions/PV_output/PV_output_%.1fMW.mat',2);
    infile2 = sprintf('D:/Jeff/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
else
    infile1 = sprintf('/Users/swardy9230/Box Sync/01_Research/Matlab_functions/PV_output/PV_output_%.1fMW.mat',2);
    infile2 = sprintf('/Users/swardy9230/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
end
load(infile1,'PV_output','PVDATE')
load(infile2,'lat_site','lon_site')
load('MetStation_data.mat')
N_PVgen = length(lat_site);
%% create data structure and load solar profile values
solarprofile = struct( ...
    'type', 'mpcData', ...
    'table', CT_TGEN, ...
    'rows', 1:N_PVgen, ...
    'col', PMAX, ...
    'chgtype', CT_REL, ...
    'values', [] );
% Import data
if isunix == 0
    infile1 = sprintf('D:/Jeff/Box Sync/01_Research/Matlab_functions/PV_output/PV_output_%.1fMW.mat',2);
    infile2 = sprintf('D:/Jeff/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
else
    infile1 = sprintf('/Users/swardy9230/Box Sync/01_Research/Matlab_functions/PV_output/PV_output_%.1fMW.mat',2);
    infile2 = sprintf('/Users/swardy9230/Box Sync/01_Research/Matlab_functions/SolarFarm_data/SolarFarm_data_%dMW.mat',PVpen);
end
load(infile1,'PV_output','PVDATE')
load(infile2,'lat_site','lon_site')
load('MetStation_data.mat')
% Extract desired period
[ PV_profile ] = episode_profile( PV_output, PVDATE, N_Days, ST_DATE );
% Loop through solar farms
for i = 1:N_PVgen
    % Identify closest MS
    ms_closest = ClosestMS(lat_site(i),lon_site(i),lat_ms, lon_ms, name_ms);
    idx = MS_str2idx(ms_closest);
    % Extract profile
    PVgen_profile = PV_profile(10:13,idx);
    % Imput normalized profile into solarprofile structure
    solarprofile.values(:, :, i) = PVgen_profile/capacity/100;
end

end