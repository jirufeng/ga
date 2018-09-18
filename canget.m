function flag=canget(A)
    n=length(A);
    P=A;
    for i1=2:n
        P=P+A^i1;
    end
    flag = all(all(P));
end