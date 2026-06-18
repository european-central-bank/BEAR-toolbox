
Generalized restrictions
=========================

Enter generalized restrictions in the area between the triple backtick marks
below. Enter one (possibly composite) restriction per line, combining the
following system properties:

* $SHKRESP(periods, 'endogenous', 'shock') for shock response in the
'endogenous' variable to the 'shock' in the specified period or periods

* $SHKCONT(periods, 'endogenous', 'shock') for the contribution of the 'shock'
to the 'endogenous' variable in the specified period or periods %

* $SHKEST(periods, 'shock') for the estimates of the 'shock' in the specified
period or periods

Period or periods are enterd as a single period number, a vector of numbers, or
a range, i.e. 1, [1,3,5], or 1:5.

The name of an endogenous variable or shock is entered as a string in single
quotes.

Anything outside the triple backtick marks is ignored. Empty lines are ignored.
Do not remove the triple backtick marks.


```

```

