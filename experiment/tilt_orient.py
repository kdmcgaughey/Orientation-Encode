from psychopy import core, visual
from datetime import datetime
from .sampler import sample_orientation, sample_stimuli
import os, json, random, numpy as np

# for keyboard IO
try:
    import keyboard
    
except Exception as exc:
    print(exc)
    print('Unable to import keyboard module, \
            keyboard IO will not be available')

# for joystick IO
# 'glfw' or 'pyglet' for backend
window_backend = 'glfw'
from psychopy.hardware import joystick
joystick.backend = window_backend

class OrientEncode:

    # default parameters for the experiment
    DEFAULT_DUR = 0.5
    DEFAULT_BLANK = 4.0
    DEFAULT_MASK = 0.25
    DEFAULT_DELAY = 1.25    
    DEFAULT_ISI = 0.5
    DEFAULT_LEN = 5.0

    def __init__(self, sub_val):
        # subject name/id
        self.sub_val = sub_val
        self.time_stmp = datetime.now().strftime("%d_%m_%Y_%H_%M_")

        # set parameter for the experiment        
        self.line_len = self.DEFAULT_LEN
        self.stim_dur = self.DEFAULT_DUR
        self.mask_dur = self.DEFAULT_MASK
        self.blank = self.DEFAULT_BLANK
        self.delay = self.DEFAULT_DELAY
        self.isi = self.DEFAULT_ISI

        # create condition sequence / record file for each subject
        self.data_dir = os.path.join('.', 'Behavior', self.sub_val)

        if not os.path.exists(self.data_dir):
            os.mkdir(self.data_dir)

        # will be used for recording response
        self.resp_flag = True
        self.increment = 0
        
        # initialize window, message
        # monitor = 'rm_413' for psychophysics and 'sc_3t' for imaging session
        self.win = visual.Window(size=(1920, 1080), fullscr=True, allowGUI=True, screen=1, monitor='rm_413', units='deg', winType=window_backend)

        # initialize stimulus
        self.target = visual.GratingStim(self.win, sf=1.0, size=10.0, mask='raisedCos', maskParams={'fringeWidth':0.25}, contrast=0.10)
        self.noise = visual.NoiseStim(self.win, units='pix', mask='raisedCos', size=512, contrast=0.12, noiseClip=3.0,
                            noiseType='Filtered', texRes=512, noiseElementSize=4, noiseFractalPower=0,
                            noiseFilterLower=7.5/512.0, noiseFilterUpper=12.5/512.0, noiseFilterOrder=3.0)

        self.fixation = visual.GratingStim(self.win, color=0.5, colorSpace='rgb', tex=None, mask='raisedCos', size=0.25)
        self.center = visual.GratingStim(self.win, sf=0.0, size=2.0, mask='raisedCos', maskParams={'fringeWidth':0.15}, contrast=0.0)
        self.prob = visual.Line(self.win, start=(0.0, -self.line_len), end=(0.0, self.line_len), lineWidth=10.0, lineColor='black', size=1, contrast=0.80)
        
        return

    def _draw_blank(self):
        self.fixation.draw()
        self.win.flip()

        return

    def start(self, wait_on_key=True):
        self.n_trial = 250
        self.context = []
        self.response = []
        self.resp_time = []

        # generate sequence of context
        hazard = 0.04
        cond = True
        for _ in range(self.n_trial):
            if np.random.random() <= hazard:
                cond = not cond
            self.context.append(cond)
        self.context = np.array(self.context).astype(np.int)
        
        # generate stimulus sequence for each context
        n_ct0 = np.sum(self.context == 0)
        n_ct1 = np.sum(self.context == 1)
        stim_ct0 = sample_stimuli(n_ct0, mode='cardinal')
        stim_ct1 = sample_stimuli(n_ct1, mode='oblique')
        
        self.stimulus_array = [stim_ct0, stim_ct1]
        self.counter_array = [0, 0]

        # set up for the first trial
        ctx_idx = self.context[0]
        self.target.ori = self.stimulus_array[ctx_idx][self.counter_array[ctx_idx]]
        self.counter_array[ctx_idx] += 1
        self.target.phase = np.random.rand()

        if ctx_idx == 0:
            self.fixation.color = [1, 0, 0]
        else:
            self.fixation.color = [0, 1, 0]        

        # wait for confirmation
        if wait_on_key:
            self.io_wait()

        return

    def run(self):
        
        # start experiment
        # clock for global and trial timing
        self.global_clock = core.Clock()
        self.clock = core.Clock()

        # initial blank period
        self.clock.reset()
        while self.clock.getTime() <= self.blank:
            self._draw_blank()

        for idx in range(self.n_trial):
            # draw stimulus for a fixed duration
            self.clock.reset()           
            while self.clock.getTime() <= self.stim_dur:
                # 2 hz contrast modulation
                t = self.clock.getTime()
                crst = 0.05 * np.cos(4.0 * np.pi * t + np.pi) + 0.05
                                
                self.target.contrast = crst
                self.target.draw()
                self.center.draw()

                # draw fixation dot
                self.fixation.draw()
                self.win.flip()

            # draw mask
            self.clock.reset()           
            while self.clock.getTime() <= self.mask_dur:
                self.noise.draw()
                self.center.draw()

                # draw fixation dot
                self.fixation.draw()
                self.win.flip()
          
            # blank screen for delay duration
            # also set up the next stim
            self.clock.reset()

            # setup stim condition for next trial
            if idx < self.n_trial - 1:
                ctx_idx = self.context[idx + 1]                
                self.target.ori = self.stimulus_array[ctx_idx][self.counter_array[ctx_idx]]
                self.counter_array[ctx_idx] += 1
                self.noise.updateNoise()        
                
            # blank period
            while self.clock.getTime() <= self.delay:
                self._draw_blank()

            # response period
            self.clock.reset()
            response = self.io_response()
            trial_rt = self.clock.getTime()

            # record 
            self.resp_time.append(trial_rt)
            self.response.append(int(response))

            # change color of fixation dot
            if ctx_idx == 0:
                self.fixation.color = [1, 0, 0]
            else:
                self.fixation.color = [0, 1, 0]        

            # ISI
            self.clock.reset()
            while self.clock.getTime() <= self.isi:
                self._draw_blank()

        # record session time
        self.session_time = self.global_clock.getTime()

        return

    def save_data(self):
        # write subject record
        file_name = self.sub_val + '_' + self.time_stmp + '.npy'
        file_path = os.path.join(self.data_dir, file_name)
        
        save_vars = [self.context, self.response, self.resp_time,
                    self.stimulus_array[0], self.stimulus_array[1]]

        with open(file_path, 'wb') as fl:
            for var in save_vars:
                np.save(fl, np.array(var))

        return

    def pause(self):
        self.save_data()
        self.io_wait(wait_key='space')
        return

    def end(self):
        self.save_data()
        print('Successfully finish the experiment!')

    def io_wait(self):
        raise NotImplementedError("IO Method not implemented in the base class")

    def io_response(self):
        raise NotImplementedError("IO Method not implemented in the base class")

# Implement IO method with keyboard
class OrientEncodeKeyboard(OrientEncode):

    def __init__(self, sub_val):
        super().__init__(sub_val)
        self.pause_msg = visual.TextStim(self.win, pos=[0, 0], text='Press Space when you are ready to continue.')

    def io_wait(self):
        '''override io_wait'''
        self.resp_flag = True
        def confirm_callback(event):
            self.resp_flag= False

        # register callback, wait for key press
        keyboard.on_release_key('space', confirm_callback)
        while self.resp_flag:
            self.pause_msg.draw()
            self.win.flip()

        return

    def io_response(self):
        '''override io_response'''
        resp = int(sample_orientation(n_sample=1, uniform=True))
        self.prob.setOri(resp)

        # global variable for recording response
        self.resp_flag = True
        self.increment = 0

        # define callback function for keyboard event
        def left_callback(event):
            self.increment = -1.0

        def right_callback(event):
            self.increment = +1.0

        def release_callback(event):
            self.increment = 0.0

        def confirm_callback(event):
            self.resp_flag = False

        def aboard_callback(event):
            self.resp_flag = False
            self.win.close()
            core.quit()

        # key binding for recording response
        key_bind = {'left':left_callback, 'right':right_callback, 'space':confirm_callback, 'escape':aboard_callback}
        for key, callback in key_bind.items():
            keyboard.on_press_key(key, callback)

        for key in ['left', 'right']:
            keyboard.on_release_key(key, release_callback)

        # wait/record for response
        while self.resp_flag:
            if not self.increment == 0:
                resp += self.increment
                resp %= 180
                self.prob.setOri(resp)

            self.prob.draw()
            self.fixation.draw()
            self.win.flip()

        keyboard.unhook_all()
        return resp

# IO with joystick button push
class OrientEncodeButtons(OrientEncode):

    def __init__(self, sub_val, joy_id=0):
        super().__init__(sub_val)        
        self.pause_msg = visual.TextStim(self.win, pos=[0, 0], text='Press L2 or R2 when you are ready to continue.')

        # joystick setup
        self.L1 = 4
        self.L2 = 6
        self.R1 = 5
        self.R2 = 7

        nJoys = joystick.getNumJoysticks()
        if nJoys < joy_id:
            print('Joystick Not Found')

        self.joy = joystick.Joystick(joy_id)

    def io_wait(self):
        '''override io_wait'''
        while not self.confirm_press():
            self.pause_msg.draw()
            self.win.flip()

        return

    def io_response(self):
        '''override io_response'''
        resp = int(sample_orientation(n_sample=1, uniform=True))
        self.prob.setOri(resp)

        while not self.confirm_press():
            self.prob.draw()
            self.fixation.draw()
            self.win.flip()

            if self.joy.getButton(self.L1):
                resp -= 1
                resp %= 180
                self.prob.setOri(resp)

            if self.joy.getButton(self.R1):
                resp += 1
                resp %= 180
                self.prob.setOri(resp)

        return resp

    def confirm_press(self):
        return self.joy.getButton(self.L2) or \
                self.joy.getButton(self.R2)

# Response with Joystick Axis
class OrientEncodeJoystick(OrientEncodeButtons):
    def io_response(self):
        '''override io_response'''
        resp = int(sample_orientation(n_sample=1, uniform=True))
        self.prob.setOri(resp)

        while not self.confirm_press():
            self.prob.draw()
            self.fixation.draw()
            self.win.flip()

            x = self.joy.getX()
            y = self.joy.getY()
            if np.sqrt(x ** 2 + y ** 2) >= 1:
                resp = (np.arctan(y / x) / np.pi * 180.0 - 90) % 180
                self.prob.setOri(resp)

        return resp

    # use different buttons to confirm response
    def confirm_press(self):
        return self.joy.getButton(self.L1) or \
                self.joy.getButton(self.R1)