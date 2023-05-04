# Import necessary modules
from psychopy import core, visual, logging
import numpy as np
import keyboard

# Create a window
window_backend = 'glfw'
win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                    monitor='tracking', screen=1, winType=window_backend)
win.recordFrameIntervals = True
logging.console.setLevel(logging.WARNING)

# Create Gabor stimulus
gabor = visual.GratingStim(win, sf=0.75, size=6, phase=0.5, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.2)

# Create center fixation
center = visual.GratingStim(win, sf=0.0, size=1.2, mask='raisedCos', maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
fixation = visual.GratingStim(win, color=0.5, colorSpace='rgb', tex=None, mask='raisedCos', size=0.4, autoDraw=True)

# Create response probe
prob = visual.Line(win, start=(0.0, -3), end=(0.0, 3), lineWidth=4.0, lineColor='black', size=1, contrast=0.80)

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

# Initialize orientation
#ori = np.random.rand() * 180
#prob_ornt = ori

# Save stuff
stim_list = []
resp_list = []
period_list = []
std_list = []

# Define Gaussian random walk parameters:
# S.D. [1, 2, 3, 4]
mean = 0
std = 1

# Define speed profile parameters:
period = 20     # Frames
amplitude = 0   # Degrees

# Set up number of "trials"
num_trials = 50

# Subject infoa
subj = 'KDM'

# Condition info
#cond = f"_std{std}_p{period}"
cond = f"_RW_only_std{std}"

# Trial function
def ori_stim_seq(ori, mean, std, period, amplitude, stim_list, resp_list):
  
    global prob_ornt
   
    # Set number of frames for each trial sequence
    # 11 (sec) * 60 (frames / sec)
    trial_length = 11 * 60

    for t in range(trial_length): # Present trials

        # Get contribution from Gaussian random walk
        noise_t = np.random.normal(mean, std)
        ori += noise_t

        # Get contribution from cosine wave
        wave_t = amplitude * np.cos((t % period) * (2 * np.pi / period))
        stim_ori = ori + wave_t    

        # set stimulus orientation
        gabor.ori = stim_ori

        # Draw stimulus and flip window        
        prob.setOri(prob_ornt)
        gabor.draw()
        prob.draw()
        win.flip()
                
        # Save stuff
        stim_list.append(stim_ori)

        # Save response stuff
        resp_list.append(prob_ornt)        

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
       
    # Blank screen
    while exp_clock.getTime() <= Blank_delay:
        win.flip()

# Save stuff
file_path = './ori_track_data_' + subj + cond + '.npy'
print(file_path)
print('Overall, %i frames were dropped.' % win.nDroppedFrames)
np.save(file_path,[stim_list, resp_list])
