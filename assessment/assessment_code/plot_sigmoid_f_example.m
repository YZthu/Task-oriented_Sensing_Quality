fi = figure
set(gcf,'position',[300 100 600 240] );
set(gca,'Fontsize',12);
set(gca, 'LineWidth',1.5)

up_band = 7;
low_band =3;

x=0:0.01:10;
y1= 1/(up_band-low_band)*(x-3);

tmp_idx= find(y1<0);
low_i = max(tmp_idx);
y1(tmp_idx) = 0;
tmp_idx= find(y1>1);
up_i = min(tmp_idx);
y1(tmp_idx) = 1;

y2 = sigmoid_normalization(x', [low_band;up_band]);

h1=plot(x,y1,'linewidth',2);
hold on
h2=plot(x,y2,'linewidth',2);

xticks([3,7])
xticklabels(["Low Bound", "Upper Bound"])

xlabel('Assessment Factor Value')
ylabel('Quantified Impact')
%%
hold on
plot([low_band,low_band],[0,0.1],'--','linewidth',2,'color',[0.3010 0.7450 0.9330])
hold on
plot([up_band,up_band],[0,0.9],'--','linewidth',2,'color',[0.3010 0.7450 0.9330])

hold on
plot(x(1:low_i),0.1*ones(1,low_i),'--','linewidth',2,'color',[0.3010 0.7450 0.9330])
hold on
plot(x(1:up_i),0.9*ones(1,up_i),'--','linewidth',2,'color',[0.3010 0.7450 0.9330])

yticks([0, 0.1 0.9 1])

legend([h1,h2],'f', 'S')

figue_name =['./figures/sigmoid_f_example.jpg'];
saveas(fi, figue_name);
figue_name =['./figures/sigmoid_f_example.fig'];
saveas(fi, figue_name);
figue_name =['./figures/sigmoid_f_example.eps'];
saveas(fi, figue_name, 'epsc');