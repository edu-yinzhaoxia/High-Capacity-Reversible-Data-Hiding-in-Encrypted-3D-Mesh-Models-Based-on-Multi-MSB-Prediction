function [label_map,vertemb] = markEmbbed(vertex0, face, bit_len)
%MARKEMBBED 函数记录每个嵌入集顶点可嵌入数据的长度
%% Separate Vertexes into 2 Sets
[num_face, ~] = size(face);
[num_vert,~] =size(vertex0);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);
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
vertemb = Vertemb;
%% Calculate and record prediction error
[~,count]= size(Vertemb);
label_map = [];
for v = 1:count
    refer_vex = [];
    refer_vex = new_info(Vertemb(v)).ref;

    refer_vex = unique(refer_vex);
    refer_vex = setdiff(refer_vex(:),Vertemb(:))';
    [~,refer_num] = size(refer_vex);
    
    bin1 = int32(dec2binPN( vertex0(Vertemb(v),1), bit_len)');
    bin2 = int32(dec2binPN( vertex0(Vertemb(v),2), bit_len)');
    bin3 = int32(dec2binPN( vertex0(Vertemb(v),3), bit_len)');
    
    refer_bin1 = int32(zeros(1, bit_len));
    refer_bin2 = int32(zeros(1, bit_len));
    refer_bin3 = int32(zeros(1, bit_len));
    for j = 1:refer_num
        refer_bin1 = refer_bin1 + int32(dec2binPN( vertex0(refer_vex(j),1), bit_len)');
        refer_bin2 = refer_bin2 + int32(dec2binPN( vertex0(refer_vex(j),2), bit_len)');
        refer_bin3 = refer_bin3 + int32(dec2binPN( vertex0(refer_vex(j),3), bit_len)');
    end
    refer_bin1 = int32(refer_bin1/refer_num);
    refer_bin2 = int32(refer_bin2/refer_num);
    refer_bin3 = int32(refer_bin3/refer_num);
    t1=0;   
    t2=0;
    t3=0;
    for k1 = 1:bit_len
        if bin1(k1) == refer_bin1(k1)
            t1 = k1;
        else
            break;
        end
    end
    for k2 = 1:bit_len
        if bin2(k2) == refer_bin2(k2)
            t2 = k2;
        else
            break;
        end
    end
    for k3 = 1:bit_len
        if bin3(k3) == refer_bin3(k3)
            t3 = k3;
        else
            break;
        end
    end
    t0 = [t1 t2 t3];
    t = min(t0);
    label_map = [label_map t];
end
