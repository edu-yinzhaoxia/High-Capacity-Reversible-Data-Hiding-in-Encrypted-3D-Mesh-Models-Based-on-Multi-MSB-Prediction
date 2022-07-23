function [label_map] = labelInt(map_bin)
[col,~] = size(map_bin);
col = col/6;
label_map=zeros(col,6);
m={};
for i=1:col
label_map(i,:)=map_bin(1+6*(i-1):6*i);
end
for j=1:col
b=num2str(label_map(j,:));
b(findstr(' ',b))=[];
m{j}=b;
end
label_map = bin2dec(m);










