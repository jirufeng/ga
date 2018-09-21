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
%myga_TSP2(33);
ga23(33)
%ga_TSP2(33);
