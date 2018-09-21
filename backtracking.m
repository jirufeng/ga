backtracking_(33)
function result=backtracking_(edgenum)
    global line_info;
    setglobal();
    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    global Clist CityLoc CityPop;% clist是直角坐标系坐标
    [line_info_order,index]=sortrows(line_info,-3);
    stack = [];
    stack_locate = [];
    stack_size=0;
    line_order = 1;
    
    break_flag = 0;
    result = zeros(50,edgenum);
    result_max_size = size(result,1);
    result_size = 0;
    while line_order<=66
        while line_order<=66 
            stack(stack_size+1)=line_order;
            stack_size=stack_size+1;
            line_order=line_order+1;
            if stack_size == edgenum
                if test_connected(index(stack(1:edgenum))')
                    result(result_size+1,:)=index(stack(1:edgenum))';
                    result_size=result_size+1;
                    if result_size==result_max_size
                        break_flag = 1;
                        break
                    end
                else
                    if line_order~=67
                        num = stack(stack_size);
                        stack_size=stack_size-1;
                    end
                end
            end
        end
        if break_flag ==1 
            break
        end
        if line_order==67
            num = stack(stack_size);
            stack_size=stack_size-1;
            if num +1 == line_order
                num = stack(stack_size);
                stack_size=stack_size-1;
            end
            line_order = num +1;
        end
    end
    max_value = 0;
    max_index = 0;
    for i =1:50
        value = get_value(result(i,:));
        if value>max_value
            max_value = value;
            max_index = i;
        end
    end
        
    max_choice = result(max_index,:)
    get_view(max_choice);
    value = get_value(max_choice);
    show_graph(max_choice,value);
end