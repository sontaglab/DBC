function [] = print_8gates_cells(bool_eq,minterm,nb_subplot)
    offending = 1;
    nodes = [0 1 1 2 3 5 5 7 8 8 9 10];
    nodes_names = {'g_4','g_5','g_6','','g_7','','g_8','g_9','g_10','g_11','',''};
    counter = 0;
    for i = 1:4
        if (minterm(i) == string(bool_eq(i))) && (minterm(i) == '0')
            nodes_names{4} = sprintf('x_%i',i-1);
        elseif (minterm(i) == string(bool_eq(i))) && (minterm(i) == '1')
            nodes_names{end-1+counter} = sprintf('x_%i',i-1);
            counter = counter + 1;
        else
            nodes_names{6} = sprintf('x_%i',i-1);
        end
    end
    treeplot_cust(nodes,nodes_names,offending)
    title(sprintf('Cell #%i, NOR gates: %i',nb_subplot,8))
    set(gca,'xtick',[],'ytick',[]);
    box on

end