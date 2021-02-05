% 
% for i = 1:length(bus)
%     if zone(i) == "A"
%         super_zone(i) = 1;
%     elseif zone(i) == "B"
%         super_zone(i) = 1;
%     elseif zone(i) == "C"
%         super_zone(i) = 1;
%     elseif zone(i) == "D"
%         super_zone(i) = 1;
%     elseif zone(i) == "E"
%         super_zone(i) = 1;
%     else
%         super_zone(i) = 2;
%     end
% end

for j = 1:length(mpc.gen)
    
       idx = find(mpc.bus(:,1) == mpc.gen(j,1));
       mpc.gen(j,1) = super_zone(idx);
    
end