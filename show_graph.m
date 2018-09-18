function show_graph(array16_33,value)
global Clist CityLoc CityPop;
 X=triu(get_adjacency(array16_33));
    figure;clf;hold on;
    plot(CityLoc(:,2),CityLoc(:,1),'rs');
    CiteNum = 12;
    for ii=1:CiteNum
        for jj=1:CiteNum
            if (X(ii,jj)==1)
                plot([CityLoc(ii,2) CityLoc(jj,2)],...
                    [CityLoc(ii,1) CityLoc(jj,1)],'b-');
            end
        end
    end
    title(['总价值为' num2str(value)]);
    ylabel('纬度');
    xlabel('经度');
    figure;
end