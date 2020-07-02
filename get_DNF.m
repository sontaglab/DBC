function [] = get_DNF(nb_decimal,N)
close all
load('data/summary.mat')
load('data/PI.mat')
load('data/nb_norgates.mat')
load('data/permuted_terms.mat')
load('data/maxgates.mat')



all_perms_2 = unique(perms([1 2]),'rows');
all_perms_3 = unique(perms([1 2 3]),'rows');
all_perms_4 = unique(perms([1 2 3 4]),'rows');
all_perms = {all_perms_2;all_perms_3;all_perms_4};

total_offending_terms = sum(nb_norgates{nb_decimal+1,1}>N);

counter = 1;
counter2 = 1;
for i = 1:size(PI{nb_decimal+1,1},1)
    if nb_norgates{nb_decimal+1,1}(i) > N
        loc_offending(counter) = i;
        counter = counter + 1; 
    else
        loc_nonoffending(counter2) = i;
        counter2 = counter2 + 1; 
    end
end

if total_offending_terms == 2
    nb_QS = 1;
    bool_eq = zeros(1,4);
    for k = 1:4
        if PI{nb_decimal+1,1}(loc_offending(1),k) == PI{nb_decimal+1,1}(loc_offending(2),k)
            bool_eq(k) = 1;
        end
    end
    bool_eq_idx = [1,2];
elseif total_offending_terms == 3
    nb_QS = 2;
    C = nchoosek([1 2 3],2);
    for i = 1:size(C,1)
         bool_eq2 = zeros(1,4);
         for k = 1:4
             if PI{nb_decimal+1,1}(loc_offending(C(i,1)),k) == PI{nb_decimal+1,1}(loc_offending(C(i,2)),k)
                 bool_eq2(k) = 1;
             end
         end
         if sum(bool_eq2) == 2
            bool_eq = bool_eq2; 
            bool_eq_idx = [C(i,1),C(i,2)];
         end
    end
elseif total_offending_terms == 4
    nb_QS = 2;
    C = [1 2 3 4];
    counter = 1;
    for i = 1:size(C,1)
         bool_eq2 = zeros(4,1);
         for k = 1:4
             if PI{nb_decimal+1,1}(loc_offending(1),k) == PI{nb_decimal+1,1}(loc_offending(2),k)
                 bool_eq2(k) = 1;
             end
         end
         if sum(bool_eq2) == 2
            bool_eq(1,:) = bool_eq2; 
            bool_eq_idx(1,:) = [C(i,1),C(i,2)];
         end
    end
    for i = 1:size(C,1)
         bool_eq2 = zeros(4,1);
         for k = 1:4
             if PI{nb_decimal+1,1}(loc_offending(3),k) == PI{nb_decimal+1,1}(loc_offending(4),k)
                 bool_eq2(k) = 1;
             end
         end
         if sum(bool_eq2) == 2
            bool_eq(2,:) = bool_eq2; 
            bool_eq_idx(2,:) = [C(i,3),C(i,4)];
         end
    end
end

if exist('loc_nonoffending')
all_partitions = partitions(length(loc_nonoffending));
else
all_partitions = []; 
end
vector_4 = getcondvects(4);
for i = 1:size(PI{nb_decimal+1,1},1)
    binary_rep = '0000000000000000';
    for j = 1:size(vector_4,1)
        bin_nb = zeros(4,1);
        for k = 1:4
             if (PI{nb_decimal+1,1}(i,k) == '0') && (vector_4(j,k) == 0)
                 bin_nb(k) = 1;
             elseif (PI{nb_decimal+1,1}(i,k) == '1') && (vector_4(j,k) == 1)
                 bin_nb(k) = 1;
             elseif (PI{nb_decimal+1,1}(i,k) == '-')
                 bin_nb(k) = 1;
             end
        end
        if all(bin_nb)
           binary_rep(j) = 1 + '0'; 
        end
    end
    all_binary_rep(i,:) = binary_rep;
end

all_gates = cell(size(all_partitions,1),1);
all_gates_bin = cell(size(all_partitions,1),1);

for i = 1:size(all_partitions,1)
    for j = 1:size(all_partitions{i,1},2)
        sum_bin = all_binary_rep(loc_nonoffending(all_partitions{i,1}{1,j}(1)),:);
        for k = 2:size(all_partitions{i,1}{1,j},2)
            sum_bin2 = all_binary_rep(loc_nonoffending(all_partitions{i,1}{1,j}(k)),:);
            for l = 1:16
               if (sum_bin2(l) == '1')
                    sum_bin(l) = 1 + '0';
               end
            end
        end
        decimal_nb = bin2dec(sum_bin);
        if summary(decimal_nb+1,2) == 2
           nb_maxgate = maxgates_2(find(inputs_2 == summary(dec_rep(decimal_nb+1,1)+1,3),1));
        elseif summary(decimal_nb+1,2) == 3
           nb_maxgate = maxgates_3(find(inputs_3 == summary(dec_rep(decimal_nb+1,1)+1,3),1));
        elseif summary(decimal_nb+1,2) == 4
           nb_maxgate = maxgates_4(find(inputs_4 == summary(dec_rep(decimal_nb+1,1)+1,1),1));
        end
        all_gates{i,1} =[all_gates{i,1},nb_maxgate];
        all_gates_bin{i,1} = [all_gates_bin{i,1}; decimal_nb];
    end
end

best_gate = 100;
best_idx = 0;
for i = 1:size(all_gates,1)
    if all(all_gates{i,1}<8) && (sum(all_gates{i,1})<best_gate)
       best_gate = sum(all_gates{i,1});
       best_idx = i;
    end
%     if all(all_gates{i,1}<8) && (sum(all_gates{i,1})<best_gate)
%        best_gate = sum(all_gates{i,1});
%        best_idx = i;
%     end
end

fprintf('\nA circuit is generated for decimal representation: %i \n',nb_decimal)
fprintf('Corresponding binary representation: %s \n',dec2bin(nb_decimal,16))
fprintf('The maximum number of NOR gates given minterms: %i \n',max(nb_norgates{nb_decimal+1,1}))
fprintf('The number of minterms is: %i \n',size(PI{nb_decimal+1,1},1))
fprintf('The number of inputs required is: %i \n',summary(nb_decimal+1,2))
if summary(nb_decimal+1,2) <4
   fprintf('The redundant terms are: %i %i %i %i \n',permuted_terms(dec_rep(nb_decimal+1,1)+1,:)) 
end
fprintf('The corresponding NAND input value is: %i \n',dec_rep(nb_decimal+1,1))

nb_maxgate = 0;
if exist('loc_offending') && ~isempty(all_gates_bin{best_idx,1})
    width = length(loc_offending) + length(all_gates_bin{best_idx,1});
elseif exist('loc_offending')
    width = length(loc_offending);
else
    width = length(all_gates_bin{best_idx,1});    
end 

figure('Renderer', 'painters', 'Position', [100 100 300*ceil(width/2) 750])

if summary(nb_decimal+1,2) == 2
   nb_maxgate = maxgates_2(find(inputs_2 == summary(dec_rep(nb_decimal+1,1)+1,3),1));
   fprintf('The minimum number of gates to implement in a single cell is: %i \n',nb_maxgate)
   fprintf('The NAND P-equivalent decimal input representation is %i \n',summary(dec_rep(nb_decimal+1,1)+1,3))
   remaining_terms = 1:4;
   remaining_terms(permuted_terms(dec_rep(nb_decimal+1,1)+1,:)==1) = [];
   remaining_terms = remaining_terms(all_perms{1,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
   fprintf('With the following input permutation: %i %i \n',remaining_terms-1)
   fprintf('The NOR gate representation is given by \n')
   %subplot(2,4,1)
   %print_graphs(summary(nb_decimal+1,2),find(inputs_2 == summary(dec_rep(nb_decimal+1,1)+1,3),1),remaining_terms,1)
elseif summary(nb_decimal+1,2)== 3
   nb_maxgate = maxgates_3(find(inputs_3 == summary(dec_rep(nb_decimal+1,1)+1,3),1));
   fprintf('The minimum number of gates to implement in a single cell is: %i \n',nb_maxgate)
   fprintf('The NAND P-equivalent decimal input representation is %i \n',summary(dec_rep(nb_decimal+1,1)+1,3))
   remaining_terms = 1:4;
   remaining_terms(permuted_terms(dec_rep(nb_decimal+1,1)+1,:)==1) = [];
   remaining_terms = remaining_terms(all_perms{2,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
   fprintf('With the following input permutation: %i %i %i\n',remaining_terms-1)
   fprintf('The NOR gate representation is given by \n')
   %subplot(2,4,1)
   %print_graphs(summary(nb_decimal+1,2),find(inputs_3 == summary(dec_rep(nb_decimal+1,1)+1,3),1),remaining_terms,1)
elseif summary(nb_decimal+1,2)== 4
   nb_maxgate = maxgates_4(find(inputs_4 == summary(dec_rep(nb_decimal+1,1)+1,1),1));
   fprintf('The minimum number of gates to implement in a single cell is: %i \n',nb_maxgate)
   fprintf('The NAND P-equivalent decimal input representation is %i \n',summary(dec_rep(nb_decimal+1,1)+1,1))
   remaining_terms = 1:4;
   remaining_terms(permuted_terms(dec_rep(nb_decimal+1,1)+1,:)==1) = [];
   remaining_terms = remaining_terms(all_perms{3,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
   fprintf('With the following input permutation: %i %i %i %i\n',remaining_terms-1)
   fprintf('The NOR gate representation is given by \n')
else
   fprintf('A representation is not needed \n') 
end
title(sprintf('Full Circuit, NOR gates: %i',nb_maxgate))

vector_4 = getcondvects(4);

if (nb_maxgate > 0) && (nb_maxgate > N)
    fprintf('\n----------------------------------------------------------------------------------\n')
    fprintf('\nThe number of maximum gates exceeded N. Printing out cells based on minterms. \n')
    counter = 1;
    counter2 = 1;
    for i = 1:size(PI{nb_decimal+1,1},1)
        binary_rep = '0000000000000000';
        for j = 1:size(vector_4,1)
            bin_nb = zeros(4,1);
            for k = 1:4
                 if (PI{nb_decimal+1,1}(i,k) == '0') && (vector_4(j,k) == 0)
                     bin_nb(k) = 1;
                 elseif (PI{nb_decimal+1,1}(i,k) == '1') && (vector_4(j,k) == 1)
                     bin_nb(k) = 1;
                 elseif (PI{nb_decimal+1,1}(i,k) == '-')
                     bin_nb(k) = 1;
                 end
            end
            if all(bin_nb)
               binary_rep(j) = 1 + '0'; 
            end
        end
        if (nb_norgates{nb_decimal+1,1}(i) > N) && (total_offending_terms > 1) && (any(loc_offending(bool_eq_idx(:)) == i))
            subplot(2,ceil(width/2),counter)
            print_8gates_cells(bool_eq(round(counter2/2),:),PI{nb_decimal+1,1}(i,:),counter);
            counter = counter + 1;
            counter2 = counter2 + 1;
        elseif (nb_norgates{nb_decimal+1,1}(i) > N)
            subplot(2,ceil(width/2),counter)
            print_individual_cells(bin2dec(binary_rep),all_perms,counter,total_offending_terms);
            counter = counter + 1;
        end
    end
    if ~isempty(all_gates)
        for i = 1:size(all_gates{best_idx,1},2)
            subplot(2,ceil(width/2),counter)
            print_individual_cells(all_gates_bin{best_idx,1}(i),all_perms,counter,total_offending_terms);
            counter = counter + 1;
        end
    end
else
   print_graphs(summary(nb_decimal+1,2),find(inputs_4 == summary(dec_rep(nb_decimal+1,1)+1),1),remaining_terms,0);
end

fprintf('The NOR gate requirements are: ') 
for i = 1:size(PI{nb_decimal+1,1},1)
    fprintf('%i ',nb_norgates{nb_decimal+1,1}(i))
end
fprintf('\n')

[max_norgate,max_nor_index] = max(nb_norgates{nb_decimal+1,1});

end
