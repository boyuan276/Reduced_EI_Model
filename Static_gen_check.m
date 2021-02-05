function [gen_change,gen_change_log] = Static_gen_check(Gen_profs)
%Static_gen_check checks whether generation changes
%   Detailed explanation goes here
dims = size(Gen_profs);
nt = dims(2);
ngens = dims(1);

gen_change = zeros(1,nt-1);
gen_change_log = false(ngens,1);
max_gen_change = zeros(ngens,1);

for r = 1:ngens 
    % Check if generator output changes throughut the period
    if (all(~diff(Gen_profs(r,1:nt))))
       % gen output is static
    else
        gen_change_log(r) = true; % gen ouput changed
    end
    
    % Calculate the change and max change.
    for i = 2:nt
        gen_change(i-1)=Gen_profs(r,i)-Gen_profs(r,i-1); % gen change
    end
    max_gen_change(r) = max(abs(gen_change));% maximum gen change
    
%     % If the maximum change is less than the threshold change value, 
%     % make the generator static
%     if(max_gen_change(r) <= 1)
%         gen_change_log(r)= false;
%     end
end


end

