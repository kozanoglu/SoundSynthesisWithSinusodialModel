samp_rate=44100;
trans=2*pi/samp_rate;
fid=fopen('parametre.dat','rb');
S=fread(fid,1,'uint');
frate2=fread(fid,1,'uint');
dc=fread(fid,1,'float');
for i=1:frate2
    ctr(i)=fread(fid,1,'uint');
end
for i=1:frate2
        for j=1:ctr(i)
                amp(i,j)=fread(fid,1,'float');
                freq(i,j)=fread(fid,1,'float');
                angl(i,j)=fread(fid,1,'float');
    end
end
fclose(fid);

sentetik(frate2*S)=0;
freqsize=size(freq,2);
freq(frate2,freqsize)=0;
amp(frate2,freqsize)=0;
angl(frate2,freqsize)=0;

for i=1:frate2-1;
        
    if ctr(i)>0                   % Çerçeveler arasý uydurma.
        for j=1:freqsize;
            if j<freqsize
                uplev=(freq(i,j)+freq(i,j+1))/2;
            else uplev=freq(i,j)*1.5;
            end;
            if j>1
                dnlev=(freq(i,j)+freq(i,j-1))/2;
            else dnlev=freq(i,j)/2;
            end;
                        uyumf(j)=freq(i,j);
                        uyumg(j)=0;
                        uyuma(j)=angl(i,j);
                        index=0;
            for k=1:freqsize
                if freq(i+1,k)<uplev&&freq(i+1,k)>=dnlev
                    index=index+1;
                    olasifr(index)=freq(i+1,k);
                    olasiamp(index)=amp(i+1,k);
                    olasiang(index)=angl(i+1,k);
                end
            end
            if index==1
                uyumf(j)=olasifr(1);
                uyumg(j)=olasiamp(1);
                uyuma(j)=olasiang(1);
            else if index>1
                    sonuc=bul(olasifr,freq(i,j));   % bul(A[],f) A vektörü içinde f'e en yakýn olanla geri döner.
                    uyumf(j)=olasifr(sonuc);
                    uyumg(j)=olasiamp(sonuc);
                    uyuma(j)=olasiang(sonuc);
                end;
            end;
        end;
        
     % Genliklerde lineer, anlýk fazda kübik interpolasyon.
     for r=1:freqsize
         if(freq(i,r)>0 && freq(i,r)<44100)
             M=round((angl(i,r)+trans*freq(i,r)*S-uyuma(r)+(S/2)*(trans*uyumf(r)-trans*freq(i,r)))/(2*pi));
             nu1=(3/S^2)*(uyuma(r)-angl(i,r)-trans*freq(i,r)*S+2*pi*M)-(trans*uyumf(r)-trans*freq(i,r))/S;
             nu2=-(2/S^3)*(uyuma(r)-angl(i,r)-trans*freq(i,r)*S+2*pi*M)-(trans*uyumf(r)-trans*freq(i,r))/S^2;
             for m=1:S
                teta=angl(i,r)+trans*freq(i,r)*(m-1)+nu1*(m-1)^2+nu2*(m-1)^3;
                ampli=amp(i,r)+(uyumg(r)-amp(i,r))*(m-1)/S;
                sentetik(m+(i-1)*S)=sentetik(m+(i-1)*S)+ampli*cos(teta);
             end;
         end
     end;
    end
end;

    maks=min(sentetik);
    sentetik=sentetik/maks;
%sentetik=sentetik*(32767-dc)/maks;
%sentetik=sentetik*13/15;

plot((0:length(sentetik)-1)/44100, sentetik)
%plot(abs(fftshift(fft(sentetik))))
sound(sentetik, samp_rate);
wavwrite(sentetik,samp_rate,16,'file2'); % Wav dosyasý oluþurma.
fclose('all');