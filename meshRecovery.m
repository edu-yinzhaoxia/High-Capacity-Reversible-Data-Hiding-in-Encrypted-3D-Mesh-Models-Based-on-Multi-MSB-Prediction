function [ext_m, vertex3,] = meshRecovery(m, vertex2, face,label_map,num_label,Vertemb)
%% Extract embbed information and recover the mesh 

%% Convert vertexes into bitstream
magnify = 10^m;
[vertex2, bit_len] = meshPrepro(m, vertex2);
vertex3 = vertex2;
%% Separate vertexes into 2 sets
[num_face, ~] = size(face);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);
[num_vert,~] =size(vertex3);
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
%% Extract embbed information
[~, num_vertemb] = size(Vertemb); 
ext_fm = [];
ext_m = [];
ext_num = 0;
for v = 1:num_vertemb
    ext = [];
        for i = 1:3
            bin = int32(dec2binPN( vertex3(Vertemb(v),i), bit_len)');
            for j = 1:label_map(v)
                ext = [bin(j), ext];
                ext_num = ext_num + 1;
            end
        end
    ext = flipud(ext');
    ext_m = [ext_m, ext'];
end 
ext_fm = ext_m';
map_bin = ext_fm(1:num_label);
label_map = labelInt(map_bin);
ext_m = ext_fm(num_label+1:end);
%% Convert vertexes into bitstream to decrypt mesh
[~, enc_bin] = meshLength(vertex3, bit_len);
%Compute mesh length
[meshlen, ~] = meshLength(vertex3, bit_len);
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
ver2_bin = xor(enc_bin, sec_bin);
ver2_int = [];
for i = 1:length(ver2_bin)/bit_len
    ver2_temp_bin = ver2_bin((i-1)*bit_len+1: i*bit_len);
    if(ver2_temp_bin(1)==1)
        if(bit_len<64)
            ver2_temp = 0;
            for j = 0:bit_len-1
                ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
            end
            inv_dec = dec2bin(ver2_temp - 1, bit_len);
            true_dec = logical([]);
            for j = 1:bit_len
                true_dec = [true_dec; xor(str2num(inv_dec(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-1
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

for i = 1:length(ver2_bin)/bit_len/3
    vertex3(i, 1) = ver2_int(3*(i-1)+1);
    vertex3(i, 2) = ver2_int(3*(i-1)+2);
    vertex3(i, 3) = ver2_int(3*(i-1)+3);
end

%% recover the mesh 
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
            refer_bin1 = refer_bin1 + int32(dec2binPN( vertex3(refer_vex(i),1), bit_len)');
            refer_bin2 = refer_bin2 + int32(dec2binPN( vertex3(refer_vex(i),2), bit_len)');
            refer_bin3 = refer_bin3 + int32(dec2binPN( vertex3(refer_vex(i),3), bit_len)');
        end
        refer_bin1 = int32(refer_bin1/refer_num);
        refer_bin2 = int32(refer_bin2/refer_num);
        refer_bin3 = int32(refer_bin3/refer_num);
        
        for i = 1:label_map(v)
            r = label_map(v);
            vertex3(Vertemb(v),1) = bitset(vertex3(Vertemb(v),1), bit_len-i+1, refer_bin1(i));
            h1 = vertex3(Vertemb(v),1);
            vertex3(Vertemb(v),2) = bitset(vertex3(Vertemb(v),2), bit_len-i+1, refer_bin2(i));
            h2 = vertex3(Vertemb(v),2);
            vertex3(Vertemb(v),3) = bitset(vertex3(Vertemb(v),3), bit_len-i+1, refer_bin3(i));
            h3 = vertex3(Vertemb(v),3);
   
        end
        
  
end 
%Reset into vertexes
vertex3 = double(vertex3) / magnify;

end