from experiment.tracking import *

# 'dial' or 'joystick'
block = Tracking(mode='joystick')

# s.d. [1, 2, 3, 4]
block.sd = 2

# subject name
block.subject ='LQZ'

block.run()