global line_info dot_array;
setglobal();
arr = zeros(12,12);
for i=1:12
    for j=i+1:12
        arr(i,j)=-line_info(dot_array(i,j),3);
    end
end
A=arr
A = A+A';
result=prim1(A);
arr1 = zeros(1,11);
for i =1:11
    arr1(1,i)=dot_array(result(1,i),result(2,i));
end
arr1
show_graph(arr1);






function result=prim1(a)
% 输入：a—邻接矩阵，a（i，j)是指i到j之间的权值
% 输出：result—第一、二、三行分别代表最小生成树边的起点、终点、权集合
    a(a==0)=inf;
    result=[];
    p=1;
    tb=2:length(a);
    while size(result,2)~=length(a)-1
       temp=a(p,tb);
       temp=temp(:);
       d=min(temp);
       [jb,kb]=find(a(p,tb)==d);
       j=p(jb(1));k=tb(kb(1));
       result=[result,[j;k;d]];
       p=[p,k];
       tb(find(tb==k))=[];
    end
end
