function [bin2] = BinaryConversion_10_2(value,m)
% ����˵������ʮ���ƻҶ�����ֵת����8λ����������
% ���룺value��ʮ���ƻҶ�����ֵ��
% �����bin2��mλ���������飩

bin2 = dec2bin(value)-'0';
if length(bin2) < m
    len = length(bin2);
    B = bin2;
    bin2 = zeros(1,m);
    for i=1:len
        bin2(m-len+i) = B(i); %����8λǰ�油��0
    end 
end