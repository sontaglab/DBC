function [] = get_info(nb_decimal)
    load('data/PI.mat')
    load('data/nb_norgates')
    load('data/summary.mat')
    load('data/maxgates.mat')
    
    nb_inputs = summary(nb_decimal+1,2);
    
    fprintf('Decimal representation: %s \n',dec2bin(nb_decimal,16))
    fprintf('Number of gates required based on DNF decomposition (unoptimized): [') 
    for i = 1:size(PI{nb_decimal+1,1},1)
        if i < size(PI{nb_decimal+1,1},1)
            fprintf('%i,',nb_norgates{nb_decimal+1,1}(i))
        else
            fprintf('%i',nb_norgates{nb_decimal+1,1}(i))
        end
    end
    fprintf(']\n')
    
    if nb_inputs == 2
        nb_maxgate = maxgates_2(find(inputs_2 == summary(dec_rep(nb_decimal+1,1)+1,3),1));
    elseif nb_inputs == 3
        nb_maxgate = maxgates_3(find(inputs_3 == summary(dec_rep(nb_decimal+1,1)+1,3),1));
    else
        nb_maxgate = maxgates_4(find(inputs_4 == summary(dec_rep(nb_decimal+1,1)+1,1),1));
    end
    fprintf('The minimum number of gates to implement in a single cell is: %i \n',nb_maxgate)
end