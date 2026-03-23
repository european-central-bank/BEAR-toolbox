close all

%figure();
f1 = tiledlayout(3,3);
for i = 1 : 9
    nexttile();
    plot(rand(10));
end
exportgraphics(f1, "aaa2.pdf", contentType="vector");

f2 = tiledlayout(3,3);
for i = 1 : 9
    nexttile();
    bar(rand(1, 10));
end
exportgraphics(f2, "aaa2.pdf", contentType="vector", append=true);
