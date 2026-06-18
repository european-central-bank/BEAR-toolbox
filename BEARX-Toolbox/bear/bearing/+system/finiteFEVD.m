
function fevd = finiteFEVD(vma)

    % Both the input and output arrays are numT x numY x numP x numUnits
    fevd = cumsum(vma.^2, 1);

end%

