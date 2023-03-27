# Import necessary modules
from psychopy import visual, event
import numpy as np

# Create a window
window_backend = 'glfw'
win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                    monitor='rm_413', screen=1, winType=window_backend)

# Joystick setup
from psychopy.hardware import joystick
joystick.backend = window_backend
joy = joystick.Joystick(0)

# Define Gabor stimulus parameters
sf = 5.0 # Spatial frequency
contrast = 1.0 # Contrast
phase = 0.0 # Phase
size = 200 # Size in pixels
num_frames = 10 # Stimulus duration in frames

# Initialize orientation
ori = 0.0

# Create Gabor stimulus
gabor = visual.GratingStim(win, sf=0.75, size=10.0, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.25)
prob = visual.Line(win, start=(0.0, -5), end=(0.0, 5), lineWidth=10.0, lineColor='black', size=1, contrast=0.80)

# Present sequence of Gabor stimuli
for trial in range(2000): # Present 200 trials
    # Random walk for orientation

    for i in range(10):    
        # Draw stimulus and flip window
        gabor.draw()        

        # joystick response
        x = joy.getX()
        y = joy.getY()
        if np.sqrt(x ** 2 + y ** 2) >= 1:
            resp = (np.arctan(y / x) / np.pi * 180.0 - 90) % 180
            prob.setOri(resp)

        prob.draw()
        win.flip()

    # Sample from Gaussian distribution for orientation step
    ori_step = np.random.normal(0, 5) # Mean of 0, variance of 5 deg
    ori += ori_step # Add orientation step to current orientation

    # Update Gabor stimulus with new orientation
    gabor.ori = ori
    
# Close the window
win.close()
