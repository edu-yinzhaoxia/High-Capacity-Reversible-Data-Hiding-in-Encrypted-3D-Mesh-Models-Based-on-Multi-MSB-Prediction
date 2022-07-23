function [vertex3] = vertRecovery(vertex2,face,Room_2,bit_len,magnify,sec_bin)
%DATARECOVERYU 此处显示有关此函数的摘要
%   此处显示详细说明
%vertex3 = vertex2*magnify;
[num_face, ~] = size(face);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);
[num_vert,~] =size(vertex2);
 s_info = repmat(struct('id',[],'num',[],'ref',[],'status',[]),num_vert,1);
for i = 1:num_vert
    s_info(i).id =i ;
    for j = 1:num_face
        v1 = isempty(find(face(j, 1)==i))==0;
        v2 = isempty(find(face(j, 2)==i))==0;
        v3 = isempty(find(face(j, 3)==i))==0;
        if(v1==1)
            Vertnoemb = [Vertnoemb face(j, 2) face(j, 3)];
        elseif(v2==1)
            Vertnoemb = [Vertnoemb face(j, 1) face(j, 3)];
        elseif(v3==1)
            Vertnoemb = [Vertnoemb face(j, 1) face(j, 2)];
        end
     end
    Vertnoemb = unique(Vertnoemb);
    [~,num] = size(Vertnoemb);
    s_info(i).ref = Vertnoemb;
    s_info(i).num = num;
    s_info(i).status= 0;
    Vertnoemb = [];
end
[~,ind]=sort([s_info.id],'ascend');
new_info=s_info(ind);
for k = 1:num_vert
    if (mod((new_info(k).id),2)~=0)
        Vertemb = [Vertemb new_info(k).id];
        mid = find(mod(new_info(k).ref,2)==0);
        new_info(k).ref = new_info(k).ref(mid);
    end
end
[~, num_vertemb] = size(Vertemb); 
ver_bin = [];
for m = 1:num_vertemb
    ver_1 = int32(dec2binPN( vertex2(Vertemb(m),1), bit_len)');
    ver_2 = int32(dec2binPN( vertex2(Vertemb(m),2), bit_len)');
    ver_3 = int32(dec2binPN( vertex2(Vertemb(m),3), bit_len)');
    ver_bin = [ver_bin ver_1 ver_2 ver_3];
    ver_bin = double(ver_bin);
end
a = ceil(log2(9*num_vert));
label_len_bin = ver_bin(1:a);
label_len = BinaryConversion_2_10_int(label_len_bin);
compress_label_map_bin = ver_bin(a+1:a+label_len);
b = length(compress_label_map_bin);
loc_Com = zeros(length(compress_label_map_bin)/8,1);
 for n = 1:length(compress_label_map_bin)/8
     loc_Com(n,1) = BinaryConversion_2_10_int(compress_label_map_bin((n-1)*8+1:n*8));
 end
 cPos_x = arith07(loc_Com);
 pox = (cPos_x{1,1})';
 map = zeros(1,length(pox)/6);
 for p = 1:length(pox)/6
     map(1,p) = BinaryConversion_2_10_int(pox((p-1)*6+1:p*6));
 end
 c = 3*sum(map)-a-b;
len_Room_1 = length(ver_bin)- length(Room_2);
Room_1 = ver_bin(1:len_Room_1);
 g=0;
v_emb = cell(3,num_vertemb);
mid_vert = [];
for v = 1:num_vertemb
%         refer_vex = [];
%         refer_vex = new_info(Vertemb(v)).ref;
%         refer_vex = unique(refer_vex);
%         refer_vex = setdiff(refer_vex(:),Vertemb(:))';
%         [~,refer_num] = size(refer_vex);
%         
%         refer_bin1 = int32(zeros(1, bit_len));
%         refer_bin2 = int32(zeros(1, bit_len));
%         refer_bin3 = int32(zeros(1, bit_len));
%         for i = 1:refer_num
%             refer_bin1 = refer_bin1 + int32(dec2binPN( vertex2(refer_vex(i),1), bit_len)');
%             refer_bin2 = refer_bin2 + int32(dec2binPN( vertex2(refer_vex(i),2), bit_len)');
%             refer_bin3 = refer_bin3 + int32(dec2binPN( vertex2(refer_vex(i),3), bit_len)');
%         end
%         refer_bin1 = int32(refer_bin1/refer_num);
%         refer1 = refer_bin1(1:map(v));
%         refer_bin2 = int32(refer_bin2/refer_num);
%         refer2 = refer_bin2(1:map(v));
%         refer_bin3 = int32(refer_bin3/refer_num);
%         refer3 = refer_bin3(1:map(v));
        % 恢复嵌入集顶点不能嵌入信息的比特位
        mid_vert = Room_2(g+1:g+3*(bit_len-map(v)));
        v_emb{1,v} =[Room_1(1:map(v)) mid_vert(1:(bit_len-map(v)))];
        v_1 = BinaryConversion_2_10(v_emb{1,v},bit_len);
        v_emb{2,v} =[Room_1(map(v)+1:2*map(v)) mid_vert((bit_len-map(v))+1:2*(bit_len-map(v)))];
        v_2 = BinaryConversion_2_10(v_emb{2,v},bit_len);
        v_emb{3,v} =[Room_1(2*map(v)+1:3*map(v)) mid_vert(2*(bit_len-map(v))+1:3*(bit_len-map(v)))];
        v_3 = BinaryConversion_2_10(v_emb{3,v},bit_len);
        g = g + 3*(32-map(v));
        vertex2(Vertemb(v),1) = v_1;
        vertex2(Vertemb(v),2) = v_2;
        vertex2(Vertemb(v),3) = v_3;
        
        
end
      [meshlen, nodec_bin] = meshLength(vertex2, bit_len);
      dec_bin = double(xor(nodec_bin, sec_bin))';
      ver2_int = [];
      for u = 1:length(dec_bin)/bit_len
          ver2_temp_bin = dec_bin((u-1)*bit_len+1: u*bit_len);
          ver2_temp = BinaryConversion_2_10(ver2_temp_bin,bit_len);
          ver2_int = [ver2_int; ver2_temp];
      end
       v_em = cell(3,num_vertemb);
      for o = 1:length(dec_bin)/bit_len/3
          vertex2(o, 1) = ver2_int(3*(o-1)+1);
          vertex2(o, 2) = ver2_int(3*(o-1)+2);
          vertex2(o, 3) = ver2_int(3*(o-1)+3);
      end 
%       Room_3 = dec_bin(a+b+c+1:a+b+c+length(Room_2));
     q =0;
for v = 1:num_vertemb
        refer_vex = [];
        refer_vex = new_info(Vertemb(v)).ref;
        refer_vex = unique(refer_vex);
        refer_vex = setdiff(refer_vex(:),Vertemb(:))';
        [~,refer_num] = size(refer_vex);
        refer_bin1 = int32(zeros(1, bit_len));
        refer_bin2 = int32(zeros(1, bit_len));
        refer_bin3 = int32(zeros(1, bit_len));
        for i = 1:refer_num
            refer_bin1 = refer_bin1 + int32(dec2binPN( vertex2(refer_vex(i),1), bit_len)');
            refer_bin2 = refer_bin2 + int32(dec2binPN( vertex2(refer_vex(i),2), bit_len)');
            refer_bin3 = refer_bin3 + int32(dec2binPN( vertex2(refer_vex(i),3), bit_len)');
        end
%         mid = Room_3(q+1:q+3*(bit_len-map(v)));
        refer_bin1 = int32(refer_bin1/refer_num);
        refer_1 = refer_bin1(1:map(v));
        refer_bin2 = int32(refer_bin2/refer_num);
        refer_2 = refer_bin2(1:map(v));
        refer_bin3 = int32(refer_bin3/refer_num);
        refer_3 = refer_bin3(1:map(v));
        v_em{1,v} = int32(dec2binPN(vertex2(Vertemb(v),1),bit_len)');
        v_em{1,v}(1:map(v)) = refer_1;
%         v_em{1,v} = [refer_1 mid(1:(bit_len-map(v)))] ;
        v1 = BinaryConversion_2_10(v_em{1,v},bit_len);
        v_em{2,v} = int32(dec2binPN(vertex2(Vertemb(v),2),bit_len)');
        v_em{2,v}(1:map(v)) = refer_2;
%         v_em{2,v} = [refer_2 mid((bit_len-map(v))+1:2*(bit_len-map(v)))] ;
        v2 = BinaryConversion_2_10(v_em{2,v},bit_len);
        v_em{3,v} = int32(dec2binPN(vertex2(Vertemb(v),3),bit_len)');
        v_em{3,v}(1:map(v)) = refer_3;
%         v_em{3,v} = [refer_2 mid(2*(bit_len-map(v))+1:3*(bit_len-map(v)))];
        v3 = BinaryConversion_2_10(v_em{3,v},bit_len);
         q = q + 3*(32-map(v));
        vertex2(Vertemb(v),1) = v1;
        vertex2(Vertemb(v),2) = v2;
        vertex2(Vertemb(v),3) = v3;
        
end
        vertex3 = double(vertex2)/magnify; 
end

