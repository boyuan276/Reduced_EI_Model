function [Gen_prof] = EI5k_most_EDwSolar( )
%EI5K_MOST_EDWSOLAR Unit commitment problem on the eastern interconnection
%with solar within New York State.

%   This program investigates the effect of distributed solar generators 
%   within New York State on the dispatch of all dispatchable generating 
%   units in the Eastern Interconnection. 
%
%   PVpen:          defines how much solar exists within NYS in MW. New 
%                   scenarios can be defined using 
%                   New_Solar_Farm_Scenario.m, and existing scenario data  
%                   is stored in MatLAB_functions/SolarFarm_data.
%
%   verbose:        0 - don't print any most outputs
%                   1 - print MOST output for only the final example case
%                   2 - print MOST output for all example cases
%
%   solar_scenario: output of the function where distributed solar unit  
%                   data and extra unit data are defined.
%
%   solar_prof:     output of the function where solar generation profiles
%                   are defined. 
%
%   load_prof:      output of the function where NYISO load profiles are
%                   defined.
%   
%   Updated by Jeff on 7.23.2018

%% set up options
define_constants;
PVpen = 4500; %set the PV penetration level in MW
verbose = 1; %set the verbose option
ST_DATE = datestr('01/01/10','dd-mmm-yyyy'); %set the start date
N_Days = 1; %set the number of dats in the scenario

solar_scenario = EI5k_solar_v1( PVpen ); %solar scenario definition function
solar_prof = EI5k_solar_profile(ST_DATE,N_Days,PVpen); %solar profile definition function
load_prof = EI5k_load_profile(ST_DATE,N_Days,PVpen); %load profile definition function

mpopt = mpoption('verbose', verbose);
mpopt = mpoption(mpopt, 'out.gen', 1);
mpopt = mpoption(mpopt, 'model', 'DC');
mpopt = mpoption(mpopt, 'most.dc_model', 0);    % use model with no network
mpopt = mpoption(mpopt, 'most.solver', 'GUROBI');
if verbose < 2
    mpopt = mpoption(mpopt, 'out.all', 0);
end
mpopt = mpoption(mpopt, 'most.price_stage_warn_tol', 1e-5);

%% ----- solver options----- 

if have_fcn('gurobi')
    %mpopt = mpoption(mpopt, 'gurobi.method', -1);       %% automatic
    %mpopt = mpoption(mpopt, 'gurobi.method', 0);        %% primal simplex
    mpopt = mpoption(mpopt, 'gurobi.method', 1);        %% dual simplex
    %mpopt = mpoption(mpopt, 'gurobi.method', 2);        %% barrier
    mpopt = mpoption(mpopt, 'gurobi.threads', 2);
    mpopt = mpoption(mpopt, 'gurobi.opts.MIPGap', 0);
    mpopt = mpoption(mpopt, 'gurobi.opts.MIPGapAbs', 0);
end

%% ----- case setup -----

% Import the 5000 bus EI network Matpower casefile
casefile = 'case_ei5k_v10_g524.m';
mpc = loadcase(casefile);
mpc.branch(:, RATE_A) = 0;  % disable line flow limits (mimic no network case)
r1 = rundcopf(mpc, mpopt);
Pg1 = r1.gen(:, PG);        % active generation
lam1 = r1.bus(:, LAM_P);    % nodal energy price

% Import the extra generator data compiled from EPA & Energy Visuals %%%%
% STILL NEED TO DO THIS %%%%
xgd = loadxgendata('EI5k_xgd_uc.m', mpc);
% Import the distributed solar data (changes with scenario)
[isolar, mpc, xgd] = addsolar(solar_scenario, mpc, xgd);
% Import load and solar profiles for the desired temporal period
profiles = getprofiles(solar_prof, isolar);
profiles = getprofiles(load_prof, profiles);
% Import load zones (non-NYISO is zone 0)
load('Bus_information.mat','bus_zone_letter')
bus_zone = Zone_let2num( bus_zone_letter );
mpc.bus(:,BUS_AREA) = bus_zone; %define the area of each bus
nt = size(profiles(1).values, 1);       % number of periods
% mpc = ext2int(mpc);
[~, mpc.bus, mpc.gen, mpc.branch] = ext2int(mpc.bus, mpc.gen, mpc.branch); % convert to internal ordering;

%% -----  run optimal scheduling problem  -----

mdi = loadmd(mpc, nt, xgd, [], [], profiles);
mdo = most(mdi, mpopt);
if verbose >= 1
    ms = most_summary(mdo);
end

Gen_prof = mdo.results.Pc;

end