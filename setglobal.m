function setglobal()
    global line_info;
    global CityLoc CityPop Clist;
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
    CityPop = [1961.24 1063.60 311.03 846.78 862.65 2301.91 978.54 2884.62 1404.76...
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