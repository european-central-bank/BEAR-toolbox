function out=invpd(in)
temp=eye(cols(in));
out=in\temp;