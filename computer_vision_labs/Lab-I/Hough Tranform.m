for x=1:cols %coumns
    for y=1:row %rows
        if IGO(row-y+1, x, 1) == 0
            for alpha=min_alpha:max_alpha
                a=pi*alpha/180.0;
                rho=round(x.*cos(a)+y.*sin(a));
                if ((rho>0) && (rho<=max_rho))
                    A(max_rho-rho+1, alpha-min_alpha+1) =A(max_rho-rho+1.alpha-min_alpha+1)
                end;
            end;
        end; %if
    end;
end;

