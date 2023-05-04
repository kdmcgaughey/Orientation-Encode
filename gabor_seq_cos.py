# Import necessary modules
from psychopy import visual, event
import numpy as np
import keyboard

# Create a window
window_backend = 'glfw'
win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                    monitor='rm_413', screen=1, winType=window_backend)


# Initialize orientation
ori = 0.0

# Initialize speed profile
speed = 0.01     # Degrees per frame
period = 200     # In trials
amplitude = 360  # In Degrees

# Create Gabor stimulus
gabor = visual.GratingStim(win, sf=0.5, size=7.5, phase=0.5, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.25)
prob = visual.Line(win, start=(0.0, -3.5), end=(0.0, 3.5), lineWidth=10.0, lineColor='black', size=1, contrast=0.80)
center = visual.GratingStim(win, sf=0.0, size=2.0, mask='raisedCos', maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
fixation = visual.GratingStim(win, color=0.5, colorSpace='rgb', tex=None, mask='raisedCos', size=0.25, autoDraw=True)

# define callback function for keyboard event
prob_ornt = 0
prob.setOri(prob_ornt)
def left_callback(event):
    global prob_ornt
    prob_ornt -= 10.0

def right_callback(event):
    global prob_ornt
    prob_ornt += 10.0

# key binding for recording response
key_bind = {'a':left_callback, 'l':right_callback}
for key, callback in key_bind.items():
    keyboard.on_press_key(key, callback)

# Present sequence of Gabor stimuli

num_frames = 1 # Stimulus duration in frames

for trial in range(2000): # Present trials

    # Random walk for orientation
    for i in range(num_frames):   

        # Draw stimulus and flip window
        gabor.draw()
        prob.setOri(prob_ornt)
        prob.draw()
        win.flip()
        
        #  Calculate the current angle of rotation based on cosine speed profile
        angle = amplitude * np.cos((trial % period) * (2 * np.pi / period))

        # Calculate the amount of rotation for this frame
        rotation = speed * angle

        # Update stimulus orientation
        ori += rotation

        # Draw stimulus
        gabor.ori = ori
    
# Close the window
win.close()
