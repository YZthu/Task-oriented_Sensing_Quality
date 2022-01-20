function [r1, r2, r3]= Recall_metrics(acc, ssq)

[~, rank_loc] = sort(ssq, 'descend');
[~, loc] = max(acc);

r1 = 0;
if find(rank_loc(1) == loc)
    r1 =1;
end

r2 = 0;
if find(rank_loc(1:2) == loc)
    r2 =1;
end

r3 = 0;
if find(rank_loc(1:3) == loc)
    r3 =1;
end

end