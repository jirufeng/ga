%code22 test if it will alloc network.
setglobal();
%graph is answer1.
graph =[57     5    40    60    31    52    41    34    51    46     1    39     6    59     4     3    47     7    53    42    35    56    62 33    48    17     8    66    15    11    32    26    58]

global line_info dot_array;
%两点序号 最大价值 平均人口 最大流量 实际流量 是否实际联通 是否虚拟联通
for i = 1:length(graph)
    line_info(graph(i),6) = line_info(graph(i),5);
    line_info(graph(i),7) = 1;
    line_info(graph(i),8) = 1;
end
[line_info_order,index]=sortrows(line_info,-4);
for i = 1: length(line_info_order)
    if line_info_order(i,8)==1
        continue;
    end
    flow_m = get_flow_m();
    [shortestPath, totalCost] = Dijkstra(flow_m,line_info_order(i,1),line_info_order(i,2));
    %转发只有一条路径。两点间通讯只有一条路径。
    if length(shortestPath)~=3
        continue
    end
    if if_alloc(shortestPath)
        %not excute
        line1 = dot_array(shortestPath(1),shortestPath(2));
        line2 = dot_array(shortestPath(2),shortestPath(3));
        alloc_flow = min(line_info(line1,6),line_info(line2,6));
        line_info(line1,6)=line_info(line1,6)-alloc_flow;
        line_info(line2,6)=line_info(line2,6)-alloc_flow; 
    end
    
end
function flag = if_alloc(shortestPath)
% test if it will alloc network
global dot_array line_info
flag = 0;
line1 = dot_array(shortestPath(1),shortestPath(2));
    line2 = dot_array(shortestPath(2),shortestPath(3));
    line3 = dot_array(shortestPath(1),shortestPath(3));
    if line_info(line3,4)>line_info(line1,4)+line_info(line2,4)
        flag = 1;
    end
end
    
function flow_m = get_flow_m()
    global line_info;
    flow_m = zeros(12,12);
    for i=1:66
        if line_info(i,6)~=0
            flow_m(line_info(i,1),line_info(i,2))=line_info(i,4)*0.9^line_info(i,9);
            flow_m(line_info(i,2),line_info(i,1))=line_info(i,4)*0.9^line_info(i,9);
        else
            flow_m(line_info(i,1),line_info(i,2))=Inf;
            flow_m(line_info(i,2),line_info(i,1))=Inf;
        end
    end
end
    