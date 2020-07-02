function [nodes2,node_names2,saved_vector] = get_subtree(nodes,node_names,node_nb)
    nodes2 = nodes;
    node_names2 = node_names;
    if node_nb == 1
       nodes2 = nodes;
       node_names2 = node_names;
       saved_vector = 1:length(nodes2);
       return;
    end
    
    vector = zeros(1,length(nodes));
    for i = 1:length(vector)
        curr = i;
        while (nodes(curr) ~= 0)
           if (curr == node_nb)
               vector(i) = 1;
           end
           curr = nodes(curr);
        end
    end
    
    saved_vector = 1:length(vector);
    for i = 1:length(vector)
        if vector(length(vector)-i+1) == 0
            nodes2(length(vector)-i+1) =[];
            node_names2(length(vector)-i+1) =[];
            saved_vector(length(vector)-i+1) = [];
            for j = 1:length(nodes2)
               if (nodes2(j) >=  length(vector)-i+1)
                  nodes2(j) = nodes2(j) - 1; 
               end
            end
        end
    end
end