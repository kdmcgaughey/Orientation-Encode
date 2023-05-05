# Import necessary modules
from psychopy import core, visual, logging
from psychopy.hardware import joystick
from datetime import datetime
import numpy as np
import keyboard

class Tracking:
    def __init__(self, mode='dial'):
        # Create a window
        window_backend = 'glfw'
        self.win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                            monitor='tracking', screen=1, winType=window_backend)
        self.win.recordFrameIntervals = True
        logging.console.setLevel(logging.WARNING)

        # Create Gabor stimulus
        self.gabor = visual.GratingStim(self.win, sf=0.75, size=6, phase=0.5, mask='raisedCos',
                                        maskParams={'fringeWidth':0.25}, contrast=0.2)
        # Create center fixation
        self.center = visual.GratingStim(self.win, sf=0.0, size=1.2, mask='raisedCos',
                                         maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
        self.fixation = visual.GratingStim(self.win, color=0.5, colorSpace='rgb',
                                           tex=None, mask='raisedCos', size=0.4, autoDraw=True)
        # Create response probe
        self.prob = visual.Line(self.win, start=(0.0, -3), end=(0.0, 3), lineWidth=4.0,
                                lineColor='black', size=1, contrast=0.80)

        # Response probe
        self.prob_ornt = 0
        self.resp_flag = False
        
        # Input mode
        self.mode = mode
        if self.mode == 'dial':
            # Define callback function for rotating the probe
            def left_callback(event):
                self.prob_ornt -= 3

            def right_callback(event):
                self.prob_ornt += 3

            # Key binding for recording response
            key_bind = {'a':left_callback, 'l':right_callback}
            for key, callback in key_bind.items():
                keyboard.on_press_key(key, callback)

            # Define callback function for confrim
            def confirm_callback(event):
                self.resp_flag= False

            # register callback, wait for key press
            keyboard.on_release_key('space', confirm_callback)
                
        if self.mode == 'joystick':
            # initialize joystick
            joystick.backend = window_backend
            self.joystick = joystick.Joystick(0)
        
        # Record stimulus and responses
        self.stim_list = []
        self.resp_list = []

        # Experiment parameters
        self.num_trials = 50
        self.frame_rate = 60
        self.trial_length = 12 * self.frame_rate

        # Gaussian random walk parameters
        self.mean = 0
        self.sd = 1

        # Condition info
        self.time_stmp = datetime.now().strftime("%d_%m_%Y_%H_%M")
        self.subject = None        

    def trial(self, ori):
        stim = []
        resp = []

        # Present a single trial by frame
        for t in range(self.trial_length):

            # Gaussian random walk
            noise_t = np.random.normal(self.mean, self.sd)
            ori += noise_t

            # Sinusoidal
            wave_t = 0
            stim_ori = ori + wave_t

            # set stimulus and probe orientation
            self.gabor.ori = stim_ori
            self.prob.ori = self.prob_ornt

            # Draw stimulus and flip window             
            self.gabor.draw()
            self.prob.draw()
            self.win.flip()
            
            # Get joystick response
            if self.mode == 'joystick':
                # left axis    
                x = joystick.getAxis(0)        
                y = joystick.getAxis(1)
                if np.sqrt(x ** 2 + y ** 2) >= 1:
                    self.prob_ornt = (np.arctan(y / x) / np.pi * 180.0 - 90) % 180 

            # Save stimulus and response orientation at each frame
            stim.append(stim_ori)
            resp.append(self.prob_ornt)

        # Add to all stimulus and response
        self.stim_list.append(stim)
        self.resp_list.append(resp)
        return
    
    def kb_wait(self):
        # setup callback
        self.resp_flag = True

        # wait for keyboard press     
        while self.resp_flag:
            self.win.flip()
        return
    
    def joy_wait(self):                
        self.L2 = 6
        self.R2 = 7
        
        # wait for button press
        while not (self.joy.getButton(self.L2) or \
                   self.joy.getButton(self.R2)):            
            self.win.flip()
        return                

    def run(self):
        print(self.time_stmp)
        print(self.subject + ' SD=%.2f' % self.sd)

        # Run trials        
        for trials in range (self.num_trials):
            # Wait for subject to start next trial
            if self.mode == 'dial':
                self.kb_wait()
                
            if self.mode == 'joystick':
                self.joy_wait()                

            # Initialize orientation
            ori = np.random.rand() * 180
            self.prob_ornt = ori
            self.trial(ori)           

        # Save data
        self.stim_list = np.array(self.stim_list)
        self.resp_list = np.array(self.resp_list)
        
        # file_path = './ori_track_data_' + subj + cond + '.npy'
        # np.save(file_path,[stim_list, resp_list])

        # print('Data saved to ' + file_path)
        # print('Overall, %i frames were dropped.' % win.nDroppedFrames)

