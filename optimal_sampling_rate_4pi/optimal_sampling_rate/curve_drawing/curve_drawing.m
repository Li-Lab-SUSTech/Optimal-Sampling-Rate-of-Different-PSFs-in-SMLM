function [f] = curve_drawing(y)
x = [40,48,56,64,72,80,96,104,120,136,176,200,240]';
EXPR = {'x^(-2)','x^(-1)','x^(2)','x','1'};
p = fittype(EXPR);
f = fit(x,y,p);
plot(f,x,y);
end

