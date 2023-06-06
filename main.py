from experiment.tracking import *

# 'dial' or 'joystick'
block = Tracking(mode='joystick')

# s.d. [1, 2, 3, 4]
block.sd = 3

# change parameters
# block.amplitude = 10

# subject name
block.subject ='KDM'

block.run()