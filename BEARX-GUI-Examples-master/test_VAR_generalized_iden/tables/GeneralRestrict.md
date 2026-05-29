
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


Restrictions used in this project
---------------------------------

ACTIVE (cheap, run in seconds with MaxCandidates=100)

  Sign restrictions on impact + 1 period
    - Demand shock: pushes GDP, inflation and short rate up
    - Supply shock: pushes GDP up, inflation down
    - Monetary policy tightening: short rate up, GDP and inflation down

  Relative magnitude
    - MP moves the policy rate on impact by more than a demand shock does


DISABLED (work in principle, but HUGE compute cost - see notes below)

  Narrative sign restriction on the shock series
    - e.g. index 76 = 2008-Q4 (Fed cuts after Lehman): MP shock must be
      negative (expansionary) in that quarter
        $SHKEST(76, 'MP') < 0

  Narrative historical contribution
    - e.g. indices 80:84 = 2009-Q4 to 2010-Q4: MP eased and contributed
      POSITIVELY to GDP (without the MP easing, GDP growth would have been
      lower)
        $SHKCONT(80:84, 'GDP_GROWTH', 'MP') > 0

  Composite restriction over horizons
    - e.g. cumulated effect of MP on inflation over the first 3 quarters
      is negative
        $SHKRESP(1, 'INFLATION', 'MP') + $SHKRESP(2, 'INFLATION', 'MP')
            + $SHKRESP(3, 'INFLATION', 'MP') < 0

Why disabled: every $SHKEST and $SHKCONT macro forces BEAR to refilter the
full shock series and recompute the historical decomposition for EACH
candidate rotation. With 1000 reduced-form samples and an acceptance rate
of ~0.1-1% the run-time blows up from seconds to many minutes (potentially
hours). The composite line above is cheap on its own, but together with the
two narrative lines the acceptance rate collapses.

To re-enable, paste the lines back into the code block below and raise
MaxCandidates to 5000-10000 on the GeneralRestrict page.


```
$SHKRESP(1:2, 'GDP_GROWTH', 'DEM') > 0
$SHKRESP(1:2, 'INFLATION', 'DEM') > 0
$SHKRESP(1:2, 'SHORT_RATE', 'DEM') > 0

$SHKRESP(1:2, 'GDP_GROWTH', 'SUP') > 0
$SHKRESP(1:2, 'INFLATION', 'SUP') < 0

$SHKRESP(1, 'SHORT_RATE', 'MP') > 0
$SHKRESP(1:4, 'GDP_GROWTH', 'MP') < 0
$SHKRESP(1:4, 'INFLATION', 'MP') < 0

$SHKRESP(1, 'SHORT_RATE', 'MP') > $SHKRESP(1, 'SHORT_RATE', 'DEM')

```

