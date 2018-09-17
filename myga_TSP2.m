
function myga_TSP2(edgenum)

    % mainly amended by Chen Zhen, 2012~2016

    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    [Clist,CityLoc,CityPop]=testcase;% clist��ֱ������ϵ����

    population_size=70; %��ʼ��Ⱥ��С
    parent_number = 50;
    child_num = population_size - parent_number;
    gnmax=500;  %������
    pc=0.8; %�������
    mutation_rate=0.8; %�������

    %������ʼ��Ⱥ
    population=zeros(parent_number,edgenum);
    for i=1:parent_number
        temp = randperm(BitNum);
        population(i,:) = temp(1:edgenum);
    end
    [~,p]=objf(population,Clist,CityPop,edgenum);

    gn=1;
    fopt=zeros(gn,1);
    ymean=zeros(gn,1);
    ymax=zeros(gn,1);
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
        for i = 1:size(smnew,1)
            i
            flag = test_liantong(smnew(i,:))
            assert (flag==1);
        end
        [f,p]=objf(population1,Clist,CityPop,edgenum);  %��������Ⱥ����Ӧ��
            % index��¼�����ÿ��ֵԭ��������
        [f, index] = sort(f,'descend'); % ����Ӧ�Ⱥ���ֵ��С��������
        population = population1(index(1:parent_number), :); % �ȱ���һ���ֽ��ŵĸ���
        %��¼��ǰ����ú�ƽ������Ӧ��
        

        %ymean(gn)=1000/mean(f);
        %ymax(gn)=1000/fmax;
        %��¼��ǰ������Ѹ���
        x=population(1,:);
        xmax(gn,:)=x;
        gn=gn+1;
        fopt(gn) = fobj(x(end,1:edgenum),Clist,CityPop);
    end

    [f,X]=fobj(xmax(end,1:edgenum),Clist,CityPop);
    figure;clf;hold on;
    plot(CityLoc(:,2),CityLoc(:,1),'rs');
    for ii=1:CiteNum
        for jj=1:CiteNum
            if (X(ii,jj)==1)
                plot([CityLoc(ii,2) CityLoc(jj,2)],...
                    [CityLoc(ii,1) CityLoc(jj,1)],'b-');
            end
        end
    end
    title(['����Ϊ' num2str(f)])
    ylabel('γ��');
    xlabel('����');
    figure;
    plot(fopt);
    ylabel('�����ֵ');
    xlabel('��������');
    title(['������Ϊ' num2str(edgenum)]);
    pause(0.01);
    figure;
end

%------------------------------------------------
%����������Ⱥ����Ӧ��,���ؼ�ֵ�������ۼƸ���
function [cost,p]=objf(population,Clist,CityPop,edgenum)

    inn=size(population,1);  %��ȡ��Ⱥ��С
    cost=zeros(inn,1);
    for i=1:inn
        cost(i)=fobj(population(i,1:edgenum),Clist,CityPop);  %���㺯��ֵ������Ӧ��
    end
    cost=cost'; %ȡ���뵹��
    %���ݸ������Ӧ�ȼ����䱻ѡ��ĸ���
    fsum=0;
    for i=1:inn
        fsum=fsum+cost(i)^15;% ����Ӧ��Խ�õĸ��屻ѡ�����Խ��
    end
    ps=zeros(inn,1);
    for i=1:inn
        ps(i)=cost(i)^15/fsum;
    end

    %�����ۻ�����
    p=zeros(inn,1);
    p(1)=ps(1);
    for i=2:inn
        p(i)=p(i-1)+ps(i);
    end
    p=p';
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
    row_num = size(population,1)
    edge_num = size(population,2)
    i = 1;
    while i<row_num
        if length(unique(population(i,:)))~=edge_num
            i
            population(i,:)=[]
            row_num=row_num-1
            continue;
        end
        arr = eye(12);
        num =0;
        for line_id=1:edge_num
            line_index=population(i,line_id);
            x=0;y=0;
            x = line_info(line_index,1);
            y = line_info(line_index,2);
            arr(x,y)=1;
            num=num+1;
        end
        arr1 = arr+arr';
        %view(biograph(arr,[],'ShowArrows','off','ShowWeights','on'));% ��ʾͼ
        if ~canget(arr1)
            population(i,:)=[];
            row_num=row_num-1;
            continue;
        end
        i=i+1;
         
    end

end
function flag=canget(A)
    n=length(A);
    P=A;
    for i1=2:n
        P=P+A^i1;
    end
    flag = all(all(P));
end

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
    adjacency=arr+arr';
end 
function flag=test_liantong(array16)
    adjacency=get_adjacency(array16);
    flag = canget(adjacency);
end
function [Clist,CityLoc,CityNum]=testcase
    CityLoc=[39.91667 116.41667;
        45.75000 126.63333;
        43.45 87.36;
        34.26667,108.95000;
        34.76667,113.65000;
        31.14 121.29;
        30.35 114.17;
        29.35 106.33;
        30.40 104.04;
        29.39 91.08;
        25.04 102.42;
        23.16667,113.23333];
    CityNum = [1961.24 1063.60 311.03 846.78 862.65 2301.91 978.54 2884.62 1404.76...
        55.94 643.20 1035.79];

    axesm utm   %����ͶӰ��ʽ������MATLAT�Դ���Universal Transverse Mercator ��UTM����ʽ
    Z=utmzone(CityLoc);%utmzone����latlon20���������ѡ������Ϊ���ʵ�ͶӰ���򣬿�����һ��̨վ�ľ�γ�ȣ�Ҳ����������̨վ�ľ�γ�ȣ���ʱ��ƽ����
    setm(gca,'zone',Z)
    h = getm(gca);
    R=zeros(size(CityLoc));
    for i=1:length(CityLoc)
        [x,y]= mfwdtran(h,CityLoc(i,1),CityLoc(i,2));
        Clist(i,:)=[x;y]/1e3;
    end
end