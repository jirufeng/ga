function adjacency=get_adjacency(array16_33) 
    arr=eye(12);
    global line_info;
    num =0;
    for line_id=1:length(array16_33)
        line_index=array16_33(line_id);
        x1 = line_info(line_index,1);
        y1 = line_info(line_index,2);
        arr(x1,y1)=1;
        num=num+1;
    end
    adjacency=arr+arr';
end 