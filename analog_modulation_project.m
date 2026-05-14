clc
close all
clear all
%-------------------------------------------------------------------------
%% the message signal and all components
fs=80000; %%sampling rate
t=0:1/(2*fs):1-1/(2*fs) ;
m=2*sin(2*pi*400*t)+4*cos(2*pi*500*t)+3*cos(2*pi*300*t);
sound(m,fs);%%======>>> sound of the message//////
figure(1);
subplot(3,1,1);
%%plotting message in time domain
plot(t,m);
title( "time domain of the message signal");
xlabel("time");
ylabel("Message");
%%plotting message in frequency domain
fftm=fft(m,2*fs);
fftSignal = (1/(2*fs))*fftm;
spectrum = fftshift(fftSignal);
f =(-fs:1:fs-1);
subplot(3,1,2);
plot(f, abs(spectrum));
title('magnitude of frequency transform of the message signal');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(m,fs);
%%-------------------------------------------------------------------------
%% signal modulation with 3 types (AM,DSB,SSB(USB  or LSB))
fc=20000; % carrier frequency====>> tune it till it is less than (fs/2)
S_AM=conventionalAM(m,fs,fc);
S_DSB=DSB_SC(m,fs,fc);
S_SSB_LSB=SSBLSB(m,fs,fc);
S_SSB_USB=SSBUSB(m,fs,fc);
s=S_SSB_USB;%========>> tune this either AM , DSB or SSB(USB  or LSB) but dont forget to change it in the demodulation

figure(2);
subplot(3,1,1);
%%plotting Modulated signal in time domain
plot(t,s);
title( "time domain of the modulated signal");
xlabel("time");
ylabel("Modulated signal");
fftS= (1/(2*fs)).*fft(s);
SpectrumS=fftshift(fftS);
subplot(3,1,2);
%%plotting Modulated signal in frquency domain
plot(f, abs(SpectrumS));
title('magnitude of frequency transform of the modulated signal');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(s,fs);

%%-------------------------------------------------------------------------

%% transfering the signal through awgan channel
figure(3);   %====> plotting for the -10db noise

SR_neg10db=awgn(s,-10); %%recived signal with noise -10 db
SR_pos20db=awgn(s,20);   %%recived signal with noise 20 db
subplot(3,1,1);
plot(t,SR_neg10db);
title( "time domain of the recived signal  with noise -10db");
xlabel("time");
ylabel("recived signal")

subplot(3,1,2);
plot(f,(1/(2*fs))*abs(fftshift(fft(SR_neg10db))));
title('magnitude of frequency transform the recived modulated signal  with noise -10db');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(SR_neg10db,fs);
figure(4)%===>> plotting for 20db noise

subplot(3,1,1);
plot(t,SR_pos20db);
title( "time domain of the recived modulated signal  with noise 20db");
xlabel("time");
ylabel("recived signal")
subplot(3,1,2)
plot(f,(1/(2*fs))*abs(fftshift(fft(SR_pos20db))));
title('magnitude of frequency transform the recived signal  with noise 20db');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(SR_pos20db,fs);

%--------------------------------------------------------------------------
%% demodulating the received signal with -10db noise

recived_AM_neg10db=demodulation_ConventionalAM(SR_neg10db,fc,fs);
recived_DSB_SC_neg10db= demodulation_DSB_SC(SR_neg10db,fc,fs);
recived_SSB_neg10db=demodulation_SSB(SR_neg10db,fc,fs);
R=recived_SSB_neg10db %======>> dont forget it must be the same type of the modulation
figure(5) ;
subplot(3,1,1);
%%plotting  in received signal with -10db noise time domain
plot(t,R);
title( "time domain of the received signal with -10db noise");
xlabel("time");
ylabel("Recived signal");
sound(R,fs);%%========>> sound of the demodulated signal with -10db/////
%%plotting message in frequency domain
Recived_spectrum=(1/(2*fs))*abs(fftshift(fft(R)));
subplot(3,1,2);
plot(f, Recived_spectrum);
title('magnitude of frequency transform of the received signal with -10db noise ');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(R,fs);


%------------------------------------------------------------------------------
%% demodulating the received signal with 20db noise
recived_AM_20db=demodulation_ConventionalAM(SR_pos20db,fc,fs);
recived_DSB_SC_20db= demodulation_DSB_SC(SR_pos20db,fc,fs);
recived_SSB_20db=demodulation_SSB(SR_pos20db,fc,fs);
R=recived_SSB_20db %=====>> the same type of modulation 
figure(6) ;
subplot(3,1,1);
%%plotting  in received signal with 20db noise time domain
plot(t,R);
title( "time domain of the received signal with 20db noise");
xlabel("time");
ylabel("Recived signal");
%%plotting message in frequency domain
Recived_spectrum=(1/(2*fs))*abs(fftshift(fft(R)));
subplot(3,1,2);
plot(f, Recived_spectrum);
title('magnitude of frequency transform of the received signal with 20db noise ');
xlabel('Frequency (Hz)');
ylabel('magnitude');
subplot(3,1,3);
pspectrum(R,fs);
sound(R,fs)%==>>>> sound of the demodulated signal















%% all the functions of modulation and demodulation

function S= conventionalAM(m,fs,fc)
t=0:1/(2*fs):1-1/(2*fs)  ;
Ac=10;
%%modulating using product modulator
S=Ac*(1+(1/Ac)*m).*cos(2*pi*fc*t)
return 

end
function S= DSB_SC(m,fs,fc)
t=0:1/(2*fs):1-1/(2*fs) ; 
Ac=10;
%%modulating using balance modulator
S= Ac*m.*cos(2*pi*fc*t)
return 

end
function S= SSBLSB(m,fs,fc)
t=0:1/(2*fs):1-1/(2*fs)  ;
Ac=10;
x=t/(pi.*t.*t)
mh=hilbert(m);
s1=Ac*mh.*cos(2*pi*fc*t);
s2=-Ac*m.*sin(2*pi*fc*t);
S=s1+s2;
return

end
function S= SSBUSB(m,fs,fc)
t=0:1/(2*fs):1-1/(2*fs)  ;
Ac=10;
mh=abs(hilbert(m));
s1=Ac*m.*cos(2*pi*fc*t);
s2=-Ac*mh.*sin(2*pi*fc*t);
S=s1-s2;
return

end
function r= demodulation_ConventionalAM(s,fc,fs)
t=0:1/(2*fs):1-1/(2*fs)  ;
Ac=10;
s1=2*s.*cos(2*pi*fc*t);
wpass=2*pi*1000;
s3=lowpass(s1,wpass,fs);
r=s3-Ac
return


end
function r= demodulation_DSB_SC(s,fc,fs)
t=0:1/(2*fs):1-1/(2*fs)
Ac=10;
s1=2*s.*cos(2*pi*fc*t);
wpass=2*pi*1000;
s3=lowpass(s1,wpass,fs);
r=s3/Ac

end
function r= demodulation_SSB(s,fc,fs)
t=0:1/(2*fs):1-1/(2*fs)
Ac=10;
s1=2*s.*cos(2*pi*fc*t);
wpass=2*pi*1000;
s3=lowpass(s1,wpass,fs);
r=s3/Ac
end
