function ssim = SSIM_index(x, y)

ux = mean(x);
uy = mean(y);
sigmax = std(x);
sigmay = std(y);
sigmaxy = cov(x,y);

L = 2^10;
c1 = (0.01*L)^2;
c2 = (0.02*L)^2;
c3= c2/2;

lxy =(2*ux*uy +c1)/ (ux^2 +uy^2 + c1);
cxy = (2*sigmax*sigmay + c2) / (sigmax^2 + sigmay^2 + c2);
sxy = (sigmaxy(1,2) + c3) / (sigmax*sigmay + c3);

ssim = lxy * cxy * sxy;

end