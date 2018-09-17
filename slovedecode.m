function [si,sid,X,si2,sid2] = slovedecode(s,cn,linenum)

citynum = cn*(cn-1)/2;
si = s(1:citynum);
sid = s(citynum+1:2*citynum);
X = s(2*citynum+1:end);
X = reshape(X,cn,cn);

kk = cumsum(sid);
[~,Ind] =find(kk>=linenum,1);
si2 = si(1:Ind);
kk(Ind) = linenum;
sid2 = diff([0 kk(1:Ind)]);