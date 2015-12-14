function s=sq_intsct(x,y)
  xx=[x(3:4) y(3:4)];
  yy=[y(1:2) x(1:2)];
  s=sum(xx(:)<yy(:));
s=s==0;
end