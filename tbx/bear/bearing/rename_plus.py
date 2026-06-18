

import subprocess as sp
import sys

old_name = sys.argv[1]
new_name = sys.argv[2]
intermediate_name = "x" + new_name.removeprefix("+")

sp.run(["git", "mv", old_name, intermediate_name], check=True, )
sp.run(["git", "commit", "-m", "Intermediate rename"], check=True, )
sp.run(["git", "mv", intermediate_name, new_name], check=True, )
sp.run(["git", "commit", "-m", "Final rename"], check=True, )


