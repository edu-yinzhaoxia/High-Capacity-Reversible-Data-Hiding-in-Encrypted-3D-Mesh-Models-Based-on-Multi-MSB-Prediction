function [len_sum] = lenSum(label_map,vertemb)
%LENSUM ����ģ�Ϳ�Ƕ�볤��
[~,num] = size(vertemb);
len_sum = 0;
for i = 1:num
    len_sum =len_sum + 3*label_map(i);
end

