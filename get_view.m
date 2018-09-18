function adjacency=get_view(array16) 
    arr=eye(12);
    global line_info;
    num =0;
    for line_id=1:length(array16)
        line_index=array16(line_id);
        x1 = line_info(line_index,1);
        y1 = line_info(line_index,2);
        arr(x1,y1)=1;
        num=num+1;
    end
    view(biograph(arr,[],'ShowArrows','off','ShowWeights','on'));
    adjacency=arr+arr';
end 