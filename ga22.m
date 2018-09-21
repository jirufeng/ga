
function ga22(edgenum)

    % mainly amended by Chen Zhen, 2012~2016

    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    setglobal();
    global Clist CityLoc CityPop;

    population_size=300; %��ʼ��Ⱥ��С
    parent_number = 150;
    child_num = population_size - parent_number;
    gnmax=200;  %������
    pc=1; %�������
    mutation_rate=0.2; %�������

    %������ʼ��Ⱥ
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
    xmax=zeros(gnmax,edgenum);%�ڼ���
    scnew=zeros(child_num,edgenum);%����
    smnew=zeros(child_num,edgenum);%���죬�������ӣ�Ȼ�����
    while gn<gnmax+1
        for j=1:2:child_num
            seln=sel(population);  %ѡ�����
            scro=cro(population,seln,pc);  %�������
            scnew(j,:)=scro(1,:);
            scnew(j+1,:)=scro(2,:);
            smnew(j,:)=mut(scnew(j,:),mutation_rate);  %�������
            smnew(j+1,:)=mut(scnew(j+1,:),mutation_rate);
        end
        smnew=die(smnew);
        population1=[population;smnew];  %�������µ���Ⱥ
        f=objf(population1);  %��������Ⱥ����Ӧ��
            % index��¼�����ÿ��ֵԭ��������
        [f, index] = sort(f,'descend') % ����Ӧ�Ⱥ���ֵ��С��������
        population = population1(index(1:parent_number), :); % �ȱ���һ���ֽ��ŵĸ���
        %��¼��ǰ����ú�ƽ������Ӧ��
        %��¼��ǰ������Ѹ���
        x=population(1,:);
        xmax(gn,:)=x;
        gn=gn+1;
        fopt(gn) = get_value(x);
    end

    f = get_value(xmax(end,1:edgenum));
    '����ֵͼis:'
    xmax(end,1:edgenum)
    show_graph(xmax(end,1:edgenum),f)
    
    plot(fopt);
    ylabel('�����ֵ');
    xlabel('��������');
    title(['������Ϊ' num2str(edgenum)]);
    pause(0.01);
    figure;
end

%------------------------------------------------
%����������Ⱥ����Ӧ��,���ؼ�ֵ�������ۼƸ���
function cost=objf(population)
    edgenum = size(population,2);
    inn=size(population,1);  %��ȡ��Ⱥ��С
    cost=zeros(inn,1);
    for i=1:inn
        cost(i)=get_value(population(i,1:edgenum));
    end
    cost=cost'; %ȡ���뵹��
end

%--------------------------------------------------
%���ݱ�������ж��Ƿ����
function pcc=pro(pc)
    test(1:100)=0;
    l=round(100*pc);
    test(1:l)=1;
    n=round(rand*99)+1;
    pcc=test(n);
end

%--------------------------------------------------
%��ѡ�񡱲���
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
%�����桱����
function scro=cro(population,seln,pc)

    edgenum=size(population,2);
    pcc=pro(pc);  %���ݽ�����ʾ����Ƿ���н��������1���ǣ�0���
    scro(1,:)=population(seln(1),:);%ѡ���
    scro(2,:)=population(seln(2),:);
    if pcc==1
        c1 = randi([1 edgenum]);
        middle=scro(1,1:c1);
        scro(1,1:c1)=scro(2,1:c1);
        scro(2,1:c1)=middle;
    end
end

%--------------------------------------------------
%�����족����
function snnew=mut(snew,mutation_rate)
    snnew=snew;
    edgenum=size(snew,2);
    mutation_ratem=pro(mutation_rate);  %���ݱ�����ʾ����Ƿ���б��������1���ǣ�0���
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
        %view(biograph(arr,[],'ShowArrows','off','ShowWeights','on'));% ��ʾͼ
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

