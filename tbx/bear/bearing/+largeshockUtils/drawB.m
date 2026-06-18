function pars = drawB(pars, prior, numEn, sizeB, numBRows, estimLength, Y, LX)

      priorMeanB  = prior.meanB(:);
      priorPrecB  = prior.precB;

      % Note than the matrix invA is vectorized without the diagonal (all 1-s), and by rows (not by
      % columns, which is the standard way).
      invA  = largeshockUtils.unvech(pars.F, 0, 1);
      H = largeshockUtils.get_H(pars);

      Im          = eye(numBRows);
      invAkronIm  = sparse(kron(invA, Im));

      lXpX    = cell(numEn, 1);
      lXpY    = cell(numEn, 1);
      invAY   = Y * invA';

      tmpX = zeros(numBRows, numBRows);
      tmpY = zeros(numBRows, 1);

      for i = 1 : numEn
        tmpX(:) = 0;
        tmpY(:) = 0;
        for t = 1 : estimLength
          Xtn     = LX(t, :) / sqrt(H(i, t));
          tmpX    = tmpX + Xtn' * Xtn;
          tmpY    = tmpY + Xtn' / sqrt(H(i, t)) * invAY(t, i);
        end
        lXpX{i} = tmpX;
        lXpY{i} = tmpY;
      end

      XSX = invAkronIm' * sparse(blkdiag(lXpX{:})) * invAkronIm;

      XSY = invAkronIm' * vertcat(lXpY{:});

      % To correct small numerical errors resulting in non-symmetric XSX
      XSX = (XSX + XSX') / 2;

      postPrecB     = XSX + priorPrecB;
      postCovB      = inv(postPrecB);
      cholPostCovB  = chol(postCovB, "lower");

      postMeanB = postPrecB  \ (XSY + priorPrecB*priorMeanB);

      draw = postMeanB + cholPostCovB*randn(sizeB, 1);

      pars.B = reshape(draw, numBRows, []);

    end