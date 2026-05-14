close all
clear all
clc
%% Modulation projectى  بسم الله الرحمن الرحيم     
%% Source of information
SNR=[ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
%$SNR=[-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 ];
x=1;
Num_Info_bits=1000000;
m=randi([0 1],1,Num_Info_bits);

pe_OOK_parc=zeros(1,length(SNR))
pe_PSK_parc=zeros(1,length(SNR))
pe_OOK_therotical=zeros(1,length(SNR))
pe_PSK_therotical=zeros(1,length(SNR))
while(x<=length(SNR));
    y=SNR(x)
    % m=ones(1,Num_Info_bits);
    S_OOK=m;
    i=1;
    S_PSK=zeros(1,Num_Info_bits);
    while(i<=length(m));
        if(m(i)==1);
            S_PSK(i)=1;
        end;
        if(m(i)==0);
            S_PSK(i)=-1;
        end;
        i=i+1;
    end;
    %% Adding the signal to noisy channel
    ratio=10.^(SNR(x)/10);
    var=1/(2*ratio);
    A=randn(1,Num_Info_bits)+1j*randn(1,Num_Info_bits);
    sigma=sqrt(var);
    SR_OOK= S_OOK+A*sigma;
    %SR_OOK=awgn(S_OOK,y);
    SR_PSK=S_PSK+A*sigma;
    %SR_PSK=awgn(S_PSK,y);

    j=1;
    while(j<=length(SR_PSK));
        if(real(SR_OOK(j))>0.5);
            m_OOK_recived(j)=1;

        end;
        if(real(SR_OOK(j))<=0.5);
            m_OOK_recived(j)=0;
        end;
        if(real(SR_PSK(j))>0);
            m_PSK_recived(j)=1;
        end;
        if(real(SR_PSK(j))<=0);
            m_PSK_recived(j)=0;
        end;
        j=j+1;
    end;

    k=1;
    count_PSK=0;
    count_OOK=0;
    while(k<=Num_Info_bits);
        if(m_OOK_recived(k)~=m(k));
            count_OOK=count_OOK+1;
        end;
        if(m_PSK_recived(k)~=m(k));
            count_PSK=count_PSK+1;
        end;
        k=k+1;

    end;
    pe_OOK_parc(x)=count_OOK/Num_Info_bits;
    pe_PSK_parc(x)=count_PSK/Num_Info_bits;
    x=x+1;

end
z=1
while(z<=length(SNR))
    a=(10.^(SNR(z)/10));
    pe_OOK_therotical(z)=qfunc(sqrt(a./2))
    pe_PSK_therotical(z)=qfunc(sqrt(2*a))
    z=z+1.

end
figure(1)
semilogy(SNR,pe_OOK_parc,'DisplayName','probability of error of OOK Modulation practical ')
title( "OOK modulation techniques");
xlabel("SNR db");
ylabel("Bit error rate");
hold on
semilogy(SNR,pe_OOK_therotical,'DisplayName','probability of error of OOK Modulation theoritical')
legend

figure(2)
semilogy(SNR,pe_PSK_parc,'DisplayName','probability of error of PSK Modulation Practical')
title( "PSK modulation techniques");
xlabel("SNR db");
ylabel("probability of error");
hold on
semilogy(SNR,pe_PSK_therotical,'DisplayName','probability of error of PSK Modulation theoritical')
legend
figure(3)
semilogy(SNR,pe_PSK_parc,'DisplayName','probability of error of PSK Modulation Practical')
title( "all modulation thoeritical and parctical probability of error");
xlabel("SNR db");
ylabel("probability of error");
hold on
semilogy(SNR,pe_PSK_therotical,'DisplayName','probability of error of PSK Modulation theoritical')
hold on
semilogy(SNR,pe_OOK_parc,'DisplayName','probability of error of OOK Modulation practical ')
hold on
semilogy(SNR,pe_OOK_therotical,'DisplayName','probability of error of OOK Modulation theoritical')
legend