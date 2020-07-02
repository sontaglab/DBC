function [] = get_partition(nb_decimal,N)
figure
warning off
load('data/summary.mat')
load('data/maxgates.mat')
load('data/permuted_terms')

all_perms_2 = unique(perms([1 2]),'rows');
all_perms_3 = unique(perms([1 2 3]),'rows');
all_perms_4 = unique(perms([1 2 3 4]),'rows');
all_perms = {all_perms_2;all_perms_3;all_perms_4};
remaining_terms = 1:4;
remaining_terms(permuted_terms(dec_rep(nb_decimal+1,1)+1,:)==1) = [];

nb_inputs = summary(nb_decimal+1,2);
if nb_inputs == 2
    remaining_terms = remaining_terms(all_perms{1,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
    print_graphs(summary(nb_decimal+1,2),find(inputs_2 == summary(dec_rep(nb_decimal+1,1)+1,3)),remaining_terms,0,N);
elseif nb_inputs == 3
    remaining_terms = remaining_terms(all_perms{2,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
    print_graphs(summary(nb_decimal+1,2),find(inputs_3 == summary(dec_rep(nb_decimal+1,1)+1,3)),remaining_terms,0,N);
else
    remaining_terms = remaining_terms(all_perms{3,1}(summary(dec_rep(nb_decimal+1,1)+1,4),:));
    print_graphs(summary(nb_decimal+1,2),find(inputs_4 == summary(dec_rep(nb_decimal+1,1)+1,1)),remaining_terms,0,N);
end

end