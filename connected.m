function flag=connected(A)
% test if graph is connected
    n=length(A);
    P=A;
    for i1=2:n
        P=P+A^i1;
    end
    flag = all(all(P));
end