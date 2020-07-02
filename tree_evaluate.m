function [bin_nb,gate_nb,input_nb] = evaluate_tree(nodes,node_names)
    vector_count = zeros(1,length(nodes));
    vector_term = zeros(1,length(nodes));
    for k = 1:length(nodes)
       if nodes(k) ~= 0 
            vector_count(1,nodes(k)) = vector_count(1,nodes(k)) + 1;
       end
    end
    counter = 1;
    for i = 1:length(nodes)
        if (vector_count(i) == 0)
            node_names2{1,counter} = node_names{1,i};
            node_loc(counter) = i;
            vector_term(i) = 1;
            counter = counter + 1;
        end
    end
    [terminal_nodes,~,terminal_loc] = unique(node_names2,'stable');

    gate_nb = length(nodes) - length(terminal_loc);
    input_nb = length(terminal_nodes);
    for i = 1:(2^input_nb)
        test_bin(i,:) = dec2bin(i-1,input_nb);
    end
    
    %terminal_nodes
    
    for i = 1:size(test_bin,1)
        vector_term2 = vector_term;
        vector_value = zeros(1,length(nodes));
        for j = 1:length(terminal_loc)
            if test_bin(i,terminal_loc(j)) == '0'
               vector_value(1,node_loc(j)) = 0;
            else
               vector_value(1,node_loc(j)) = 1;
            end
        end
        
        while ~all(vector_term2)
            for k = 1:length(nodes)
                if ((vector_count(k) == 2) && (vector_term2(k) == 0))
                    curr = find(nodes == k);
                    if vector_term2(curr(1)) == 1 && vector_term2(curr(2)) == 1
                        if vector_value(curr(1)) == 0 && vector_value(curr(2)) == 0
                            vector_value(k) = 1;
                            vector_term2(k) = 1;
                        else
                            vector_term2(k) = 1;
                        end
                    end
                elseif ((vector_count(k) == 1) && (vector_term2(k) == 0))
                    curr = find(nodes == k);
                    if vector_term2(curr) == 1 
                        if vector_value(curr) == 0
                            vector_value(k) = 1;
                            vector_term2(k) = 1;
                        else
                            vector_term2(k) = 1;
                        end
                    end
                end
            end
            %vector_term2
        end
        if vector_value(1) == 0
            bin_nb(i) = '0';
        else
            bin_nb(i) = '1';
        end
        %bin_nb = fliplr(bin_nb);
        
    end
end