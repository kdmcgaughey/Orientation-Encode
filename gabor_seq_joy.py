# Import necessary modules
from psychopy import core, visual, event
import numpy as np
import keyboard

# Create a window
window_backend = 'glfw'
from psychopy.hardware import joystick
win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                    monitor='rm_413', screen=1, winType=window_backend)
# joystick
joystick.backend = window_backend
joy = joystick.Joystick(0)

# Create Gabor stimulus
gabor = visual.GratingStim(win, sf=0.75, size=4, phase=0.5, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.2)

# Create center fixation
center = visual.GratingStim(win, sf=0.0, size=1.0, mask='raisedCos', maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
fixation = visual.GratingStim(win, color=0.5, colorSpace='rgb', tex=None, mask='raisedCos', size=0.25, autoDraw=True)

# Create response probe
prob = visual.Line(win, start=(0.0, -2), end=(0.0, 2), lineWidth=5.0, lineColor='black', size=1, contrast=0.80)

# Define callback function for keyboard event
prob_ornt = 0
def left_callback(event):
    global prob_ornt
    prob_ornt -= 4
  
def right_callback(event):
    global prob_ornt
    prob_ornt += 4 

# Key binding for recording response
key_bind = {'a':left_callback, 'l':right_callback}
for key, callback in key_bind.items():
    keyboard.on_press_key(key, callback)

# Save stuff
stim_list = []
resp_list = []
period_list = []
std_list = []

# Define Gaussian random walk parameters:
mean = 0
std = 2

# Define speed profile parameters:
period = 20     # Frames
amplitude = 0   # Degrees

# Set up number of "trials"
num_trials = 30

# Subject infoa
subj = 'KM_Joystick'

# Condition info
#cond = f"_std{std}_p{period}"
cond = f"_RW_only_std{std}"

# Trial function
def ori_stim_seq(ori, mean, std, period, amplitude, stim_list, resp_list):
    global prob_ornt
   
    # Set number of frames for each trial sequence
    trial_length = 60 * 12

    for t in range(trial_length): # Present trials    

        # Draw stimulus and flip window
        gabor.draw()
        prob.setOri(prob_ornt)
        prob.draw()

        # Joy stick response
        # left axis    
        x = joy.getAxis(0)        
        y = joy.getAxis(1)
        if np.sqrt(x ** 2 + y ** 2) >= 1:
            prob_ornt = (np.arctan(y / x) / np.pi * 180.0 - 90) % 180 
                
        # Get contribution from Gaussian random walk
        noise_t = np.random.normal(mean, std)
        ori += noise_t

        # Get contribution from cosine wave
        wave_t = amplitude * np.cos((t % period) * (2 * np.pi / period))
        stim_ori = ori + wave_t

        # Save stuff
        stim_list.append(stim_ori)

        # Save response stuff
        resp_list.append(prob_ornt)

        # Update stimulus
        gabor.ori = stim_ori

        # Flip frame 
        win.flip()

# Set up timing between "trials"
exp_clock = core.Clock()
Blank_delay = 4

# Run trials
for b in range (num_trials):

    # Initialize orientation
    ori = np.random.rand() * 180
    prob_ornt = ori

    # Run trials
    ori_stim_seq(ori, mean, std, period, amplitude, stim_list, resp_list)
    exp_clock.reset()
   
    print(std)
    print(period)

    # Blank screen
    while exp_clock.getTime() <= Blank_delay:
        win.flip()

# Save stuff
file_path = './ori_track_data_' + subj + cond + '.npy'
print(file_path)
np.save(file_path,[stim_list, resp_list])