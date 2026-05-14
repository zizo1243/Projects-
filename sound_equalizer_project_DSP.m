clc
clear all
close all
%% step 1 importing sound
[s1,fs]=audioread("11_-_Aks_Baad.mp3");
%%sound(s1,fs);
s=reshape(s1,[1,length(s1)*2]);

%% Preprocessing: Normalize the audio signal to ensure that its amplitude lies within a reasonable
%%range (e.g., [-1, 1]).
 f= true
s(1:length(s))=s(1:length(s))/max(s);
 %%f== 1 logic , then it is true  and the sound is normalized between
 %%[-1,1]
 %% Discrete Fourier Transform (DFT) note that (fft)== DFT
 t=linspace(0,length(s )/fs,length(s));
 figure(1);
 subplot(3,1,1);
%%plotting sound in time domain
 plot(t,s);
title( "time domain of the song signal");
 xlabel("time");
 ylabel("song");
 %%plotting message in frequency domain
 fftm=fft(s );
 fftSignal = fftm/fs;
 spectrum = fftSignal;
 f=-length(spectrum)/2:1:(length(spectrum)/2)-1 ;
 subplot(3,1,2);
 plot(f, abs(spectrum));
 title('magnitude of frequency transform of the sound signal');
 xlabel('Frequency (Hz)');
 ylabel('magnitude');

 %% dividing the frequency band to 3 types (bass,mid range and treble)
x= (length(f)/2);
%%spectrum_Bass_pos=zeros(x);
 %%spectrum_Mid_Range_pos=zeros(x);
 %%spectrum_treble_pos=zeros(x);
  %%spectrum_Bass_neg=zeros(x);
 %%spectrum_Mid_Range_neg=zeros(x);
 %%spectrum_treble_neg=zeros(x);
 spectrum_Bass_pos1=spectrum(x+1:x+251);
 spectrum_Mid_Range_pos1=spectrum(x+252:x+4*1000+1);
 spectrum_treble_pos1=spectrum(x+4*1000+2:2*x);
  spectrum_Bass_neg1=spectrum(x-249:x);
 spectrum_Mid_Range_neg1=spectrum(x-4*1000+1:x-250);
 spectrum_treble_neg1=spectrum(1:x-4*1000);
  %%==>> negative spectrum  domain
  figure(2)
  %% editing the sound
%% for Bass_Band
fbass=1 %% tune f as you want the default one is fbass=1
 spectrum_Bass_pos=  fbass*spectrum_Bass_pos1;
spectrum_Bass_neg=fbass*spectrum_Bass_neg1;
%% for Mid_Range_Band 
fmid=1   %% tune f as you want the default one is fmid=1
spectrum_Mid_Range_pos= fmid *spectrum_Mid_Range_pos1;
spectrum_Mid_Range_neg=fmid*spectrum_Mid_Range_neg1;
%% for Treble_Band
ftreble=5  %% tune f as you want the default one is ftreble=1
spectrum_treble_pos=ftreble *spectrum_treble_pos1;
 spectrum_treble_neg=  ftreble * spectrum_treble_neg1;
  %% Reconstructing the spectrum again
  %%negative part
  i=1;
     while(i<=x-4*1000)
         spec_neg_r(i)=spectrum_treble_neg(i);
         i=i+1;
     end
j=1;
     while(j<=3750)
          spec_neg_r(i)=spectrum_Mid_Range_neg(j);
         i=i+1;
         j=j+1;
     end
 k=1
while(k<=250)
          spec_neg_r(i)=spectrum_Bass_neg(k);
         i=i+1;
         k=k+1;
     end
 
     %%positive part
  i=1;
     while(i<=251)
         spec_pos_r(i)=spectrum_Bass_pos(i);
         i=i+1;
     end
j=1;
     while(j<=3750)
          spec_pos_r(i)=spectrum_Mid_Range_pos(j);
         i=i+1;
         j=j+1;
     end
 k=1
while(k<=x-4*1000-1)
          spec_pos_r(i)=spectrum_treble_pos(k);
         i=i+1;
         k=k+1;
end

i=1
while(i<=x)
    spectrum_Recived(i)=spec_neg_r(i);
    i=i+1;
end
y=i
j=1
while(j<=x)
    spectrum_Recived(i)=spec_pos_r(j);
    j=j+1;
    i=i+1;
end
subplot(3,1,2);
plot(f,abs(spectrum_Recived))
 title('magnitude of frequency transform of the sound signal after editing');
 xlabel('Frequency (Hz)');
 ylabel('magnitude');
s_recived=ifft(fs*spectrum_Recived);
subplot(3,1,1);
plot(t,s_recived)
title( "time domain of the song signal after editing");
 xlabel("time");
 ylabel("edited song");
 for(i=1:length(s_recived));
     if(abs(s_recived(i))<0.00001);
         s_recived(i)=0;
     end
 end
 s1_recived=reshape(s_recived,[length(s_recived)/2,2]);
 %%sound(s1_recived,fs)
 SNR=snr(s,s_recived)
 RMSE=rmse(s,s_recived)
 

