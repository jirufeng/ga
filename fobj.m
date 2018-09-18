function [f,X]=fobj(XId,CityLoc,CityNum)
    city_num = size(CityLoc,1);

    X = 1-tril(ones(city_num,city_num),0);
    X = X(:);
    Ind = find(X==1);
    X(Ind)=1:length(Ind);
    for ii=1:length(XId)
        X(X==(XId(ii)))=Inf;
    end
    X=(X==Inf);
    X = reshape(X,city_num,city_num);

    f = 0;
    SnrReq = [Inf 3000 1200 600];
    RateTable = [0 8 16 32];
    for ii =1:city_num
        for jj=ii+1:city_num
            if (X(ii,jj)>=1)
               %Dist= norm(CityLoc(ii,:)-CityLoc(jj,:));
               Dist = distance(CityLoc(ii,1),CityLoc(ii,2),CityLoc(jj,1),CityLoc(jj,2))*pi/180*6371;
               Ind = find(SnrReq>Dist);
               ModRate = RateTable(Ind(end));
               f = f+ sqrt(CityNum(ii)*CityNum(jj))*ModRate;
            end        
        end
    end
end