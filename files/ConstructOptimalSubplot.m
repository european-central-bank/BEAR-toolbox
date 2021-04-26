function [Nrows,Ncols]=ConstructOptimalSubplot(NumberOfPlots)

% Given a number of plots, this function determines the 'optimal' number of
% rows and columns of the subplot.

switch NumberOfPlots
    case 1
        Nrows=1;
        Ncols=1;
    case 2
        Nrows=2;
        Ncols=1;
    case 3
        Nrows=2;
        Ncols=2;
    case 4
        Nrows=2;
        Ncols=2;
    case 5
        Nrows=3;
        Ncols=2;
    case 6
        Nrows=3;
        Ncols=2;
    case 7
        Nrows=3;
        Ncols=3;
    case 8
        Nrows=3;
        Ncols=3;
    case 9
        Nrows=3;
        Ncols=3;
    case 10
        Nrows=3;
        Ncols=4;
    case 11
        Nrows=3;
        Ncols=4;
    case 12
        Nrows=3;
        Ncols=4;
    case 13
        Nrows=4;
        Ncols=4;
    case 14
        Nrows=4;
        Ncols=4;
    case 15
        Nrows=4;
        Ncols=4;
    case 16
        Nrows=4;
        Ncols=4;
    otherwise
        Nrows=ceil(sqrt(NumberOfPlots));
        Ncols=ceil(sqrt(NumberOfPlots));
end