clear ;clc;close all;
global line_info;
line_info = zeros(66,3);
k=1;
for i=1:12
    for j=i+1:12
        line_info(k,1:2)=[i j];
        k=k+1;
    end
end

array16 = [  20    11    16    21    61    36    28    15    25     7    63    53     4    10    26     1];
%test_liantong(array16)
%myga_TSP2(33);
ga22(33)
%ga_TSP2(33);
function adjacency=get_adjacency(array16) 
    arr=eye(12);
    global line_info;
    num =0;
    for line_id=1:16
        line_index=array16(line_id);
        x1 = line_info(line_index,1);
        y1 = line_info(line_index,2);
        arr(x1,y1)=1;
        num=num+1;
    end
    view(biograph(arr,[],'ShowArrows','off','ShowWeights','on'));
    adjacency=arr+arr';
end 
function flag=test_liantong(array16)
    adjacency=get_adjacency(array16);
    flag = canget(adjacency);
end
function flag=canget(A)
    n=length(A);
    P=A;
    for i1=2:n
        P=P+A^i1;
    end
    flag = all(all(P));
end