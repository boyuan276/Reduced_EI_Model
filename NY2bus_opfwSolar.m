function [] = NY2bus_opfwSolar( )
%NY2bus_opfwSolar Unit commitment problem on the eastern interconnection
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
verbose = 1; %set the verbose option
ST_DATE = datestr('01/01/11','dd-mmm-yyyy'); %set the start date
N_Days = 1; %set the number of dats in the scenario

% solar_scenario = NY2bus_solar_v1( PVpen ); %solar scenario definition function
% solar_prof = EI5k_solar_profile(ST_DATE,N_Days,PVpen); %solar profile definition function
load_prof = NY2bus_load_profile(ST_DATE,N_Days,PVpen); %load profile definition function

mpopt = mpoption('verbose', verbose);
mpopt = mpoption(mpopt, 'out.gen', 1);
mpopt = mpoption(mpopt, 'model', 'DC');
%mpopt = mpoption(mpopt, 'most.dc_model', 0);    % use model with no network
mpopt = mpoption(mpopt, 'most.solver', 'GUROBI');
if verbose < 2
    mpopt = mpoption(mpopt, 'out.all', 0);
end
mpopt = mpoption(mpopt, 'most.price_stage_warn_tol', 1e-5);

%% ----- solver options----- 

if have_fcn('gurobi')
    mpopt = mpoption(mpopt, 'gurobi.method', -1);       %% automatic
%     mpopt = mpoption(mpopt, 'gurobi.method', 0);        %% primal simplex
%     mpopt = mpoption(mpopt, 'gurobi.method', 1);        %% dual simplex
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
% Set generator minimums to zero
mpc.gen(1:ngens, PMIN) = 0;
% Define the area of each bus
mpc.bus(:,BUS_AREA) = [1,2];

% Scale the load based on 
opt.scale = 'QUANTITY';
load_zone = [1;2];
load = [load_prof.values(1) load_prof.values(5)];
mpc = scale_load(load, mpc, load_zone, opt);

%% ----- run opf -----

r1 = rundcopf(mpc, mpopt);
Pg1 = r1.gen(:, PG);        % active generation
lam1 = r1.bus(:, LAM_P);    % nodal energy price

end