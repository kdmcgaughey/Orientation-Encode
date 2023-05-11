from experiment.tracking import *

# 'dial' or 'joystick'
block = Tracking(mode='dial')

# s.d. [1, 2, 3, 4]
block.sd = 1

# subject name
block.subject ='LQZ'

block.run()