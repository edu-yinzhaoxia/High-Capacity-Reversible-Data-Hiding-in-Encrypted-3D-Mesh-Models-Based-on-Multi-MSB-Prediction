 % =========================================================================
% An example code for the algorithm proposed in
%
% 
%   
%
%
% 
% =========================================================================
clear; clc; close all;
addpath(genpath(pwd));
% vextex0: Original vertex information 
% vextex1: Encrypted vertex information 
% vextex2: Vertex information embedded in secret data after encryption  
% vextex3: Vertex information after extraction and restoration 

fid = fopen('results.txt','w'); % Save output
files = dir('origin'); 
[num, ~]= size(files);
for i=1:num
if strfind(files(i).name,'.off')
% if strfind(files(i).name,'.ply') %Read a file in .ply format
    name = files(i).name;
else
    continue;
end
source_dir = ['origin/',name];
display(name)
fprintf(fid, '%s\n',name);
display('m           capacity             hd                   snr');
fprintf(fid, 'm             capacity              hd               snr\n');



 m = 5;% Vertex information storage accuracy m
%% Read a 3D mesh file
[~, file_name, suffix] = fileparts(source_dir);
if(strcmp(suffix,'.obj')==0) %off
    [vertex, face] = read_mesh(source_dir);
    vertex = vertex'; face = face';%Comment out this line if you want to read the .PLY format 
else %obj
    Obj = readObj(source_dir);
    vertex = Obj.v; face = Obj.f.v;
end
vertex0 = vertex;
%% Preprocessing
magnify = 10^m;
[vertex, bit_len] = meshPrepro(m, vertex0);

%% Prediction error detection
[label_map,vertemb] = markEmbbed(vertex, face, bit_len);
a = sum(label_map(:));
[label_bin,num_label] = labelBinary(label_map);
[meshlen, mesh_bin] = meshLength(vertex, bit_len);
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
%Encrypt
enc_bin = xor(mesh_bin, sec_bin);
% vertex1 = meshEncrypt(enc_bin',bit_len,magnify);
vertex1 = meshGenerate(enc_bin, magnify, face, bit_len);
[Room_1,Room_2,vertex2] = arrangeVertex(vertex1,m,label_map,vertemb,bit_len);
[vertex3,message] = dataEmbed(vertex2,Room_2,label_bin,label_map,bit_len,vertemb,magnify);
[vertex4] = vertRecovery(vertex3,face,Room_2,bit_len,magnify,sec_bin);
%% 哈夫曼编码压缩
% tic
%  P = zeros(1,32);
% % 获取各符号的概率；
%  for j = 0:31
%      P(j+1) = length(find(label_map == j))/length(label_map);
%  end
%  k = 0:31;
%  dict = huffmandict(k,P); %生成字典
%  enco = huffmanenco(label_map,dict); %编码
%  deco = huffmandeco(enco,dict); %解码
% %    计算编码长度，计算压缩率
%   encodedLen = length(enco);
% %   encodedLen = numel(binaryComp); 
%   imgLen = length(label_bin);
%   disp(strcat(['编码后传输的比特流长度为' num2str(encodedLen)]))
%   disp(strcat(['原二进制编码比特长度为' num2str(imgLen)]))
%   disp(strcat(['压缩率为' num2str(100*(imgLen-encodedLen)/imgLen) '%']))
%   toc
% [vex_wrong,vertemb] = meshWrong(vertex, face, bit_len, embbed_len);
%% Encryption
%Compute mesh length
% [meshlen, mesh_bin] = meshLength(vertex, bit_len);
%Generate a psudorandom stream
% k_enc = 12345;
% sec_bin = logical(pseudoGenerate(meshlen, k_enc));
%Encrypt
% enc_bin = xor(ver_bin, sec_bin);
%Generate encrypted mesh
% vertex1 = meshGenerate(enc_bin, magnify, face, bit_len);
 % save the encrypted model
% out_file = fullfile('encryption', ['encrypt_',file_name, '.off']); 
% write_off(out_file, vertex1, face);

%% Data hiding
% [len_sum] = lenSum(label_map,vertemb);
% [vertex2, message_bin] = meshEmbbed(m, vertex1, face,label_bin,len_sum,label_map,vertemb);
% save the model with embedded secret information
% out_file = fullfile('embedded',['embbed_',file_name, '.off']);
% write_off(out_file, vertex2, face);

%% Data extraction & Mesh recovery
% [ext_m, vertex3] = meshRecovery(m, vertex2, face,label_map,num_label,vertemb);
% save the restored model
out_file = fullfile('recovery',['recovery_',file_name, '.off']);
write_off(out_file, vertex4, face);
%compare1 = isequal(message_bin, ext_m);
%% Experimental result
%Compute HausdorffDist
 hd = HausdorffDist(vertex0,vertex4,1,0);
%Compute SNR
snr = meshSNR(vertex0,vertex4);
%Compute capacity
[vex_num, ~] = size(vertex);
capacity = length(message)/vex_num;
%Compute error percent

% if isempty(int32(message_bin))
%     err_percent = 0;
%     break;
% end
% 
% err_dist = int32(message_bin)-ext_m;
% err_length = length(find(err_dist(:)~=0));
% err_percent = err_length/length(ext_m);

% output results
fprintf(fid,'%d          %f         %e          %f\n', m,capacity, hd, snr);
display([num2str(m),'           ',num2str(capacity),'              ', num2str(hd),'            ',num2str(snr)]);
end
