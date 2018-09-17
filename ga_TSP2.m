function ga_TSP2(linenum)

% mainly amended by Chen Zhen, 2012~2016

    CiteNum = 12;
    BitNum=(CiteNum-1)*CiteNum/2; %you chan choose 10, 30, 50, 75
    [Clist,CityLoc,CityPop]=testcase;
    CityDis = zeros(CiteNum,CiteNum);
    for ii=1:CiteNum
        for jj=1:CiteNum
            CityDis(ii,jj) = norm(CityLoc(ii,:)-CityLoc(jj,:));
        end
    end
    max_line = 4;

    inn=100; %初始种群大小
    gnmax=100;  %最大代数
    pc=0.8; %交叉概率
    pm=0.8; %变异概率


    %产生初始种群
    DecNum = BitNum+BitNum+CiteNum*CiteNum;
    s=zeros(inn,DecNum);
    for i=1:inn
        si=randperm(BitNum);
        sid=randi([1 max_line],1,BitNum);
        X = rand(CiteNum,CiteNum);
        X = X/sum(X(:));
        s(i,:) = slovecode(si,sid,X);
    end
    [~,p]=objf(s,Clist,CityDis,CityPop,linenum);

    gn=1;
    ymean=zeros(gn,1);
    ymax=zeros(gn,1);
    xmax=zeros(inn,DecNum);
    scnew=zeros(inn,DecNum);
    smnew=zeros(inn,DecNum);
    while gn<gnmax+1
        for j=1:2:inn
            seln=sel(p);  %选择操作
            scro=cro(s,seln,pc,CiteNum,linenum);  %交叉操作
            scnew(j,:)=scro(1,:);
            scnew(j+1,:)=scro(2,:);
            smnew(j,:)=mut(scnew(j,:),pm,CiteNum,linenum);  %变异操作
            smnew(j+1,:)=mut(scnew(j+1,:),pm,CiteNum,linenum);
        end
        s=smnew;  %产生了新的种群
        [f,p]=objf(s,Clist,CityDis,CityPop,linenum);
        %记录当前代最好和平均的适应度
        [fmax,nmax]=max(f);
        ymean(gn)=1000/mean(f);
        ymax(gn)=1000/fmax;
        %记录当前代的最佳个体
        x=s(nmax,:);
        xmax(gn,:)=x;
        gn=gn+1;
        [~,~,XFp,si2,sid2] = slovedecode(x,12,linenum);
        XId = [si2;sid2]';
        fopt(gn)=fobj2(XId,XFp,CityDis,Clist,CityPop);

        gn
    end

    [~,~,XFp,si2,sid2] = slovedecode(xmax(end,:),12,linenum);
    XId = [si2;sid2]';
    [f,X]=fobj2(XId,XFp,CityDis,Clist,CityPop);
    figure;clf;hold on;
    plot(CityLoc(:,2),CityLoc(:,1),'rs');
    for ii=1:CiteNum
        for jj=1:CiteNum
            if (X(ii,jj)>=1)
                plot([CityLoc(ii,2) CityLoc(jj,2)],...
                    [CityLoc(ii,1) CityLoc(jj,1)],'b-','linewidth',double(X(ii,jj)));
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
    title(['连接数为' num2str(linenum)]);
    pause(0.01);
    figure;
end

%------------------------------------------------
%计算所有种群的适应度
function [f,p]=objf(s,Clist,CityDis,CityPop,linenum)

    citynum = size(Clist,1);
    inn=size(s,1);  %读取种群大小
    f=zeros(inn,1);
    for i=1:inn
        [~,~,XFp,si2,sid2] = slovedecode(s(i,:),citynum,linenum);
        XId = [si2;sid2]';
        f(i)=fobj2(XId,XFp,CityDis,Clist,CityPop);  %计算函数值，即适应度
    end
    f=f'; %取距离倒数
    %根据个体的适应度计算其被选择的概率
    fsum=0;
    for i=1:inn
        fsum=fsum+f(i)^15;% 让适应度越好的个体被选择概率越高
    end
    ps=zeros(inn,1);
    for i=1:inn
        ps(i)=f(i)^15/fsum;
    end

    %计算累积概率
    p=zeros(inn,1);
    p(1)=ps(1);
    for i=2:inn
        p(i)=p(i-1)+ps(i);
    end
    p=p';
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
    %从种群中选择两个个体，最好不要两次选择同一个个体
    for i=1:2
        r=rand;  %产生一个随机数
        prand=p-r;
        j=1;
        while prand(j)<0
            j=j+1;
        end
        seln(i)=j; %选中个体的序号
        if i==2&&j==seln(i-1)    %%若相同就再选一次
            r=rand;  %产生一个随机数
            prand=p-r;
            j=1;
            while prand(j)<0
                j=j+1;
            end
        end
    end
end

%------------------------------------------------
%“交叉”操作
function scro=cro(s,seln,pc,citenum,linenum)
pcc=pro(pc);  %根据交叉概率决定是否进行交叉操作，1则是，0则否

s1 = s(seln(1),:);
s2 = s(seln(2),:);
scro(1,:) = s1;
scro(2,:) = s2;
if pcc==1
    [si1,sid1,X1,~,~] = slovedecode(s1,citenum,linenum);
    [si2,sid2,X2,~,~] = slovedecode(s2,citenum,linenum);
    sbn = length(si1);
    
    c1=round(rand*(sbn-2))+1;  %在[1,bn-1]范围内随机产生一个交叉位
    c2=round(rand*(sbn-2))+1;
    chb1=min(c1,c2);
    chb2=max(c1,c2);
    
    %三部分分别进行交叉
    middle=si1(chb1+1:chb2);
    si1(chb1+1:chb2)=si2(chb1+1:chb2);
    si2(chb1+1:chb2)=middle;
    middle=sid1(chb1+1:chb2);
    sid1(chb1+1:chb2)=sid2(chb1+1:chb2);
    sid2(chb1+1:chb2)=middle;
    
    cc1=round(rand*(citenum-2))+1;  %在[1,bn-1]范围内随机产生一个交叉位
    cc2=round(rand*(citenum-2))+1;
    cchb1=min(cc1,cc2);
    cchb2=max(cc1,cc2);
    middle=X1(cchb1+1:cchb2,:);
    X1(cchb1+1:cchb2,:)=X2(cchb1+1:cchb2,:);
    X1(cchb1+1:cchb2,:)=middle;
    
    for i=1:chb1 %似乎有问题
        while find(si1(chb1+1:chb2)==si1(i))
            zhi=find(si1(chb1+1:chb2)==si1(i));
            si1(i)=si2(chb1+zhi);
            sid1(i)=sid2(chb1+zhi);
        end
        while find(si2(chb1+1:chb2)==si2(i))
            zhi=find(si2(chb1+1:chb2)==si2(i));
            si2(i)=si1(chb1+zhi);
            sid2(i)=sid1(chb1+zhi);
        end
    end
    for i=chb2+1:sbn
        while find(si1(1:chb2)==si1(i))
            zhi=logical(si1(1:chb2)==si1(i));
            si1(i)=si2(zhi);
            sid1(i)=sid2(zhi);
        end
        while find(si2(1:chb2)==si2(i))
            zhi=find(si2(1:chb2)==si2(i));
            si2(i)=si1(zhi);
            sid2(i)=sid1(zhi);
        end
    end
    XMask = 1-tril(ones(12,12),1);
    X1 = X1.*XMask;X1= X1+X1';
    X2 = X2.*XMask;X2= X2+X2';
    
    scro(1,:) = slovecode(si1,sid1,X1);
    scro(2,:) = slovecode(si2,sid2,X2);
    
end
end

%--------------------------------------------------
%“变异”操作
function snnew=mut(snew,pm,citenum,linenum)

    snnew=snew;

    pmm=pro(pm);  %根据变异概率决定是否进行变异操作，1则是，0则否
    if pmm==1
        [si1,sid1,X1,~,~] = slovedecode(snew,citenum,linenum);
        bn=size(si1,2);
        
        c1=round(rand*(bn-2))+1;  %在[1,bn-1]范围内随机产生一个变异位
        c2=round(rand*(bn-2))+1;
        chb1=min(c1,c2);
        chb2=max(c1,c2);
        x=si1(chb1+1:chb2);
        si1(chb1+1:chb2)=fliplr(x);
        x=sid1(chb1+1:chb2);
        sid1(chb1+1:chb2)=fliplr(x);
        
        c1=round(rand*(citenum-2))+1;  %在[1,bn-1]范围内随机产生一个变异位
        c2=round(rand*(citenum-2))+1;
        chb1=min(c1,c2); chb2=max(c1,c2);
        x=X1(chb1+1:chb2,:);
        X1(chb1+1:chb2,:)=fliplr(x')';
        
        bit = randperm(bn,round(rand*bn));
        randbit = randi([-1 1],1,length(bit));
        sid1(bit)=sid1(bit)+randbit;
        sid1 = min(max(sid1,1),4);
        
        bit = randperm(citenum,round(rand*citenum));
        randval = randn(1,length(bit),citenum)*0.1;
        X1(bit,:)=randval;X1 = max(X1,1);
        XMask = 1-tril(ones(citenum,citenum),1);
        X1 = X1.*XMask;X1= X1+X1';
        X1 = X1/sum(X1(:));
        
        snnew = slovecode(si1,sid1,X1);
        
    end
end


function [Clist,CityLoc,CityNum]=testcase
    CityLoc=[39.91667 116.41667,;
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