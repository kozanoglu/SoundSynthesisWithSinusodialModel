clear all; close all; fclose all;
data=wavread('piano.wav');
samp_rate=44100; ctr=0; S=621;    % pencere uzunluðu
trans=2*pi/samp_rate;
frate=floor(size(data,1)/S);
data=data*32767/max(data);  % normalize etme.

dc=mean(data);  
data=data-dc;
mak=max(data);

pencere=hanning(S)./S;        % Pencereleme ve FFT
for i=1:frate;
    penc=data(((i-1)*S)+1:i*S).*pencere;
    stf(i,1:1024)=fft([penc((S+1)/2:S)' zeros(1,1024-S) penc(1:(S-1)/2)']);
end;
stfamp=abs(stf).*2;
stfang=angle(stf);

 for i=1:frate;
    freq(i,1)=0;
    for j=3:267;
        if stfamp(i,j)>stfamp(i,j-1)&&stfamp(i,j)>stfamp(i,j+1)&&stfamp(i,j)>32
            ctr=ctr+1;
            angl(i,ctr)=stfang(i,j);
            
            amp(i,ctr)=stfamp(i,j);
           % freq(i,ctr)=;
            % Parabolik interpolasyon.
            x2=(j-1)*samp_rate/1024;
            y2=stfamp(i,j);
            x1=(j-2)*samp_rate/1024;
            y1=stfamp(i,j-1);
            x3=(j)*samp_rate/1024;
            y3=stfamp(i,j+1);
            b=((x1^2-x3^2)*(y1-y2)-(x1^2-x2^2)*(y1-y3))/((x1^2-x3^2)*(x1-x2)-(x1^2-x2^2)*(x1-x3));
            a=((y1-y2)-(x1-x2)*b)/(x1^2-x2^2);
            c=(y1-a*x1^2)-(b*x1);
            freq(i,ctr)=-b/(2*a);
          %  amp(i,ctr)=(a*freq(i,ctr)^2)+(b*freq(i,ctr))+c;
        end
    end;
    ca(i)=ctr;
    ctr=0;
end;

%Parametre dosyasý oluþturuluyor.
fid=fopen('parametre.dat','wb');
fwrite(fid,S,'int');
fwrite(fid,frate,'uint');
fwrite(fid,dc,'float');
for i=1:frate
    fwrite(fid,ca(i),'uint');
end
for i=1:frate
    for j=1:ca(i)
        fwrite(fid,amp(i,j),'float');
        fwrite(fid,freq(i,j),'float');
        fwrite(fid,angl(i,j),'float');
    end
end
fclose(fid);
fclose('all');

%plot(abs(fftshift(fft(data))))
%plot((0:length(data)-1)/44100, data)    