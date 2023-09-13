function [f] = curve_drawing(y)
x = [30,40,50,60,80,100,120,150,200,250]';
EXPR = {'x^(-2)','x^(-1)','x^(2)','x','1'};
p = fittype(EXPR);
f = fit(x,y,p);
plot(f,x,y);
end

