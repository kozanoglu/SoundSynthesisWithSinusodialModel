function ret=bul(olasifr,freq)
n=size(olasifr,1);
if n==1
    n=size(olasifr,2);
end

clear temp;
temp=olasifr;
temp(:)=abs(olasifr(:)-freq);

closest=min(temp);

for i=1:n
    if closest==temp(i)
        ret=i;
    end
end
