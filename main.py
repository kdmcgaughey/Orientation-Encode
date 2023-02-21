from experiment.orient_context import *
import sys

# create the experiment with n_trial for each block
# different class for choices of IO methods
if not len(sys.argv) == 2:
    sub_val = str(input('Enter Unique Subject ID:'))
else:
    sub_val = str(sys.argv[1])

# start running the experiment
exp = OrientEncodeKeyboard(sub_val)
exp.start(wait_on_key=True)
exp.run()
exp.save_data()