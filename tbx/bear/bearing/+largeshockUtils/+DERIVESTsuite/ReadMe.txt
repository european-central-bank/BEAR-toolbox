Numerical differentiation 

Author: John D'Errico
e-mail: woodchips@rochester.rr.com
Release: 1.0
Release date: 3/7/2007

This is a suite of tools to solve automatic numerical differentiation
problems in one or more variables. All of these methods also produce
error estimates on the result.

A pdf file is also provided to explain the theory behind these tools.


DERIVEST.m

A flexible tool for the computation of derivatives of order 1 through
4 on any scalar function. Finite differences are used in an adaptive
manner, coupled with a Romberg extrapolation methodology to provide a
maximally accurate result. The user can configure many of the options,
changing the order of the method or the extrapolation, even allowing
the user to specify whether central, forward or backward differences
are used.

GRADEST.m

Computes the gradient vector of a scalar function of one or more
variables at any location.

JACOBIANEST.m

Computes the Jacobian matrix of a vector (or array) valued function of
one or more variables.

DIRECTIONALDIFF.m

Computes the directional derivative (along some line) of a scalar
function of one or more variables.

HESSIAN.m

Computes the Hessian matrix of all 2nd partial derivatives of a scalar
function of one or more variables.

HESSDIAG.m

The diagonal elements of the Hessian matrix are the pure second order
partial derivatives. This function is called by HESSIAN.m, but since
some users may need only the diagonal elements, I've provided
HESSDIAG.
