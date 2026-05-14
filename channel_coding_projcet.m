%% with puncturing 
clc
clear all 
close all
pr=0:0.01:0.2
q=1
p=0;%counter to fill in CodedBitErrorProb with coded bit error probabilities correspond to each p
%for(p=0:0.01:0.2)
state=0;
errors=0
errors_Inc=0
check=true
count_inc_8_9=0
count_inc_4_5=0
count_inc_2_3=0
count_inc_4_7=0
count_inc_1_2=0
%% reading the 3 given videos
obj1=VideoReader('P0.001_incremental_code.avi');
obj2=VideoReader('coastguard.avi');
obj3=VideoReader('foreman.avi');
a=read(obj2);
%%======>>> put obj1 , obj2 or obj3
%% finding the number of frames of the videos
frames=get(obj1,'NumberOfFrames');
%% To extract the frames of the video
i=1;
while(i<=frames);
    I(i).cdata=a(:,:,:,i);
    i=i+1;
end;
%%  generating a new video with the same size as the original video
 s=size(I(1).cdata);
mov(1:frames) =struct('cdata', zeros(s(1),s(2), 3, 'uint8'),'colormap', []);
% CodedBitErrorProb_Inc=zeros(1, 30*ceil((0.2-0.0001)/0.01) );
% CodedBitErrorProb=zeros(1, 30*ceil((0.2-0.0001)/0.01) );
% throughput=zeros(1, 30*ceil((0.2-0.0001)/0.01) );

for(Frame=1:30);
%Red Components of the Frame
R=I(Frame).cdata(:,:,1);
%Green Components of the Frame
G=I(Frame).cdata(:,:,2);
%Blue Components of the Frame
B=I(Frame).cdata(:,:,3); 
%% converting the singed data from integers to binary
Rdouble = double(R);
Gdouble = double(G);
Bdouble = double(B);
Rbin1 = de2bi(Rdouble);
Gbin1 = de2bi(Gdouble);
Bbin1 = de2bi(Bdouble);
Rbin=reshape(Rbin1,[1,25344*8]);
Gbin=reshape(Gbin1,[1,25344*8]);
Bbin=reshape(Bbin1,[1,25344*8]);

%% packeting red green and blue colour frame  in one array with only one array
packetarr=zeros(1,3*length(Bbin));
packetarr(1:length(Rbin) )= Rbin;
packetarr(length(Gbin)+1: 2*length(Gbin))= Gbin;
packetarr(2*length(Bbin)+1: 3*length(Bbin))= Bbin;
%% lets encode the packetarr in the encoder
packetarr2=reshape(packetarr,[1024,(length(packetarr)/1024)]);
j=1;
i=1;
k1=1;
k2=1;
k3=1;
k4=1;
k=1;
transpacketarr=zeros(1,length(packetarr)*2);
transpacketarr2=reshape(transpacketarr,[1024*2,(length(packetarr)/1024)]);
transpacketarr2_8_9=zeros(2048-(2048/16)*7,(length(packetarr)/1024));
transpacketarr2_4_5=zeros(2048-(2048/16)*6,(length(packetarr)/1024));
transpacketarr2_2_3=zeros(2048-(2048/16)*4,(length(packetarr)/1024));
transpacketarr2_4_7=zeros(2048-(2048/16)*2,(length(packetarr)/1024));
punc_8_9=[1,1,1,0,1,0,1,0,0,1,1,0,1,0,1,0];
punc_4_5=[1,1,1,0,1,0,1,0,1,1,1,0,1,0,1,0];
punc_2_3=[1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0];
punc_4_7=[1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0];
while(i<=(length(packetarr)));
    packet=packetarr2(i:1024*j);
    trellis = poly2trellis(7,[171 133]); 
    encoded_8_9 = convenc(packet,trellis,punc_8_9);
    encoded_4_5 = convenc(packet,trellis,punc_4_5);
    encoded_2_3 = convenc(packet,trellis,punc_2_3);
    encoded_4_7 = convenc(packet,trellis,punc_4_7);
    encoded = convenc(packet,trellis);
    errored_8_9 = bsc(encoded_8_9,p);
    errored_4_5 = bsc(encoded_4_5,p);
    errored_2_3 = bsc(encoded_2_3,p);
    errored_4_7 = bsc(encoded_4_7,p);
    errored = bsc(encoded,p);
    transpacketarr2_8_9(k1:(2048-(2048/16)*7)*j)=errored_8_9;
    transpacketarr2_4_5(k2:(2048-(2048/16)*6)*j)=errored_4_5;
    transpacketarr2_2_3(k3:(2048-(2048/16)*4)*j)=errored_2_3;
    transpacketarr2_4_7(k4:(2048-(2048/16)*2)*j)=errored_4_7;
    transpacketarr2(k:2048*j)=errored;
    i=i+1024;
    j=j+1;
    k1=k1+2048-(2048/16)*7;
    k2=k2+2048-(2048/16)*6;
    k3=k3+2048-(2048/16)*4;
    k4=k4+2048-(2048/16)*2;
    k=k+2048;


end
transpacketarr_8_9=reshape(transpacketarr2_8_9,[1,(2048-(2048/16)*7)*(length(packetarr)/1024)]);
transpacketarr_4_5=reshape(transpacketarr2_4_5,[1,(2048-(2048/16)*6)*(length(packetarr)/1024)]);
transpacketarr_2_3=reshape(transpacketarr2_2_3,[1,(2048-(2048/16)*4)*(length(packetarr)/1024)]);
transpacketarr_4_7=reshape(transpacketarr2_4_7,[1,(2048-(2048/16)*2)*(length(packetarr)/1024)]);
transpacketarr=reshape(transpacketarr2,[1,(2048)*(length(packetarr)/1024)]);
%% decoding

% count_inc_8_9=0
% count_inc_4_5=0
% count_inc_2_3=0
% count_inc_4_7=0
% count_inc_1_2=0
j=1;
i=1;
k1=1;
k2=1;
k3=1;
k4=1;
k=1;
while(k<=(length(transpacketarr)));
   packetdec_8_9=transpacketarr2_8_9(k1:(2048-(2048/16)*7)*j);
   decoded1_8_9=vitdec(packetdec_8_9,trellis,35,'trunc','hard',punc_8_9);
   decoded_8_9(i:1024*j)=decoded1_8_9;
   packetdec_4_5=transpacketarr2_4_5(k2:(2048-(2048/16)*6)*j);
   decoded1_4_5=vitdec(packetdec_4_5,trellis,35,'trunc','hard',punc_4_5);
   decoded_4_5(i:1024*j)=decoded1_4_5;
   packetdec_2_3=transpacketarr2_2_3(k3:(2048-(2048/16)*4)*j);
   decoded1_2_3=vitdec(packetdec_2_3,trellis,35,'trunc','hard',punc_2_3);
   decoded_2_3(i:1024*j)=decoded1_2_3;
   packetdec_4_7=transpacketarr2_4_7(k4:(2048-(2048/16)*2)*j);
   decoded1_4_7=vitdec(packetdec_4_7,trellis,35,'trunc','hard',punc_4_7);
   decoded_4_7(i:1024*j)=decoded1_4_7;
   packetdec=transpacketarr2(k:2*1024*j);
   decoded1=vitdec(packetdec,trellis,35,'trunc','hard');
   decoded(i:1024*j)=decoded1;
   %%using incremental method of decoding 


  if(state==0)
      if((packetarr(i:1024*j)==decoded1_8_9))
        decodedinc(i:1024*j)=decoded1_8_9;
        count_inc_8_9=count_inc_8_9+1;
      else
        state=state+1;
      end
  end
  if(state==1)
      if((packetarr(i:1024*j)==decoded1_4_5))
        decodedinc(i:1024*j)=decoded1_4_5;
        count_inc_4_5=count_inc_4_5+1;
      else
        state=state+1;
      end
  end
  if(state==2)
      if((packetarr2(i:1024*j)==decoded1_2_3))
        decodedinc(i:1024*j)=decoded1_2_3;
        count_inc_2_3=count_inc_2_3+1;
      else
        state=state+1;
      end
  end
  if(state==3)
      if((packetarr2(i:1024*j)==decoded1_4_7))
        decodedinc(i:1024*j)=decoded1_4_7;
        count_inc_4_7=count_inc_4_7+1
      else
        state=state+1;
      end
  end
  if(state>3)
      decodedinc(i:1024*j)=decoded1;
      count_inc_1_2=count_inc_1_2+1;
  end
    i=i+1024;
    j=j+1;
    k1=k1+2048-(2048/16)*7;
    k2=k2+2048-(2048/16)*6;
    k3=k3+2048-(2048/16)*4;
    k4=k4+2048-(2048/16)*2;
    k=k+2048;
end
%% no channel coding code
decoded_no=bsc(packetarr,p);
% 
%to get the bit error probabilities corresponding to each p: see the
%different bits between (what's before encoding) and (what's after decoding)
%divided by the length of the array(total bits)
%if we subtract the arrays the successful transmitted bits wil give a zero result
%else it is in error
errors= length(find((packetarr-decoded)~=0))+errors;
errors_Inc=length(find((packetarr-decodedinc)~=0))+errors_Inc;

%% reconstructing the video
Redbin_R=decoded_8_9(1:length(Rbin));
Greenbin_R=decoded_8_9(length(Rbin)+1:2*length(Rbin));
Bluebin_R=decoded_8_9(2*length(Rbin)+1:3*length(Rbin));
Redbin1_R=reshape(Redbin_R,[length(Redbin_R)/8,8]);
Greenbin1_R=reshape(Greenbin_R,[length(Redbin_R)/8,8]);
Bluebin1_R=reshape(Bluebin_R,[length(Redbin_R)/8,8]);
Redouble_R=bi2de(Redbin1_R);
Greendouble_R=bi2de(Greenbin1_R);
Bluedouble_R=bi2de(Bluebin1_R);
Red_R=reshape(Redouble_R,[144,176]);
Green_R=reshape(Greendouble_R,[144,176]);
Blue_R=reshape(Bluedouble_R,[144,176]);
%%  generating a new video with the same size as the original video
mov(1,Frame).cdata(:,:,1) = Red_R;
mov(1,Frame).cdata(:,:,2) = Green_R;
mov(1,Frame).cdata(:,:,3) = Blue_R;
b(:,:,:,Frame)= mov(Frame).cdata;
end
 CodedBitErrorProb(q)= errors/(30*length(packetarr));
  CodedBitErrorProb_Inc(q)= errors_Inc/(30*length(packetarr));
  throughput(q)=((count_inc_1_2)*0.5+(count_inc_8_9)*8/9+(count_inc_4_5)*4/5+(count_inc_2_3)*2/3+(count_inc_4_7)*4/7)/(30*594)

%% saving and playing the video 
% if(p==0.01 | p==0.1)
% implay(b);
% end
q=q+1;

%end
% WriterObj=VideoWriter("P0.001_incremental_code.avi");
% open(WriterObj);
% writeVideo(WriterObj,mov);
% close(WriterObj);


figure(1)
title("code bit error probalbility for each frame");
 plot(pr,CodedBitErrorProb);
% hold on
 figure(2)
 title("code bit error probalbility for each frame");
 plot(pr,CodedBitErrorProb_Inc);
% hold on
 figure(3);
title("throughput of each frame");
 plot(pr,throughput);