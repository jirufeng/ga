function value = fitness23(graph)
    global line_info dot_array;
    %line_info各列 第一个城市序号 第二个城市序号 最大价值 平均人口 最大容量 实际容量 是否实际联通 是否虚拟联通 调整次数 是否不分配流量
    %初始容量
    %距离矩阵设计，人口越多，距离越远，流量越多，距离越近，流量为0为无限远，和目标函数有相关。两条线段平均。乘法开根号，乘法好像是尽可能找中间的。
    line_info(:,[6 7 8 9 10,11])=0;
    for i = 1:length(graph)
        line_info(graph(i),6) = line_info(graph(i),6)+line_info(graph(i),5);
        line_info(graph(i),7) = 1;
        line_info(graph(i),8) = 1;
        line_info(graph(i),11)=line_info(graph(i),6);
    end
    [line_info_order,index]=sortrows(line_info,-4);
    value_first = get_value();
    for j=1:5
        for i = 1: length(line_info)
            if line_info(index(i),8)==1
                continue;
            end
            flow_m = get_flow_m();
            [shortestPath, totalCost] = Dijkstra(flow_m,line_info(index(i),1),line_info(index(i),2));
            %转发只有一条路径。两点间通讯只有一条路径。
            if length(shortestPath)~=3
                continue
            end
            alloc_flow = if_alloc(shortestPath);
            line1 = dot_array(shortestPath(1),shortestPath(2));
            line2 = dot_array(shortestPath(2),shortestPath(3));
            line3 = dot_array(shortestPath(1),shortestPath(3));
            if alloc_flow~=0

                line_info(line1,6)=line_info(line1,6)-alloc_flow;
                line_info(line2,6)=line_info(line2,6)-alloc_flow; 
                line_info(line3,6)=alloc_flow;
                line_info(line1,9)=line_info(line1,9)+1;
                line_info(line2,9)=line_info(line2,9)+1;
                line_info(line3,9)=line_info(line3,9)+1;
                line_info(line3,8)=1;
            else
                line_info(line3,10)=1;
            end
        end
    end
    for i = 1: length(line_info)
        if line_info(index(i),8)==1
            continue;
        end
        flow_m = get_flow_m();
        [shortestPath, totalCost] = Dijkstra(flow_m,line_info(index(i),1),line_info(index(i),2));
        %转发只有一条路径。两点间通讯只有一条路径。
        if length(shortestPath)~=3
            continue
        end
        alloc_flow = if_alloc1(shortestPath);
        if alloc_flow~=0
            line1 = dot_array(shortestPath(1),shortestPath(2));
            line2 = dot_array(shortestPath(2),shortestPath(3));
            line3 = dot_array(shortestPath(1),shortestPath(3));
            line_info(line1,6)=line_info(line1,6)-alloc_flow;
            line_info(line2,6)=line_info(line2,6)-alloc_flow; 
            line_info(line3,6)=alloc_flow;
            line_info(line1,9)=line_info(line1,9)+1;
            line_info(line2,9)=line_info(line2,9)+1;
            line_info(line3,9)=line_info(line3,9)+1;
            line_info(line3,8)=1;
        else
            line_info(line3,10)=1;
        end
    end
    value_last = get_value();
    value = value_last;
    arr1 = zeros(12,12);
    arr2=zeros(12,12);
    for i=1:66
        arr1(line_info(i,1),line_info(i,2))=line_info(i,11);
        arr2(line_info(i,1),line_info(i,2))=line_info(i,6);
    end
end
function num=get_value()
    global line_info;
    num = 0;
    for i = 1:length(line_info)
        num=num+network_value(line_info(i,4),line_info(i,6));
    end
end
function num=get_last_flow()
    global line_info;
    num = sum(line_info(:,6))
end
function num = get_all_flow()
    global line_info;
    num = 0;
    for i = 1:length(line_info)
        num=num*line_info(i,5)*line_info(i,7);
    end
end
function value = network_value(popu,flow)
    value = popu^2*flow^(0.5);
end
function best_flow = if_alloc(shortestPath)
    global dot_array line_info
    line1 = dot_array(shortestPath(1),shortestPath(2));
    line2 = dot_array(shortestPath(2),shortestPath(3));
    line3 = dot_array(shortestPath(1),shortestPath(3));
    flow_max = min(line_info(line1,6),line_info(line2,6));
    alloc_flow = 0;
    max_value = 0;
    best_flow = 0;
    while alloc_flow < flow_max
        value = network_value(line_info(line3,4),alloc_flow)+network_value(line_info(line1,4),line_info(line1,6)-alloc_flow)+...
            network_value(line_info(line2,4),line_info(line2,6)-alloc_flow);
        if value > max_value
            max_value = value;
            best_flow = alloc_flow;
        end
        alloc_flow=alloc_flow+0.25;
    end
end
function best_flow = if_alloc1(shortestPath)
    global dot_array line_info
    line = dot_array(shortestPath(1),shortestPath(3));
    len = length(shortestPath);
    line_arr=[]
    for i=1:len-1
        line_arr=[line_arr,dot_array(shortestPath(i),shortestPath(i+1))]
    end
    flow_max = min(line_info(line_arr,6));
    alloc_flow = 0;
    max_value = 0;
    best_flow = 0;
    while alloc_flow < flow_max
        value = network_value(line_info(line,4),alloc_flow);
        for i = 1:len-1
            value = value+network_value(line_info(line_arr(i),4),line_info(line_arr(i),6)-alloc_flow);
        end
        if value > max_value
            max_value = value;
            best_flow = alloc_flow;
        end
        alloc_flow=alloc_flow+0.25;
    end
end
    
function flow_m = get_flow_m()
    global line_info;
    flow_m = zeros(12,12);
    for i=1:66
        if line_info(i,6)~=0
            flow_m(line_info(i,1),line_info(i,2))=line_info(i,4)^(2)*(line_info(i,6)*0.8^line_info(i,9))^(-0.5);
            flow_m(line_info(i,2),line_info(i,1))=line_info(i,4)^(2)*(line_info(i,6)*0.8^line_info(i,9))^(-0.5);
        else
            flow_m(line_info(i,1),line_info(i,2))=Inf;
            flow_m(line_info(i,2),line_info(i,1))=Inf;
        end
    end
end
    