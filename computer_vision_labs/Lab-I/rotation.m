clc
clear

N=8 %the size NxN

%mask
M=zeros(N,N);
r=N/2
for w=1:N
  for k=1:N
    if sqrt((w-r-0.5)^2+(k-r-0.5)^2)<r
      M(w,k)=1;
    end;
  end;
end;
M

%an example matrix
M_in=ones(N,N);
M_in(1:round(r),:)=7;
M_in

alpha=45*pi/180; %rotation angle

%wrong rotation of the matrix
R=[cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];
M_out_b=zeros(N,N);
for w1=1:N
  for k1=1:N
    if M(w1,k1)
      wk=R*[w1-r-0.5;k1-r-0.5];
      w2=round(wk(1)+r+0.5);
      k2=round(wk(2)+r+0.5);
      M_out_b(w2,k2)=M_in(w1,k1);
    end;
  end;
end;
M_out_b %bad

%correct rotation (with "backprojection") of the matrix
R=[cos(-alpha) -sin(-alpha); sin(-alpha) cos(-alpha)];
M_out_g=zeros(N,N);
for w1=1:N
  for k1=1:N
    if M(w1,k1)
      wk=R*[w1-r-0.5;k1-r-0.5];
      w2=round(wk(1)+r+0.5);
      k2=round(wk(2)+r+0.5);
      M_out_g(w1,k1)=M_in(w2,k2);
    end;
  end;
end;
M_out_g %good
