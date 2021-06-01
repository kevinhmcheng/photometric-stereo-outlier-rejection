function f = nearest_arith(x)
len = size(x,1);
f = zeros(1,len);
if (size(x,2) == 1) %grayscale
    for i = 1:len
        sum = 0;
        for j = 1:len
            sum = sum + abs(x(i)-x(j));
        end
        f(i) = sum;
    end
else %RGB
    for i = 1:len
        sum = 0;
        for j = 1:len
            sum = sum + abs(x(i,1)-x(j,1)) + abs(x(i,2)-x(j,2)) + abs(x(i,3)-x(j,3));
        end
        f(i) = sum;
    end
end

end