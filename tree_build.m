function [nb_QS] = tree_build(graphs,index,nb_inputs,maxgates,permutation,offending,N)
    load('data/summary.mat')
    if ~exist('N')
        N = 7;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Creating vector with all the node names %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:(maxgates(index)+nb_inputs)
        if i <= nb_inputs
            var_names{i,1} = sprintf('x_%i',permutation(i)-1); 
        else
            var_names{i,1} = sprintf('g_%i',i-1);
        end
    end
    nb_QS = -1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Parsing graph into tree nodes structure %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var_count = zeros(length(var_names),1);
    find_counts = cell(size(graphs,2),3);
    var_loc = cell(length(var_names),2);
    for i = 1:size(graphs,2)
        for j = 1:length(var_names)
            if ~isempty(graphs{index,i})
                find_counts{i,1} = [find_counts{i,1} strfind(graphs{index,i},var_names{j})];
                find_counts{i,2} = unique([find_counts{i,2} strfind(graphs{index,i},'/ \')]);
                find_counts{i,3} = unique([find_counts{i,3} strfind(graphs{index,i},' | ')]);
                if strfind(graphs{index,i},var_names{j}) 
                    var_loc{j,1} = [var_loc{j,1} repmat(i,length(strfind(graphs{index,i},var_names{j})),1)'];
                    var_loc{j,2} = [var_loc{j,2} strfind(graphs{index,i},var_names{j})];
                    var_count(j) = var_count(j) + 1;
                end
            end
        end
    end
    counter = 0;
    for i = 1:size(var_loc,1)
        for j = 1:length(var_loc{i,1})
            counter = counter + 1;
            node_ranking(counter,:) = [i,var_loc{i,1}(j)+var_loc{i,2}(j)/100];
        end
    end
    for i = 1:length(var_names)
       if strfind(var_names{i,1},'g_')
            var_names{i,1}=strrep(var_names{i,1},'g_','g_{');
            var_names{i,1} = strcat(var_names{i,1},'}');
       end
    end
    
    [~,inx]=sort(node_ranking(:,2));
    node_ranking = node_ranking(inx,:);
    nodes_names = cell(size(node_ranking,1),1);
    nodes  = zeros(sum(var_count),1)';
    counter = 1;
    node_count = zeros(size(find_counts,1),1);
    for i = 1:size(find_counts,1)
       node_count(i) = length(find_counts{i,1});
    end
    node_count(:,2) = cumsum(node_count);
    sum_varcounts = cumsum(var_count);
    for i = 2:2:size(find_counts,1)-1
        nb_1conn = length(find_counts{i,3});
        nb_2conn = length(find_counts{i,2});

        all_conn = [find_counts{i,3}' ones(length(find_counts{i,3}),1);
                    find_counts{i,2}' ones(length(find_counts{i,2}),1)*2];

        [~,inx]=sort(all_conn(:,1));
        all_conn = all_conn(inx,:);

        for j = 1:size(all_conn,1)
            if all_conn(j,2) == 1
                counter = counter + 1;
                [~,index_1conn] = min(abs(sort(find_counts{i-1,1}) - all_conn(j,1)));
                nodes(counter) = node_count(i-1,2) - node_count(i-1,1) + index_1conn;
            else
                for k = 1:2
                    counter = counter + 1;
                    [~,index_2conn] = min(abs(sort(find_counts{i-1,1}) - all_conn(j,1)));
                    nodes(counter) = node_count(i-1,2) - node_count(i-1,1) + index_2conn;
                end
            end
        end
    end
    for i = 1:size(node_ranking,1)
        nodes_names{i,1} = var_names{node_ranking(i,1),1};
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Count number of gates with repeats %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:length(nodes)
        if ~isempty((strfind(nodes_names{i,1},'x_')))
            terminal(i) = 1;
        else
            terminal(i) = 0;
        end
    end
    terminal_copy = terminal;
    gates = 1 - terminal;
    gates_number = zeros(1,length(gates));
    unique_nodes = unique(nodes);
    for i = 1:length(unique_nodes)
        idx = find(nodes == unique_nodes(i));
        idx_vect = zeros(length(idx),1);
        if all(terminal(idx) == 1)
            gates_number(unique_nodes(i)) = 1;
            gates(unique_nodes(i)) = 0;
            terminal(unique_nodes(i)) = 1;
            for j = 1:length(nodes)
                if strcmp(nodes_names{unique_nodes(i),1},nodes_names{j,1})
                   gates_number(j) = 1; 
                   gates(j) = 0;
                end
            end
            
        end
    end
    for i = 1:length(nodes)
       if gates_number(i) == 1
          terminal(i) = 1;
       end
    end
    for k = 1:100
        for i = 1:length(nodes)
            if gates(i) == 0
               terminal(i) = 1; 
            end
            if gates(i) > 0
                idx = find(nodes == i);
                if ~isempty(idx)
                    if all(terminal(idx) == 1) %&& (nodes(i)>0)
                        gates_number(i) =  gates_number(i) + 1;
                        for j = 1:length(idx)
                           gates_number(i) =  gates_number(i) + gates_number(idx(j));
                        end
                        gates(i) = 0;
                        for j = 1:length(nodes)
                            if strcmp(nodes_names{i,1},nodes_names{j,1})
                               gates_number(j) = gates_number(i); 
                               gates(j) = 0;
                            end
                        end
                    end
                end
            end
        end
    end
    fprintf('Total NOR gates with repeats: %i \n \n',gates_number(1))
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Partitioning graph using 1 QS %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    exclude = {};
    nb_items = 0;
    qs_check = 0;
    if maxgates(index) < N
       nb_QS = 0;
       qs_check = 1; 
    end
    for i = 1:length(gates)
       if gates_number(i) > 0 && gates_number(i) < N && maxgates(index) > N-1
            gates_nb = gates_number(i);
            nb_repeats = 0;
            for j = 1:length(gates)
               if strcmp(nodes_names{i,1},nodes_names{j,1})
                   nb_repeats = nb_repeats + 1;
               end
            end
            nb_items2 = 1;
            gates_above = {};
            for k = 1:length(gates)
                if (strcmp(nodes_names{j,1},nodes_names{k,1}))
                    next = i;
                    while (next > 0)
                        if (next ~= i)
                            gates_above{nb_items2} = nodes_names{next,1};
                        end
                        if (nodes(next)>0)
                           next = nodes(next);
                           nb_items2 = nb_items2 + 1;
                        else
                           next = 0; 
                        end
                    end
                end
            end
            gates_above = uniqueStrCell(gates_above);
            for j = 1:length(gates)
                for k = 1:length(gates_above)
                    if (terminal_copy(j) == 1) && (strcmp(gates_above{k},nodes_names{j,1}))
                        nb_repeats = nb_repeats + 1;
                    end
                end
            end
            final_gatenb = gates_number(1)-nb_repeats*gates_nb;
            
            if (final_gatenb < N) 
                 if isempty(exclude)
                    fprintf('Partitioning possible with %s \n',nodes_names{i,1})
                    fprintf('Final NOR gates with 1 QS: %i / %i \n \n',final_gatenb,gates_number(i))
                    nb_items = nb_items + 1;
                    exclude{nb_items} = nodes_names{i,1};
                    qs_check = 1;
                    if (nb_QS ~= 0)
                        nb_QS = 1;
                    end
                 else
                    if ~(strcmp(exclude,nodes_names{i,1}))
                        fprintf('Partitioning possible with %s \n',nodes_names{i,1})
                        fprintf('Final NOR gates with 1 QS: %i / %i \n \n',final_gatenb,gates_number(i))
                        nb_items = nb_items + 1;
                        exclude{nb_items} = nodes_names{i,1};
                    end
                 end
            end
       end
    end
   if (qs_check == 0)
       exclude = {};
       exclude2= {};
       nb_exclude = 0;
       for i = 2:length(gates)
           for j = 2:length(gates)
               if (i~=j) && ~(strcmp(nodes_names{i,1},nodes_names{j,1})) && (gates_number(i)>=gates_number(j)) && (gates_number(j) > 0)
                    nb_items = 1;
                    gates_above = {};
                    for k = 1:length(gates)
                        if (strcmp(nodes_names{i,1},nodes_names{k,1}))
                            next = i;
                            gates_above = {};
                            while (next > 0)
                                if (next ~= i)
                                    gates_above{nb_items} = nodes_names{next,1};
                                end
                                if (nodes(next)>0)
                                   next = nodes(next);
                                   nb_items = nb_items + 1;
                                else
                                   next = 0; 
                                end
                            end
                        end
                    end
                    gates_above = uniqueStrCell(gates_above);
                    check_concatenated = 0;
                    nb_items = 1;
                    gates_above2 = {};
                    for k = 1:length(gates)
                        if (strcmp(nodes_names{j,1},nodes_names{k,1}))
                            next = k;
                            while (next > 0)
                                if (next ~= k)
                                    gates_above2{nb_items} = nodes_names{next,1};
                                end
                                if (nodes(next)>0)
                                   next = nodes(next);
                                   nb_items = nb_items + 1;
                                else
                                   next = 0; 
                                end
                            end
                        end
                    end
                    gates_above2 = uniqueStrCell(gates_above2);
                    for k = 1:length(gates_above2)
                        if (strcmp(gates_above2{k},nodes_names{i,1}))
                            check_concatenated = 1;
                        end
                    end
                    nb_repeats = 0;
                    nb_repeats2 = 0;
                    if (check_concatenated == 0)
                        for k = 1:length(gates)
                           if strcmp(nodes_names{i,1},nodes_names{k,1})
                               nb_repeats = nb_repeats + 1;
                           end
                           if strcmp(nodes_names{j,1},nodes_names{k,1})
                               nb_repeats2 = nb_repeats2 + 1;
                           end
                           for l = 1:length(gates_above)
                               if (terminal_copy(k) == 1) && (strcmp(gates_above{l},nodes_names{k,1}))
                                   nb_repeats = nb_repeats + 1;
                               end
                           end
                           for l = 1:length(gates_above2)
                               if (terminal_copy(k) == 1) && (strcmp(gates_above2{l},nodes_names{k,1}))
                                   nb_repeats2 = nb_repeats2 + 1;
                               end
                           end
                        end
        
                        final_gatenb = gates_number(1)-nb_repeats*gates_number(i)-nb_repeats2*gates_number(j);
                        if (final_gatenb < N) && (gates_number(i) < N) && (gates_number(j) < N)
                             if isempty(exclude)
                                fprintf('Partitioning possible with %s and %s\n',nodes_names{i,1},nodes_names{j,1})
                                fprintf('Final NOR gates with 2 QS in parallel: %i / %i / %i \n \n',final_gatenb,gates_number(i),gates_number(j))
                                nb_exclude = nb_exclude + 1;
                                exclude{nb_exclude} = nodes_names{i,1};
                                exclude2{nb_exclude} = nodes_names{j,1};
                                nb_QS = 2;
                             else
                                check = 0;
                                for k  = 1:nb_exclude
                                    if strcmp(nodes_names{i,1},exclude{k}) && strcmp(nodes_names{j,1},exclude2{k})
                                       check = 1; 
                                    end
                                end
                                if check == 0
                                    fprintf('Partitioning possible with %s and %s\n',nodes_names{i,1},nodes_names{j,1})
                                    fprintf('Final NOR gates with 2 QS in parallel: %i / %i / %i \n \n',final_gatenb,gates_number(i),gates_number(j))
                                    nb_exclude = nb_exclude + 1;
                                    exclude{nb_exclude} = nodes_names{i,1};
                                    exclude2{nb_exclude} = nodes_names{j,1};
                                end
                             end
                        end
                    else
                        for k = 1:length(gates)
                           if strcmp(nodes_names{i,1},nodes_names{k,1})
                               nb_repeats = nb_repeats + 1;
                           end
                           if strcmp(nodes_names{j,1},nodes_names{k,1})
                               nb_repeats2 = nb_repeats2 + 1;
                           end
                           for l = 1:length(gates_above)
                               if (terminal_copy(k) == 1) && (strcmp(gates_above{l},nodes_names{k,1}))
                                   nb_repeats = nb_repeats + 1;
                               end
                           end
                           for l = 1:length(gates_above2)
                               if (terminal_copy(k) == 1) && (strcmp(gates_above2{l},nodes_names{k,1}))
                                   nb_repeats2 = nb_repeats2 + 1;
                               end
                           end
                        end
        
                        final_gatenb = gates_number(1)-nb_repeats*(gates_number(i)-gates_number(j))-nb_repeats2*gates_number(j);
                        if (final_gatenb < N) && (gates_number(i)-gates_number(j) < N) && (gates_number(j) < N)
                             if isempty(exclude)
                                nb_QS = 2;
                                fprintf('Partitioning possible with %s and %s\n',nodes_names{i,1},nodes_names{j,1})
                                fprintf('Final NOR gates with 2 QS in series: %i / %i / %i \n \n',final_gatenb,gates_number(i)-gates_number(j),gates_number(j))
                                nb_exclude = nb_exclude + 1;
                                exclude{nb_exclude} = nodes_names{i,1};
                                exclude2{nb_exclude} = nodes_names{j,1};
                             else
                                check = 0;
                                for k  = 1:nb_exclude
                                    if strcmp(nodes_names{i,1},exclude{k}) && strcmp(nodes_names{j,1},exclude2{k})
                                       check = 1; 
                                    end
                                end
                                if check == 0
                                    fprintf('Partitioning possible with %s and %s\n',nodes_names{i,1},nodes_names{j,1})
                                    fprintf('Final NOR gates with 2 QS in series: %i / %i / %i \n \n',final_gatenb,gates_number(i)-gates_number(j),gates_number(j))
                                    nb_exclude = nb_exclude + 1;
                                    exclude{nb_exclude} = nodes_names{i,1};
                                    exclude2{nb_exclude} = nodes_names{j,1};
                                end
                             end
                        end
                    end

               end
           end
       end
   end
    
    if ~exist('plotting')
       tree_plot(nodes,nodes_names,offending)
    end
end
