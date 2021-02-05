
% used to update the gen_view array and store output in a table
pen = input('Enter the PV penetration scenario:\n');
update(1,10)
dataout = maketable(pen);
filename = sprintf('OutputData/output_for_%d_penetration',pen);
save(filename,'dataout')
writetable(dataout, filename)
disp ('done')

%%
% checks whether generation changes
% start_row>=1 and <=13617
function s = update(start_row,end_row)
    global genout
    global genview
    r = 0;
    gen_change = zeros(1,24);
    max_gen_change = zeros(13617,1);
    for r = start_row:end_row % genview has one more row than genout
        if (all(~diff(genout(r,1:24))))% 24-->1 day generation data
            genview(r+1,28)= num2cell(1); % gen output is static
        else 
            genview(r+1,28)= num2cell(0); % gen ouput changed
        end
        for i = 2:24
            gen_change(i-1)=genout(r,i)-genout(r,i-1);
        end
        max_gen_change(r)= max(abs(gen_change));% consider the maximum change in generation
        % if the maximum change is less than the threshold change value then
        % make the generator static 
        if(max_gen_change(r)<= 1)
            genview(r+1,28)= num2cell(1);
        end
    end
    genview(2:13618,29) = num2cell(max_gen_change);
end 

%%
% creates a table and stores the the values of the updated generation
function dataout = maketable(pen_value)
    global genview
    global genout
    gen_num = genview(2:13618,1);
    gen = genout(:,1:24);
    avg_gen = mean(gen,2); % compute the mean value of generation for each row
    gen_type = genview(2:13618,2);
    generation_cxs = genview(2:13618,28);
    max_change=genview(2:13618,29);
    dataout= table(gen_num, gen_type, avg_gen,max_change, generation_cxs);
end



