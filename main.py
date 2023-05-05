from experiment.tracking import *

# 'dial' or 'joystick'
block = Tracking(mode='dial')

# S.D. [1, 2, 3, 4]
block.sd = 2
block.subject ='LQZ'

block.run()