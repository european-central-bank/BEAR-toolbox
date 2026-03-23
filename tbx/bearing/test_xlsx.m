

c = {
    "Instructions", "", "", "", "", "", "", ""
    "", "VAR order", "Endogenous Names", "Exogenous Names", "Structural shock names", "Num endogenous", "Num exogenous", "Num structural shocks"
    "", 4, "GDP", "OIL", "DEM", 3, 1, 3
    "", "", "CPI", "", "SUP", "", "", ""
    "", "", "STNc", "", "POL", "", "", ""
}


writecell(c, "BearInterface.xlsx", sheet="Meta", range="A1")

cc = readcell("BearInterface.xlsx", sheet="Meta", range="A1")

