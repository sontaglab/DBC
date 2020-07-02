function [QS_nb] = print_graphs(nb_inputs,index,permutation,offending,N)
    warning off
    load('data/summary.mat')
    load('data/maxgates.mat')
    if nb_inputs == 2
       graphs = graphs_2inputs;
       maxgates = maxgates_2;
    elseif nb_inputs == 3
       graphs = graphs_3inputs;
       maxgates = maxgates_3;
    else
       graphs = graphs_4inputs; 
       maxgates = maxgates_4;
    end
    
    for i = 1:size(graphs,2)
        if ~isempty(graphs{index,i})
            for j = 1:nb_inputs
                graphs{index,i} = strrep(graphs{index,i},sprintf('x_%i',j-1),sprintf('y_%i',permutation(j)-1));
            end
            for j = 1:4
                graphs{index,i} = strrep(graphs{index,i},sprintf('y_%i',j-1),sprintf('x_%i',j-1));
            end
            if ~exist('plotting')
                fprintf('%s\n',graphs{index,i});
            end
        end
    end
    if exist('N')
        QS_nb = tree_build(graphs,index,nb_inputs,maxgates,permutation,offending,N);
    else
        QS_nb = tree_build(graphs,index,nb_inputs,maxgates,permutation,offending);
    end
end