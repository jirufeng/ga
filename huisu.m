huisu1(16)

function flag=canget(A)
    n=length(A);
    P=A;
    for i1=2:n
        P=P+A^i1;
    end
    flag = all(all(P));
end
function adjacency=get_view(array16) 
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
    CityLoc=[39.91667 116.41667;%北京
        45.75000 126.63333;%哈尔滨
        43.45 87.36;%乌鲁木齐
        34.26667,108.95000;
        34.76667,113.65000;
        31.14 121.29;%上海
        30.35 114.17;
        29.35 106.33;%重庆
        30.40 104.04;%成都
        29.39 91.08;%拉萨
        25.04 102.42;
        23.16667,113.23333];
    CityNum = [1961.24 1063.60 311.03 846.78 862.65 2301.91 978.54 2884.62 1404.76...
        55.94 643.20 1035.79]/100;

    axesm utm   %设置投影方式，这是MATLAT自带的Universal Transverse Mercator （UTM）方式
    Z=utmzone(CityLoc);%utmzone根据latlon20里面的数据选择他认为合适的投影区域，可以是一个台站的经纬度，也可以是所有台站的经纬度（此时是平均）
    setm(gca,'zone',Z)
    h = getm(gca);
    R=zeros(size(CityLoc));
    for i=1:length(CityLoc)
        [x,y]= mfwdtran(h,CityLoc(i,1),CityLoc(i,2));
        Clist(i,:)=[x;y]/1e3;
    end
end
function value = get_value(array16_33)
    global line_info;
    row_num = size(array16_33,1);
    value = 0;
    for i = 1:row_num
        value=value+line_info(array16_33(i),3);
    end
end
function setglobal()
    global line_info;
    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    [Clist,CityLoc,CityPop]=testcase;% clist是直角坐标系坐标
    line_value = zeros(12,12);
    SnrReq = [Inf 3000 1200 600];
    RateTable = [0 8 16 32];
    city_num = 12;
    pop = zeros(12,12);
    flow = zeros(12,12);
    for ii =1:city_num
        for jj=ii+1:city_num
               Dist = distance(CityLoc(ii,1),CityLoc(ii,2),CityLoc(jj,1),CityLoc(jj,2))*pi/180*6371
               %Dist= norm(CityLoc(ii,:)-CityLoc(jj,:));
               Ind = find(SnrReq>Dist);
               ModRate = RateTable(Ind(end));
               line_value(ii,jj)=sqrt(CityPop(ii)*CityPop(jj))*ModRate;
               pop(ii,jj) = sqrt(CityPop(ii)*CityPop(jj));
               flow(ii,jj) = ModRate;
        end
    end
    line_info = zeros(66,5);
    k=1;
    for i=1:city_num
        for j=i+1:city_num
            line_info(k,1:2)=[i j];
            line_info(k,3)=line_value(i,j);
            line_info(k,4)=pop(i,j);
            line_info(k,5)=flow(i,j);
            k=k+1;
        end
    end
end
function huisu1(edgenum)

    % mainly amended by Chen Zhen, 2012~2016
    global line_info;
    setglobal();
    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    [Clist,CityLoc,CityPop]=testcase;% clist是直角坐标系坐标
    [line_info_order,index]=sortrows(line_info,-3);
    stack = [];
    stack_size=0;
    line_order = 1;
    edgenum = 16;
    break_flag = 0;
    while line_order<=66
        while line_order<=66 
            stack(stack_size+1)=line_order;
            stack_size=stack_size+1;
            line_order=line_order+1;
            if stack_size == edgenum
                if test_liantong(index(stack(1:edgenum))')
                    break_flag = 1;
                    break
                else
                    if line_order~=67
                        num = stack(stack_size);
                        stack_size=stack_size-1;
                    end
                end
            end
        end
        if break_flag ==1 
            break
        end
        if line_order==67
            num = stack(stack_size);
            stack_size=stack_size-1;
            if num +1 == line_order
                num = stack(stack_size);
                stack_size=stack_size-1;
            end
            line_order = num +1;
        end
    end
    max_choice = index(stack(1:edgenum))';
    get_view(max_choice);
    get_value(max_choice)
    %[f,X]=fobj(xmax(end,1:edgenum),Clist,CityPop);
    
    X=triu(get_adjacency(max_choice))
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
    title(['容量为' num2str(f)])
    ylabel('纬度');
    xlabel('经度');
    figure;
    plot(fopt);
    ylabel('网络价值');
    xlabel('迭代次数');
    title(['连接数为' num2str(edgenum)]);
    pause(0.01);
    figure;
end