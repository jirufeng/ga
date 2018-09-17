function [f,X]=fobj2(XId,XFp,CityDis,CityLoc,CityNum)%XID包括存在的边数和另一个信息，XFP是每两个点的流量
    CN = size(CityLoc,1);

    %计算邻接矩阵
    X = 1-tril(ones(CN,CN),0);
    X = X(:);
    Ind = find(X==1);
    X(Ind)=1:length(Ind);
    Xc = zeros(1,CN*CN);

    for ii=1:length(XId)
        X(X==XId(ii,1))=XId(ii,2);
        Xc(X==XId(ii,1)) = 1;

    end
    X(Xc==0)=0;
    X = reshape(X,CN,CN);

    X = X+X';
    XInt = X>0;
    CityDis= CityDis.*XInt;
    CityDis(XInt==0) = Inf;

    %直达路径速率 计算
    Xload = ones(CN,CN);
    SnrReq = [Inf 3000 1200 600];
    RateTable = [0 8 16 32];
    for ii =1:CN
        for jj=1:CN
            if (X(ii,jj)>=1)
                Dist= norm(CityLoc(ii,:)-CityLoc(jj,:));
                Ind = find(SnrReq>Dist);
                ModRate = RateTable(Ind(end));
                Xload(ii,jj) = X(ii,jj)*ModRate;
            end
        end
    end


    %计算含一个中间结点情况下的速率分配
    Xload2 = zeros(CN,CN);
    XFp = XFp*sum(Xload(:))/4;
    for ii =1:CN
        for jj=ii+1:CN
            [shortestPath, totalCost] = Dijkstra(CityDis, ii, jj);

            if (totalCost==Inf || length(shortestPath)~=3)
                Xload2(ii,jj) = 0;
                Xload2(jj,ii) = 0;
            else
                Xload2(jj,ii) = XFp(ii,jj);
                Xload2(jj,ii) = XFp(ii,jj);           

                Xload(ii,shortestPath(2))=Xload(ii,shortestPath(2))-XFp(ii,jj);
                Xload(shortestPath(2),ii)=Xload(shortestPath(2),ii)-XFp(ii,jj);
                Xload(shortestPath(2),jj)=Xload(shortestPath(2),jj)-XFp(ii,jj);
                Xload(jj,shortestPath(2))=Xload(jj,shortestPath(2))-XFp(ii,jj);
            end
        end
    end


    if (min(Xload(:))<0)
        f= 0;
        return;
    else
        for ii =1:CN
            for jj=ii+1:CN
                Xload2(ii,jj)= Xload(ii,jj);
                Xload2(jj,ii)= Xload(jj,ii);
            end
        end
    end

    % 计算总的路径
    f = 0;
    for ii =1:CN
        for jj=ii+1:CN
            if (X(ii,jj)>=1)
                Dist= norm(CityLoc(ii,:)-CityLoc(jj,:));
                Ind = find(SnrReq>Dist);
                ModRate = RateTable(Ind(end));
                f = f+ sqrt(CityNum(ii)*CityNum(jj))*Xload2(ii,jj);
            end
        end
    end


end

function [shortestPath, totalCost] = Dijkstra(netCostMatrix, s, d)
%==============================================================
% shortestPath: the list of nodes in the shortestPath from source to destination;
% totalCost: the total cost of the  shortestPath;
% farthestNode: the farthest node to reach for each node after performing the routing;
% n: the number of nodes in the network;
% s: source node index;
% d: destination node index;
%==============================================================
%  Code by:
% ++by Xiaodong Wang
% ++23 Jul 2004 (Updated 29 Jul 2004)
% ++http://www.mathworks.com/matlabcentral/fileexchange/5550-dijkstra-shortest-path-routing
% Modifications (simplifications) by Meral Shirazipour 9 Dec 2009
%==============================================================
n = size(netCostMatrix,1);
for i = 1:n
    % initialize the farthest node to be itself;
    farthestPrevHop(i) = i; % used to compute the RTS/CTS range;
    farthestNextHop(i) = i;
end

% all the nodes are un-visited;
visited(1:n) = false;

distance(1:n) = inf;    % it stores the shortest distance between each node and the source node;
parent(1:n) = 0;

distance(s) = 0;
for i = 1:(n-1),
    temp = [];
    for h = 1:n,
        if ~visited(h)  % in the tree;
            temp=[temp distance(h)];
        else
            temp=[temp inf];
        end
    end;
    [t, u] = min(temp);      % it starts from node with the shortest distance to the source;
    visited(u) = true;         % mark it as visited;
    for v = 1:n,                % for each neighbors of node u;
        if ( ( netCostMatrix(u, v) + distance(u)) < distance(v) )
            distance(v) = distance(u) + netCostMatrix(u, v);   % update the shortest distance when a shorter shortestPath is found;
            parent(v) = u;     % update its parent;
        end;
    end;
end;

shortestPath = [];
if parent(d) ~= 0   % if there is a shortestPath!
    t = d;
    shortestPath = [d];
    while t ~= s
        p = parent(t);
        shortestPath = [p shortestPath];
        
        if netCostMatrix(t, farthestPrevHop(t)) < netCostMatrix(t, p)
            farthestPrevHop(t) = p;
        end;
        if netCostMatrix(p, farthestNextHop(p)) < netCostMatrix(p, t)
            farthestNextHop(p) = t;
        end;
        
        t = p;
    end;
end;

totalCost = distance(d);
end