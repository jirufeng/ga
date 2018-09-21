
function ga22(edgenum)

    % mainly amended by Chen Zhen, 2012~2016

    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    setglobal();
    global Clist CityLoc CityPop;

    population_size=300; %初始种群大小
    parent_number = 150;
    child_num = population_size - parent_number;
    gnmax=200;  %最大代数
    pc=1; %交叉概率
    mutation_rate=0.2; %变异概率

    %产生初始种群
    population=zeros(parent_number,edgenum);
    i = 1;
    while i <= parent_number
        temp = randperm(BitNum);
        if test_connected(temp(1:edgenum))==1
            population(i,:) = temp(1:edgenum);
            i = i+1;
        end
    end
    population=die(population);
    %population(1,:) = [57     5    40    60    31    52    41    34    51    46     1    39     6    59    26    58];
    length(population)
    gn=1;
    fopt=zeros(gn,1);
    xmax=zeros(gnmax,edgenum);%第几代
    scnew=zeros(child_num,edgenum);%孩子
    smnew=zeros(child_num,edgenum);%变异，先生孩子，然后变异
    while gn<gnmax+1
        for j=1:2:child_num
            seln=sel(population);  %选择操作
            scro=cro(population,seln,pc);  %交叉操作
            scnew(j,:)=scro(1,:);
            scnew(j+1,:)=scro(2,:);
            smnew(j,:)=mut(scnew(j,:),mutation_rate);  %变异操作
            smnew(j+1,:)=mut(scnew(j+1,:),mutation_rate);
        end
        smnew=die(smnew);
        population1=[population;smnew];  %产生了新的种群
        f=objf(population1);  %计算新种群的适应度
            % index记录排序后每个值原来的行数
        [f, index] = sort(f,'descend') % 将适应度函数值从小到大排序
        population = population1(index(1:parent_number), :); % 先保留一部分较优的个体
        %记录当前代最好和平均的适应度
        %记录当前代的最佳个体
        x=population(1,:);
        xmax(gn,:)=x;
        gn=gn+1;
        fopt(gn) = get_value(x);
    end

    f = get_value(xmax(end,1:edgenum));
    '最大价值图is:'
    xmax(end,1:edgenum)
    show_graph(xmax(end,1:edgenum),f)
    
    plot(fopt);
    ylabel('网络价值');
    xlabel('迭代次数');
    title(['连接数为' num2str(edgenum)]);
    pause(0.01);
    figure;
end

%------------------------------------------------
%计算所有种群的适应度,返回价值向量和累计概率
function cost=objf(population)
    edgenum = size(population,2);
    inn=size(population,1);  %读取种群大小
    cost=zeros(inn,1);
    for i=1:inn
        cost(i)=get_value(population(i,1:edgenum));
    end
    cost=cost'; %取距离倒数
end

%--------------------------------------------------
%根据变异概率判断是否变异
function pcc=pro(pc)
    test(1:100)=0;
    l=round(100*pc);
    test(1:l)=1;
    n=round(rand*99)+1;
    pcc=test(n);
end

%--------------------------------------------------
%“选择”操作
function seln=sel(p)
    seln=zeros(2,1);
    num = size(p,1);
    c1 = randi([1 num]);
    c2 = randi([1 num]);
    while c1 == c2
        c2 = randi([1 num]);
    end
    seln(1)=c1;
    seln(2)=c2;
end

%------------------------------------------------
%“交叉”操作
function scro=cro(population,seln,pc)

    edgenum=size(population,2);
    pcc=pro(pc);  %根据交叉概率决定是否进行交叉操作，1则是，0则否
    scro(1,:)=population(seln(1),:);%选择的
    scro(2,:)=population(seln(2),:);
    if pcc==1
        c1 = randi([1 edgenum]);
        middle=scro(1,1:c1);
        scro(1,1:c1)=scro(2,1:c1);
        scro(2,1:c1)=middle;
    end
end

%--------------------------------------------------
%“变异”操作
function snnew=mut(snew,mutation_rate)
    snnew=snew;
    edgenum=size(snew,2);
    mutation_ratem=pro(mutation_rate);  %根据变异概率决定是否进行变异操作，1则是，0则否
    if mutation_ratem==1
        c1 = randi([1 edgenum]);
        snnew(c1) = randi([1 66]);
    end
end

function population = die(population)
    global line_info;
    delete=[];
    delete_index = 1;
    row_num = size(population,1)
    edge_num = size(population,2)
    i = 1;
    while i<=row_num
        arr = eye(12);
        num =0;
        for line_id=1:edge_num
            line_index=population(i,line_id);
            x = line_info(line_index,1);
            y = line_info(line_index,2);
            arr(x,y)=1;
            num=num+1;
        end
        arr1 = arr+arr';
        %view(biograph(arr,[],'ShowArrows','off','ShowWeights','on'));% 显示图
        if ~connected(arr1)
            delete(delete_index)=i;
            delete_index=delete_index+1;
            i=i+1;
            continue;
        end
        i=i+1;    
    end
    population(delete,:)=[]

end

