function loadprofile = EI5k_load_profile(ST_DATE,N_Days,PVpen)
%EI5K_LOAD_PROFILE Load profile data from NYISO for EI unit commitment.

%
%
%
%   Updated by Jeff on 7.23.2018

%% Define constants
[CT_LABEL, CT_PROB, CT_TABLE, CT_TBUS, CT_TGEN, CT_TBRCH, CT_TAREABUS, ...
    CT_TAREAGEN, CT_TAREABRCH, CT_ROW, CT_COL, CT_CHGTYPE, CT_REP, ...
    CT_REL, CT_ADD, CT_NEWVAL, CT_TLOAD, CT_TAREALOAD, CT_LOAD_ALL_PQ, ...
    CT_LOAD_FIX_PQ, CT_LOAD_DIS_PQ, CT_LOAD_ALL_P, CT_LOAD_FIX_P, ...
    CT_LOAD_DIS_P, CT_TGENCOST, CT_TAREAGENCOST, CT_MODCOST_F, ...
    CT_MODCOST_X] = idx_ct;
ST_DATE = datenum(ST_DATE);

%% Import data
load('NYISO_hr_LoadData_2010_2015_v2.mat','LoadDATE','LoadDATA')
LoadDATE = LoadDATE(:,1);
%   Remove leap year day from LoadDATA and LoadDATE
leap_yr_st_day = datenum('Feb-29-2012'); 
leap_yr = find(ismember(LoadDATE,leap_yr_st_day,'rows'));
LoadDATA = [LoadDATA(1:leap_yr(1) - 1,:);LoadDATA(leap_yr(end) + 1:end,:)];
LoadDATE = [LoadDATE(1:leap_yr(1) - 1,:);LoadDATE(leap_yr(end) + 1:end,:)];

%% Create data structure and input load profile values
loadprofile = struct( ...
    'type', 'mpcData', ...
    'table', CT_TAREALOAD, ...
    'rows', [1:11], ...
    'col', CT_LOAD_ALL_PQ, ...
    'chgtype', CT_REP, ...
    'values', [] );

NYISO_zonal_loads = episode_profile( LoadDATA, LoadDATE, N_Days, ST_DATE );
for i = 1:11
    loadprofile.values(:, :, i) = NYISO_zonal_loads(:,i);
end
end
