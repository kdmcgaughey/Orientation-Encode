from experiment.tracking import *
import random

# loop through the experimental blocks
# define parameters of each block
amplitude = [2, 4, 6]
period = [30, 60, 120, 240]

# create pairs of conditions and shuffle them
conditions = []
for idx in range(len(amplitude)):
    for idy in range(len(period)):
        conditions.append((amplitude[idx], period[idy]))
random.shuffle(conditions)
conditions.insert(0, (0, 60))

# loop through the conditions and run each block
for idx in range(len(conditions)):
    amplitude, period = conditions[idx]
    
    # 'dial' or 'joystick'
    block = Tracking(mode='joystick')

    # number of trials
    if idx == 0:
        block.num_trials = 30
    else:
        block.num_trials = 20

    # change parameters
    block.amplitude = amplitude
    block.period = period

    # subject name
    block.subject ='KDM'

    block.run()