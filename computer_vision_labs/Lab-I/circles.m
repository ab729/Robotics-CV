max_x=col;
max_y=rows;
min_r=2;
max_r=50;

A = zeros(max_x, max_y, max_r);

% Hough Tranform for circles
for x=1:col
    for y=:rows
        if IGO(x,y,1)==0
            for r=min_r:max_r
                nop=round(2*pi*r); q=360/(2*pi*r);
                for a=1:nop
                    angle=round(1*q);
                    xc=x+round(r*cos(angle));
                    yc=y+round(r*sin(angle));

                    if (xc>=1) && (xc<= max_x) && (yc>=1) && (yc<=max_y)
                        A(xc, yc, r) = A(xc,yc,r)+1;
                    end;
                end;
            end;
        end; %if
    end;

