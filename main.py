from experiment.tracking import *
import random

# loop through the experimental blocks
# define parameters of each block
amplitude = [2, 4]
period = [30, 60, 120, 240]

# create pairs of conditions and shuffle them
conditions = []
for idx in range(len(amplitude)):
    for idy in range(len(period)):
        conditions.append((amplitude[idx], period[idy]))
random.shuffle(conditions)

# 'dial' or 'joystick'
block = Tracking(mode='joystick')

# loop through the conditions and run each block
for idx in range(len(conditions)):
    # init block
    block.init()

    # get condition
    amplitude, period = conditions[idx]    
    # number of trials
    block.num_trials = 20

    # change parameters
    block.amplitude = amplitude
    block.period = period

    # subject name
    block.subject ='KDM'

    # run block
    block.run()