function [Gen_profs,Load_profs,Solar_profs] = NY2bus_most_EDwSolar( )
%NY2bus_MOST_EDWSOLAR Unit commitment problem on the eastern interconnection
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
%   Updated by Jeff on 11.26.2018

%% set up options
define_constants;
PVpen = 4500; %set the PV penetration level in MW
verbose = 2; %set the verbose option
ST_DATE = datestr('01/01/11','dd-mmm-yyyy'); %set the start date
N_Days = 1; %set the number of dats in the scenario

% solar_scenario = NY2bus_solar_v1( PVpen ); %solar scenario definition function
% solar_prof = EI5k_solar_profile(ST_DATE,N_Days,PVpen); %solar profile definition function
load_prof = NY2bus_load_profile(ST_DATE,N_Days,PVpen); %load profile definition function

mpopt = mpoption('verbose', verbose);
if verbose < 2
    mpopt = mpoption(mpopt, 'out.all', 0);
end
mpopt = mpoption(mpopt, 'out.gen', 1);
mpopt = mpoption(mpopt, 'model', 'DC');
mpopt = mpoption(mpopt, 'most.solver', 'GUROBI');
mpopt = mpoption(mpopt, 'most.price_stage_warn_tol', 1e-5);
mpopt = mpoption(mpopt, 'most.fixed_res', 0);
mpopt = mpoption(mpopt, 'most.security_constraints', 0);

%% ----- solver options----- 

if have_fcn('gurobi')
%     mpopt = mpoption(mpopt, 'gurobi.method', -1);       %% automatic
%     mpopt = mpoption(mpopt, 'gurobi.method', 0);        %% primal simplex
    mpopt = mpoption(mpopt, 'gurobi.method', 1);        %% dual simplex
%     mpopt = mpoption(mpopt, 'gurobi.method', 2);        %% barrier
    mpopt = mpoption(mpopt, 'gurobi.threads', 2);
    mpopt = mpoption(mpopt, 'gurobi.opts.MIPGap', 0);
    mpopt = mpoption(mpopt, 'gurobi.opts.MIPGapAbs', 0);
end

%% ----- case setup -----

% Import the 2 bus NY network Matpower casefile
casefile = 'case_ny2bus_v3.m';
mpc = loadcase(casefile);
ngens = length(mpc.gen(:,1));

% Disable line flow limits (mimic no network case)
% mpc.branch(:, RATE_A) = 0;
% Set generator minimums to zero (should help convergence)
mpc.gen(:, PMIN) = 0;
% Define the area of each bus (THIS IS REQURED FOR SCALING)
mpc.bus(:,BUS_AREA) = [1,2]; 

% Run the OPF for the first time period to get InitialPg
InitialLoad = [load_prof.values(1,1,1) load_prof.values(1,1,2)];
opt.scale = 'QUANTITY';
mpc = scale_load(InitialLoad, mpc, mpc.bus(:,BUS_AREA), opt);
r1 = rundcopf(mpc, mpopt);
Pg1 = r1.gen(:,PG);        % active generation
mpc.gen(:,PG) = Pg1;

% Import the extra generator data compiled from EPA & Energy Visuals %%%%
% STILL NEED TO DO THIS %%%%
% xgd = loadxgendata([], mpc);
% xgd = loadxgendata('NY_xgd_uc', mpc);
% xgd = loadxgendata('NY_xgd_uc_v2', mpc);
xgd = loadxgendata('NY_xgd_uc_v3', mpc);

% Import the distributed solar data (changes with scenario)
% [isolar, mpc, xgd] = addsolar(solar_scenario, mpc, xgd);

% Import load and solar profiles for the desired temporal period
% profiles = getprofiles(solar_prof, isolar);
% profiles = getprofiles(load_prof, profiles);
profiles = getprofiles(load_prof);

nt = size(profiles(1).values, 1);       % number of periods

% Convert to internal ordering if necessary
% mpc = ext2int(mpc);
% [~, mpc.bus, mpc.gen, mpc.branch] = ext2int(mpc.bus, mpc.gen, mpc.branch); 

%% -----  run optimal scheduling problem  -----

mdi = loadmd(mpc, nt, xgd, [], [], profiles);
mdo = most(mdi, mpopt);
if verbose >= 1
    ms = most_summary(mdo);
end

Gen_profs = mdo.results.Pc(1:ngens,:);
Load_profs = mdo.results.Pc(ngens+1:ngens+2,:);
Solar_profs = mdo.results.Pc(ngens+3:end,:);

end