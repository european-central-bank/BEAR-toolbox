
function lt = reshapeInit(initY)

    lt = initY;
    lt = flipud(lt);
    lt = transpose(lt);
    lt = reshape(lt, 1, []);

    % order = size(initY, 1);
    % lt = [];
    % for i = 1 : order
    %     lt = [initY(i, :), lt];
    % end

end%

