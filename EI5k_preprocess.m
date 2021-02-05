function [ ] = EI5k_preprocess( )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[~,~,loc_info] = xlsread('bus location info for ei added missing buses fixed zones.xlsx');
bus_ID = cell2mat(loc_info(2:end,1)); 
bus_zone_letter = loc_info(2:end,5);
bus_lat = cell2mat(loc_info(2:end,8));
bus_lon = cell2mat(loc_info(2:end,9));

[~,~,loc_info_old] = xlsread('bus location info for ei added missing buses.xlsx');
bus_zone_letter_old = loc_info_old(2:end,5);

% bus_info = xlsread('load_region.xlsx');
% bus_ID_v2 = bus_info(:,1);
% bus_zone_v2 = bus_info(:,3);

save('Bus_information.mat','bus_ID','bus_zone_letter','bus_lat','bus_lon','bus_zone_letter_old')


end

