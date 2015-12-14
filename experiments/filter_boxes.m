function y=filter_boxes(x)
l = size(x,1);
y=[];
for i=1:l
    ly=size(y,1);
    
    if x(i,5)<0.5 break;
    end
    ins = 1;
    for j=1:ly
        if iou(y(j,:),x(i,1:4))>0.5
            ins =0;
        end
    end
    if ins>0
        y=[y;x(i,1:4)];
    end
end
