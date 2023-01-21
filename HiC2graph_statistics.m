%%
clc;
currentpath=pwd;
temp_hic_path=[currentpath,'/template_HiC/'];
poincare_input_path=[currentpath,'/Data/'];
statistic_output_path=[pwd,'/graph_statistics/'];

filename='BRD3187N_chr2_iced_40kb.mat';%normal colon
% filename='BRD3187_chr2_iced_40kb.mat';%CRC
load([temp_hic_path,filename],'tri_hic');% load HiC data
chr_len=max([tri_hic(:,1);tri_hic(:,2)]);
el=tri_hic;
[hic0]=el2mat(el,chr_len);% triple HiC to matrix format
%%
hic1=hic0;
% hic1=each_seq_dist_ave(hic0);% sequentially normalization
[i,j,k]=find(triu(hic1,1));
el=[i,j,k];
w=el(:,3);
prc=75; 
sill=prctile(w,prc);
w=w/sill;
w(w>1)=1;
tmp=el;
tmp(:,3)=w;
id=unique(tmp(:,1:2));
self_edge=[id,id,ones(size(id))];
self_indi=tmp(:,2)-tmp(:,1);
tmp(self_indi==0,:)=[];
tmp=[tmp;self_edge];
tmp=sortrows(tmp);
tb=array2table(tmp,'VariableNames',{'id1','id2','weight'});
writetable(tb,[poincare_input_path,replace(filename,'.mat','_el.csv')]);% Input probability matrix for Poincare embedding
%%
prc_l=[95];
iter_num_max=1;
hic=hic0;
for iter_num=1:iter_num_max
    hic(isnan(hic))=0;
    [hic,pval]=corr(hic,'rows','complete');
end
hic=triu(hic,1);
pval=triu(pval,1);
hic_v=hic(hic>0);
prc_ind=1;
tic;
tmp=hic_v;
prc=prc_l(prc_ind);
sill=prctile(tmp,prc);
hic1=zeros(size(hic));
hic1(hic>sill&pval<.05)=hic(hic>sill&pval<.05);
hic=sparse(hic1);
[s,t]=find(hic);
el=[s,t];
writematrix(el,[statistic_output_path,replace(filename,'.mat','_el.txt')]);% Input adjacency matrix for betweenness centrality

id=unique(el(:,1:2));
id_od=1:length(id);
[lia,locb]=ismember(s,id);
s=id_od(locb(lia));
[lia,locb]=ismember(t,id);
t=id_od(locb(lia));
G=graph(s,t,'omitselfloops');
hub_ranks=centrality(G,'closeness');
tmp=[id,hub_ranks];
writematrix(tmp,strcat(statistic_output_path,replace(filename,'.mat',''),'_CC.txt'));% save closeness centrality
dist_mat=distances(G);
dist_mat(isinf(dist_mat))=nan;
tmp=mean(dist_mat,'all','omitnan');
writematrix(tmp,strcat(statistic_output_path,replace(filename,'.mat',''),'_ASPL.txt')); %save average shortest path    
toc;

   
%%
function [y]=el2mat(x,l)
y=zeros(l,l);
if size(x,2)==2
    wt=ones(size(x(:,end)));
elseif size(x,2)==3
    wt=x(:,end);
end
y(sub2ind(size(y),x(:,1),x(:,2)))=wt;
y=y+y'-diag(diag(y));
end
function y=each_seq_dist_ave(tmp_mat)
mat_len=size(tmp_mat,2);
diag_ave=nan(1,mat_len);
y=triu(tmp_mat,1);
for d=2:mat_len
    tmp=diag(tmp_mat,d-1);
    tmp=tmp(tmp>0);
    diag_ave(d)=mean(tmp,'omitnan');
    if ~isnan(diag_ave(d))
        mat_diag_tmp=tmp_mat(1+mat_len*(d-1):(mat_len+1):end);
        mat_diag_tmp=mat_diag_tmp/diag_ave(d);
        y(1+mat_len*(d-1):(mat_len+1):end)=mat_diag_tmp;
    end
end
y=y+y';
end