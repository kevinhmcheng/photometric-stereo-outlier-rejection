function correct_f = irf(x)
len = size(x,1);
f = zeros(1,len);
if (size(x,2) == 1) %grayscale
    pass = [];
    for i = 1:len
        verify = x(i);
        if (length(find(verify==0))+length(find(verify==1))>0)
            f(i) = 0/0; %NaN
        else
            pass = [pass i];
        end
    end
    
    A = x(pass);
    B = 1./A;
    f = A.*mean(B)+B.*mean(A);
else %RGB
    pass = [];
    for i = 1:len
        verify = [x(i,1) x(i,2) x(i,3)];
        if (length(find(verify==0))+length(find(verify==1))>0)
            f(i) = 0/0; %NaN
        else
            pass = [pass i];
        end
    end
    
    Ar = x(pass,1); Ag = x(pass,2); Ab = x(pass,3);
    Br = 1./Ar; Bg = 1./Ag; Bb = 1./Ab;
    fr = Ar.*mean(Br)+Br.*mean(Ar);
    fg = Ag.*mean(Bg)+Bg.*mean(Ag);
    fb = Ab.*mean(Bb)+Bb.*mean(Ab);
    f = fr+fg+fb;
end

f = f/size(pass,2)/6;
correct_f = nan(1,len);
correct_f(pass) = f;

end