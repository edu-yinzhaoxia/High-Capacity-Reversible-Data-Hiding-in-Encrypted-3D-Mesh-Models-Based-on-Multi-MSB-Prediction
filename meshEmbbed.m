function [vertex2, message_bin] = meshEmbbed(m, vertex1, face,label_bin,len_sum ,label_map,Vertemb)
%Embed messages into vertexes of the encrypted mesh

%% Convert Vertexes into Bitstream
magnify = 10^m;
[vertex1, bit_len] = meshPrepro(m, vertex1);
vertex2 = vertex1;

 %% Separate Vertexes into 2 Sets
[num_face, ~] = size(face);
[num_vert,~] =size(vertex1);

%% Embed messages into selected vertexes

%Generate the embedded message
[~, num_vertemb] = size(Vertemb); 
[~,num_label] = size(label_bin);
label_bin = logical(label_bin);
k_emb = 54321;
message = logical(pseudoGenerate(len_sum-num_label, k_emb));
message_bin = [label_bin message'];
message_bin = message_bin';
embbed_num = 0;
for i = 1:num_vertemb  % Full embedding
            for j = 1:3            
                for k = 1:label_map(i)
                    if message_bin(embbed_num+1) == 1
                        vertex2(Vertemb(i),j) = bitset(vertex2(Vertemb(i),j),bit_len-k+1,1);
                        embbed_num = embbed_num + 1;
                    else
                        vertex2(Vertemb(i),j) = bitset(vertex2(Vertemb(i),j),bit_len-k+1,0);
                        embbed_num = embbed_num + 1;
                    end
                end
            end
end
%Reset into vertexes
vertex2 = double(vertex2) / magnify;

end
