function A = GenRandomAdjMatrix(n,p)
    rng('default')
    rng(2)
    A = zeros(n,n);

    for i = 1:n
        for j = i+1:n
            if rand < p
                A(i,j) = randi([10,20]);
                A(j,i) = A(i,j);
            end
        end
    end
end