function [] = tree_plot(nodes,nodes_names,offending)
    [x,y,h,s] = treelayout(nodes);
    leaves = find( y == min(y) );
    num_layers = 1/min(y)-1;
    chains = zeros(num_layers, length(leaves));
    for l=1:length(leaves)
        index = leaves(l);
        chain = [];
        chain(1) = index;
        parent_index = nodes(index);
        j = 2;
        while (parent_index ~= 0)
            chain(j) = parent_index;
            parent_index = nodes(parent_index);
            j = j+1;
        end
        chains(:,l) = padarray(flip(chain), [0, num_layers-length(chain)], 'post');
    end
    y_new = zeros(size(y));
    for i=1:length(nodes)
        [r,c] = find(chains==i, 1);
        y_new(i) = max(y) - (r-1)*1/(num_layers+1);
    end
    hold on
    for c=1:size(chains, 2)
        line_x = x(chains(chains(:,c)>0, c));
        line_y = y_new(chains(chains(:,c)>0, c));
        line(line_x, line_y,'LineWidth',2.5);
    end
    for i = 1:length(nodes_names)
       if strfind(nodes_names{i},'g_')
            nodes_names{i}=strrep(nodes_names{i},'g_','g_{');
            nodes_names{i} = strcat(nodes_names{i},'}');
       end
    end
    xlim([0 1]);
    ylim([0 1]);
    
    if (offending == 1)
        iter_node = size(nodes,2);
        for i = 1:3
            iter_node = nodes(iter_node);
        end
        iter_node2 = nodes(iter_node);
        line([x(iter_node) x(iter_node2)],[y_new(iter_node) y_new(iter_node2)],'LineWidth',2.5,'Color','m');
        text((x(iter_node)+x(iter_node2))/2+0.025, (y_new(iter_node)+y_new(iter_node2))/2+0.01,'QS');
    elseif (offending == 2)
        iter_node = size(nodes,2);
        for i = 1:3
            iter_node = nodes(iter_node);
        end
        iter_node2 = nodes(iter_node);
        line([x(iter_node) x(iter_node2)],[y_new(iter_node) y_new(iter_node2)],'LineWidth',2.5,'Color','m');
        text((x(iter_node)+x(iter_node2))/2+0.025, (y_new(iter_node)+y_new(iter_node2))/2+0.015,'QS');
        last = nodes_names{end};
        nodes_names{end} = nodes_names{end-1};
        nodes_names{end-1} = last;
        scatter((x(iter_node)+x(iter_node2))/2,(y_new(iter_node)+y_new(iter_node2))/2,'filled','LineWidth',2,'MarkerFaceColor','r','MarkerEdgeColor','r');
    end

    text(x(1)+0.02, y_new(1)+0.02, num2str(nodes_names{1}));
    for t=2:length(nodes)
        text(x(t)+0.02, y_new(t)-0.01, num2str(nodes_names{t}));
    end
    for i = 1:length(y_new)
        if (strfind(nodes_names{i},'x_'))
            scatter(x(i), y_new(i), 'filled','LineWidth',2,'MarkerFaceColor','g','MarkerEdgeColor','g');
        else
            scatter(x(i), y_new(i), 'filled','LineWidth',2,'MarkerFaceColor','r','MarkerEdgeColor','r');
        end
    end
    
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1);
    bottom = outerpos(2)+ ti(2);
    ax_width = outerpos(3);
    ax_height = outerpos(4) - 2*ti(2) - 2*ti(4);
    ax.Position = [left bottom ax_width ax_height];
    axis off
end