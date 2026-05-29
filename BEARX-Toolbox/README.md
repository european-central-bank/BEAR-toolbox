# BEARX Toolbox

The BEARX Toolbox is a Matlab toolbox for Bayesian estimation, analysis, and
reporting of vector autoregressive (VAR) models. BEARX is an extended version
of the original BEAR Toolbox (version 5), adding a new command-line interface
(CLI) and a new graphical user interface (GUI) while keeping the original BEAR
available as before.

## Features

- A comprehensive range of Bayesian VAR estimators: plain (OLS, Minnesota,
  Normal-Wishart, …), time-varying, panel, factor-augmented (FAVAR),
  threshold, and mixed-frequency
- Structural identification via Cholesky decomposition, zero restrictions,
  sign restrictions, and generalized restrictions
- Forecasting (unconditional and conditional), impulse response functions,
  historical shock decomposition, and forecast error variance decomposition
- A transparent GUI that auto-generates editable Matlab scripts — nothing
  runs behind the scenes

## Quick start

**Step 1.** Clone this repository and, optionally, the companion
[BEARX GUI Examples](https://github.com/OGResearch/BEARX-GUI-Examples)
repository from within Matlab:

```matlab
!git clone https://github.com/OGResearch/BEARX-Toolbox
!git clone https://github.com/OGResearch/BEARX-GUI-Examples
```

**Step 2.** Add the toolbox to the Matlab path:

```matlab
addpath BEARX-Toolbox -end; bearPaths
```

**Step 3.** Create or open a model folder and launch the GUI:

```matlab
gui.start    % fresh session (resets configuration)
gui.resume   % resume a previous session
```

See the wiki page [Setting things up](https://github.com/OGResearch/BEARX-Toolbox/wiki/setting_things_up)
for detailed instructions.

## Repository layout

```
bearPaths.m        – adds the toolbox subfolders to the Matlab path
tbx/
  bear/            – original BEAR Toolbox (version 5) code
  bearing/         – BEARX extended estimation and model engine
  gui/             – GUI source (HTML interface, form definitions, script generator)
```

## Documentation

Full documentation is available in the
[BEARX Toolbox Wiki](https://github.com/OGResearch/BEARX-Toolbox/wiki):

- [Setting things up](https://github.com/OGResearch/BEARX-Toolbox/wiki/setting_things_up)
  — cloning the repositories, adding paths, opening the GUI
- [GUI step-by-step guide](https://github.com/OGResearch/BEARX-Toolbox/wiki/gui_step_by_step)
  — walkthrough of every GUI tab, from estimator selection to script generation
- [Reduced-form estimators](https://github.com/OGResearch/BEARX-Toolbox/wiki/reduced_form_estimators)
  — reference material on the available estimation methods

## License

See the BEAR End User Licence Agreement included in the repository
(`tbx/bear/BEAR End User Licence Agreement.pdf`).

