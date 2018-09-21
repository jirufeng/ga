global line_info dot_array;
setglobal2();
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
value = get_value(arr1);
show_graph(arr1,value);






function result=prim1(a)
% ���룺a���ڽӾ���a��i��j)��ָi��j֮���Ȩֵ
% �����result����һ���������зֱ������С�������ߵ���㡢�յ㡢Ȩ����
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
function setglobal2()
    global line_info;
    global CityLoc CityPop Clist dot_array CityPop2;
    CityLoc=[39.91667 116.41667;%����
        45.75000 126.63333;%������
        43.45 87.36;%��³ľ��
        34.26667,108.95000;%����
        34.76667,113.65000;%֣��
        31.14 121.29;%�Ϻ�
        30.35 114.17;%�人
        29.35 106.33;%����
        30.40 104.04;%�ɶ�
        29.39 91.08;%����
        25.04 102.42;%����
        23.16667,113.23333];%�㶫
    CityPop = [1961.24 1063.60 311.03 846.78 862.65 2301.91 978.54 2884.62 1404.76...
        55.94 643.20 1035.79]/100;
    CityPop2 = [12397 10910 2398 7691 23161 21235 17299 3392 8262 331 13164 15790]/100;
    axesm utm   %����ͶӰ��ʽ������MATLAT�Դ���Universal Transverse Mercator ��UTM����ʽ
    Z=utmzone(CityLoc);%utmzone����latlon20���������ѡ������Ϊ���ʵ�ͶӰ���򣬿�����һ��̨վ�ľ�γ�ȣ�Ҳ����������̨վ�ľ�γ�ȣ���ʱ��ƽ����
    setm(gca,'zone',Z)
    h = getm(gca);
    R=zeros(size(CityLoc));
    for i=1:length(CityLoc)
        [x,y]= mfwdtran(h,CityLoc(i,1),CityLoc(i,2));
        Clist(i,:)=[x;y]/1e3;
    end
    k=1;
    for i =1:12
        for j = i+1:12
            dot_array(i,j)=k;
            dot_array(j,i)=k;
            k=k+1;
        end
    end
    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    line_value = zeros(12,12);
    SnrReq = [Inf 3000 1200 600];
    RateTable = [0 8 16 32];
    city_num = 12;
    pop = zeros(12,12);
    flow = zeros(12,12);
    for ii =1:city_num
        for jj=ii+1:city_num
               Dist = distance(CityLoc(ii,1),CityLoc(ii,2),CityLoc(jj,1),CityLoc(jj,2))*pi/180*6371;
               %Dist= norm(CityLoc(ii,:)-CityLoc(jj,:));
               Ind = find(SnrReq>Dist);
               ModRate = RateTable(Ind(end));
               line_value(ii,jj)=sqrt(CityPop2(ii)*CityPop2(jj))*ModRate;
               pop(ii,jj) = sqrt(CityPop2(ii)*CityPop2(jj));
               flow(ii,jj) = ModRate;
        end
    end
    line_info = zeros(66,11);%������� ����ֵ ƽ���˿� ������� ʵ������ �Ƿ�ʵ����ͨ �Ƿ�������ͨ ��������
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