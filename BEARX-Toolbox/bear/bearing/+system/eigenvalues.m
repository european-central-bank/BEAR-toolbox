
function eigenvalues = eigenvalues(A, options)

    arguments
        A (:, :) double
        options.Sort (1, 1) logical = true
    end

    AA = system.companion(A);
    eigenvalues = eig(AA);

    if options.Sort
        [~, index] = sort(abs(eigenvalues), "descend");
        eigenvalues = eigenvalues(index);
    end

end%

