function Q = qzerores(P, R)

    % function [Q] = qzerores(n, R, P)
    % computes an orthogonal matrix Q which satisfies the zero restrictions
    % inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
    %          - cell 'R': cell containing the Z matrices for the zero restrictions
    % outputs: - matrix 'Q': orthogonal matrix satisfying the zero restrictions
    % initiate Q

    n = size(P, 1);
    Q = [];

    % loop over j values, j = 1, 2, ..., n
    for jj = 1 : n
        % create Rj
        % first create the product Zj*f
        % if there are no zero restriction on shock jj...
        if isempty(R{1, jj})
            Zjf = [];
        else
            Zjf = R{1, jj} * P;
        end
        Rj = [Zjf; transpose(Q)];

        % now the procedure will differ according to whether Rj is empty or not
        % obviously, one cannot find the nullspace of an empty matrix!
        % if Rj is empty, no orthogonalisation is required
        x = randn(n, 1); %normrnd(0, 1, n, 1);
        if isempty(Rj)
            % simply draw a random vector form the standard normal
            % normalise it
            Qj = x / norm(x);
        else
            % find a basis of the nullsapce of Rj
            Nj = null(Rj);
            % draw a random vector form the standard normal
            % and obtain the Q column satisfying the zero restriction
            Nj_x = Nj' * x;
            Qj = Nj * (Nj_x / norm(Nj_x));
            % increment Q
        end

        Q = [Q, Qj];
    end

end%

