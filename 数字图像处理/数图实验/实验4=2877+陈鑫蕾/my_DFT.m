function [F] = my_DFT(fp)
    [m,n]=size(fp);
    x=0:1:m-1;
    y=0:1:n-1;
    u=0:1:m-1;
    v=0:1:n-1;
    Wm=exp(-1i*2*pi*v'*y./n);
    Wn=exp(-1i*2*pi*u'*x./m);
    F=Wm*fp*Wn;
end

