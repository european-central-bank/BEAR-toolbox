
function merged = mergeDataCells(firstDataCell, varargin)

    merged = firstDataCell;
    for i = 1 : numel(varargin)
        for j = 1 : numel(firstDataCell)
            merged{j} = [merged{j}; varargin{i}{j}];
        end
    end

end%

