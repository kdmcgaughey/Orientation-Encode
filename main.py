# # Define Gaussian random walk parameters:
# # S.D. [1, 2, 3, 4]
# mean = 0
# std = 1

# # Subject info
# subj = 'KDM'

# # Define speed profile parameters:
# period = 20     # Frames
# amplitude = 0   # Degrees'

from experiment.tracking import *

block = Tracking(mode='dial')
block.sd = 1
block.subject = 'KDM'

block.run()