function [vertex1] = meshEncrypt(enc_bin,bit_len,magnify)
%MESHENCRYPT 此处显示有关此函数的摘要
%   此处显示详细说明
ver2_int = [];
for i = 1:length(enc_bin)/bit_len
    ver2_temp_bin = enc_bin((i-1)*bit_len+1: i*bit_len);
     if(ver2_temp_bin(1)==1)
        if(bit_len<64)
            ver2_temp = 0;
            for j = 0:bit_len-2
                ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
            end
            inv_dec = dec2bin(ver2_temp-1, bit_len);
            true_dec = logical([]);
            for j = 1:bit_len
                true_dec = [true_dec; xor(str2num(inv_dec(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-2
                ver2_temp = ver2_temp + true_dec(bit_len-j)*2^j;
            end
            ver2_temp = -ver2_temp;
        else
            ver2_temp1 = 0; %former
            ver2_temp2 = 0; %latter
            for j = 0:31
                ver2_temp1 = ver2_temp1 + ver2_temp_bin(bit_len-j)*2^j;
            end
            for j = 0:31
                ver2_temp2 = ver2_temp2 + ver2_temp_bin(32-j)*2^j;
            end
            inv_dec1 = dec2bin(ver2_temp2, 32); %former
            inv_dec2 = dec2bin(ver2_temp1-1, 64); %latter
            true_dec = logical([]);
            for j = 1:32
                true_dec = [true_dec; xor(str2num(inv_dec1(j)), 1)];
            end
            for j = 33:64
                true_dec = [true_dec; xor(str2num(inv_dec2(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-1
                ver2_temp = ver2_temp + true_dec(bit_len-j)*2^j;
            end
            ver2_temp = -ver2_temp;
        end
    else
        ver2_temp = 0;
        for j = 0:bit_len-1
            ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
        end
     end
     ver2_int = [ver2_int; ver2_temp];
end
for i = 1:length(enc_bin)/bit_len/3
    vertex1(i, 1) = ver2_int(3*(i-1)+1);
    vertex1(i, 2) = ver2_int(3*(i-1)+2);
    vertex1(i, 3) = ver2_int(3*(i-1)+3);
end

vertex1 = double(vertex1)/magnify;
% vertex1 = vertex1/magnify;
end


