# Import necessary modules
from psychopy import visual, logging, core
from psychopy.hardware import joystick
from datetime import datetime
from scipy.io import savemat
import numpy as np
import keyboard, os

class Tracking:
    def __init__(self, mode='dial'):
        # Create a window
        window_backend = 'glfw'
        self.win = visual.Window([1920, 1080], fullscr=True, allowGUI=True, units='deg',
                            monitor='tracking', screen=1, winType=window_backend)
        self.win.recordFrameIntervals = True
        logging.console.setLevel(logging.WARNING)

        # Create Gabor stimulus
        self.contrast = 0.125
        self.gabor = visual.GratingStim(self.win, sf=0.75, size=4, phase=0.5, mask='raisedCos',
                                        maskParams={'fringeWidth':0.25}, contrast=self.contrast)
        # Create center fixation
        self.center = visual.GratingStim(self.win, sf=0.0, size=1, mask='raisedCos',
                                         maskParams={'fringeWidth':0.2}, contrast=0.0, autoDraw=True)
        self.fixation = visual.GratingStim(self.win, color=0.5, colorSpace='rgb',
                                           tex=None, mask='raisedCos', size=0.4, autoDraw=True)
        # Create response probe
        self.prob = visual.Line(self.win, start=(0.0, -2), end=(0.0, 2), lineWidth=4.0,
                                lineColor='black', size=1, contrast=0.80)

        # sin parameter
        self.amplitude = 2
        self.period = 120

        # Response probe
        self.prob_ornt = 0
        self.resp_flag = False

        # Input mode
        self.mode = mode
        if self.mode == 'dial':
            # Define callback function for rotating the probe
            def left_callback(event):
                self.prob_ornt -= 3.5

            def right_callback(event):
                self.prob_ornt += 3.5

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
        
        # Experiment parameters
        self.num_trials = 30
        self.frame_rate = 60
        self.trial_length = 11 * self.frame_rate

        # Gaussian random walk parameters
        self.mean = 0
        self.sd = 3

        # Condition info             
        self.subject = None

        return

    def init(self):
        # Initialize a block of experiment
        
        # Record stimulus and responses
        self.stim_list = []
        self.resp_list = []
        self.all_stim_rw = []
        self.all_stim_s = []

        # Time stmp
        self.time_stmp = datetime.now().strftime("%d_%m_%Y_%H_%M")

        return

    def trial(self, ori):
        stim = []
        resp = []
        stim_rw = []
        stim_s = []

        freq = 1 / self.period
        # Present a single trial by frame
        for t in range(self.trial_length):

            # Gaussian random walk
            noise_t = np.random.normal(self.mean, self.sd)
            ori += noise_t
            stim_rw.append(ori)

            # Sinusoidal
            wave_t = self.amplitude * np.sin(t * freq * 2 * np.pi)           
            stim_ori = ori + wave_t
            stim_s.append(wave_t)

            # set stimulus and probe orientation
            self.gabor.ori = stim_ori
            self.prob.ori = self.prob_ornt

            # Draw stimulus and flip window
            self.gabor.draw()
            self.prob.draw()
            self.win.flip()

            # Save stimulus and response orientation at each frame
            stim.append(stim_ori)
            resp.append(self.prob_ornt)

            # Get joystick response
            if self.mode == 'joystick':
                # left axis
                x = self.joystick.getAxis(2)
                y = self.joystick.getAxis(3)
                if np.sqrt(x ** 2 + y ** 2) >= 1:
                    self.prob_ornt = (np.arctan(y / x) / np.pi * 180.0 - 90) % 180

        # Add to all stimulus and response
        self.stim_list.append(stim)
        self.resp_list.append(resp)
        self.all_stim_rw.append(stim_rw)
        self.all_stim_s.append(stim_s)
        return

    def kb_wait(self):
        # setup callback
        self.resp_flag = True

        # wait for keyboard press
        while self.resp_flag:
            self.win.flip()
        return

    def joy_wait(self):
        self.L2 = 4
        self.R2 = 5

        # wait for button press
        while not (self.joystick.getButton(self.L2) or \
                   self.joystick.getButton(self.R2)):
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

        print('Overall, %i frames were dropped.' % self.win.nDroppedFrames)

        # Save data
        self.stim_list = np.array(self.stim_list)
        self.resp_list = np.array(self.resp_list)
        self.all_stim_rw = np.array(self.all_stim_rw)
        self.all_stim_s = np.array(self.all_stim_s)

        file_name = '%s_%s.mat' % (self.time_stmp, self.subject)
        file_path = os.path.join('.', 'data', file_name)
        data = {'stim':self.stim_list, 'resp':self.resp_list, 
                'rw':self.all_stim_rw, 'sin':self.all_stim_s,
                'sd':self.sd, 'mode':self.mode, 'contrast':self.contrast,
                'amplitude':self.amplitude, 'period':self.period}
                
        savemat(file_path, data)
        print('Data saved to ' + file_path)        