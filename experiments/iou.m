function s=iou(x,y)
if sq_intsct(x,y)
intsct = (min(y(3),x(3))-max(y(1),x(1)))*(min(y(4),x(4))-max(y(2),x(2)));
s1=(x(3)-x(1))*(x(4)-x(2));
s2=(y(3)-y(1))*(y(4)-y(2));
%s=intsct/(s1+s2-intsct);
s=intsct/min(s1,s2);
else
    s=0;
end
end

