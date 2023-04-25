# Import necessary modules
from psychopy import visual, event
import numpy as np
import keyboard

# Save orientations
stim_list = []
resp_list = []

# Create a window
window_backend = 'glfw'
win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                    monitor='rm_413', screen=1, winType=window_backend)

# Create Gabor stimulus
gabor = visual.GratingStim(win, sf=0.75, size=4, phase=0.5, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.2)
prob = visual.Line(win, start=(0.0, -2), end=(0.0, 2), lineWidth=5.0, lineColor='black', size=1, contrast=0.80)

center = visual.GratingStim(win, sf=0.0, size=1.0, mask='raisedCos', maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
fixation = visual.GratingStim(win, color=0.5, colorSpace='rgb', tex=None, mask='raisedCos', size=0.25, autoDraw=True)

# define callback function for keyboard event
prob_ornt = 0
prob.setOri(prob_ornt)
def left_callback(event):
    global prob_ornt
    prob_ornt -= 4
  
def right_callback(event):
    global prob_ornt
    prob_ornt += 4 

# key binding for recording response
key_bind = {'a':left_callback, 'l':right_callback}
for key, callback in key_bind.items():
    keyboard.on_press_key(key, callback)


# Define Gaussian random walk parameters:
mean = 0
std = 2

# Define speed profile parameters:
period = 25 # Frames
amplitude = 2  # Degrees

trial_length = 600

# Initialize orientation
ori = np.random.rand() * 180
prob_ornt = ori

for t in range(trial_length): # Present trials    

    # Draw stimulus and flip window
    gabor.draw()
    prob.setOri(prob_ornt)
    prob.draw()
    win.flip()
    
    # Get a random step from Gaussian random walk
    noise_t = np.random.normal(mean, std)
    ori += noise_t

    # Calculate current angle of rotation based on cosine speed profile
    wave_t = amplitude * np.cos((t % period) * (2 * np.pi / period))
    
    stim_ori = ori + wave_t

    # Save stuff
    stim_list.append(stim_ori)

    # Save response stuff
    resp_list.append(prob_ornt)

    # Draw stimulus
    gabor.ori = stim_ori
    
# Close the window
win.close()

np.save('./data.npy', [stim_list, resp_list])