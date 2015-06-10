% This file defines a class for the frame of the g729 encoder 
classdef g729_frm_cls < handle

  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %% Constants for this function
  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  properties (Constant)
    FS = 8e3; % Sample frequency is 8 KHz
		FRM_SIZE=10e-3*g729_frm_cls.FS;
    SUB_FRM_SIZE=g729_frm_cls.FRM_SIZE/2;
    LPC_COEFF_TAB = 10;
    %%---------------------------------------------------------------------
    %% Constants for this G.729 encoder 
    %%---------------------------------------------------------------------
    C_Fs        = 8e3;                                    % Sampling frequency is 8 KHz 
    C_Ts        = 1/g729_frm_cls.C_Fs;                    % Sampling Time interval
    C_10ms      = 10e-3;                                  % 10 Milli Second is the frame interval  
    C_Frm_sz    = g729_frm_cls.C_10ms/g729_frm_cls.C_Ts;  % Number of samples that spans a frame 
    C_Lag_wdw   = 3* g729_frm_cls.C_Frm_sz;               % Number of samples that spans a lag window 
    C_Sb_Frm_sz = g729_frm_cls.C_Frm_sz/2;                % Number of samples that spans a subframe 

    %%---------------------------------------------------------------------
    %% Constants for the low pass filter 
    %%---------------------------------------------------------------------
    %C_b = [+0.92727435e+0/2.0, -0.18544941e+1/2.0, +0.92727435e+0/2.0]; % From the spec
    C_b = [+0.92727435e+0, -0.18544941e+1, +0.92727435e+0];
    C_a = [+1.00000000e+0, +0.19059465e+1, -0.91140240e+0];

    %%---------------------------------------------------------------------
    %% LP window constants 
    %%---------------------------------------------------------------------
    C_wlp   = [8.0000000e-02, 8.0057034e-02, 8.0228121e-02, 8.0513220e-02, 8.0912259e-02, 8.1425140e-02, 8.2051735e-02, 8.2791888e-02, 8.3645418e-02, 8.4612111e-02, ...
               8.5691728e-02, 8.6884001e-02, 8.8188636e-02, 8.9605307e-02, 9.1133664e-02, 9.2773328e-02, 9.4523892e-02, 9.6384923e-02, 9.8355958e-02, 1.0043651e-01, ...
               1.0262606e-01, 1.0492407e-01, 1.0732996e-01, 1.0984315e-01, 1.1246300e-01, 1.1518888e-01, 1.1802009e-01, 1.2095594e-01, 1.2399571e-01, 1.2713863e-01, ...
               1.3038393e-01, 1.3373081e-01, 1.3717842e-01, 1.4072593e-01, 1.4437245e-01, 1.4811707e-01, 1.5195887e-01, 1.5589689e-01, 1.5993016e-01, 1.6405768e-01, ...
               1.6827842e-01, 1.7259134e-01, 1.7699537e-01, 1.8148941e-01, 1.8607235e-01, 1.9074306e-01, 1.9550037e-01, 2.0034311e-01, 2.0527007e-01, 2.1028004e-01, ...
               2.1537178e-01, 2.2054401e-01, 2.2579545e-01, 2.3112481e-01, 2.3653077e-01, 2.4201198e-01, 2.4756708e-01, 2.5319469e-01, 2.5889343e-01, 2.6466187e-01, ...
               2.7049859e-01, 2.7640214e-01, 2.8237105e-01, 2.8840385e-01, 2.9449903e-01, 3.0065510e-01, 3.0687052e-01, 3.1314374e-01, 3.1947322e-01, 3.2585739e-01, ...
               3.3229466e-01, 3.3878343e-01, 3.4532210e-01, 3.5190904e-01, 3.5854262e-01, 3.6522121e-01, 3.7194313e-01, 3.7870672e-01, 3.8551032e-01, 3.9235222e-01, ...
               3.9923073e-01, 4.0614415e-01, 4.1309077e-01, 4.2006885e-01, 4.2707668e-01, 4.3411250e-01, 4.4117458e-01, 4.4826117e-01, 4.5537051e-01, 4.6250084e-01, ...
               4.6965038e-01, 4.7681736e-01, 4.8400002e-01, 4.9119656e-01, 4.9840520e-01, 5.0562416e-01, 5.1285164e-01, 5.2008585e-01, 5.2732500e-01, 5.3456730e-01, ...
               5.4181094e-01, 5.4905413e-01, 5.5629508e-01, 5.6353198e-01, 5.7076306e-01, 5.7798650e-01, 5.8520052e-01, 5.9240334e-01, 5.9959316e-01, 6.0676820e-01, ...
               6.1392669e-01, 6.2106684e-01, 6.2818689e-01, 6.3528507e-01, 6.4235963e-01, 6.4940880e-01, 6.5643085e-01, 6.6342402e-01, 6.7038658e-01, 6.7731681e-01, ...
               6.8421299e-01, 6.9107342e-01, 6.9789637e-01, 7.0468018e-01, 7.1142315e-01, 7.1812361e-01, 7.2477990e-01, 7.3139036e-01, 7.3795337e-01, 7.4446730e-01, ...
               7.5093052e-01, 7.5734143e-01, 7.6369845e-01, 7.7000000e-01, 7.7624451e-01, 7.8243045e-01, 7.8855626e-01, 7.9462044e-01, 8.0062149e-01, 8.0655790e-01, ...
               8.1242822e-01, 8.1823098e-01, 8.2396474e-01, 8.2962809e-01, 8.3521963e-01, 8.4073795e-01, 8.4618170e-01, 8.5154952e-01, 8.5684009e-01, 8.6205209e-01, ...
               8.6718423e-01, 8.7223524e-01, 8.7720386e-01, 8.8208887e-01, 8.8688904e-01, 8.9160320e-01, 8.9623016e-01, 9.0076880e-01, 9.0521797e-01, 9.0957657e-01, ...
               9.1384354e-01, 9.1801780e-01, 9.2209832e-01, 9.2608409e-01, 9.2997412e-01, 9.3376744e-01, 9.3746313e-01, 9.4106025e-01, 9.4455793e-01, 9.4795528e-01, ...
               9.5125147e-01, 9.5444568e-01, 9.5753712e-01, 9.6052502e-01, 9.6340864e-01, 9.6618727e-01, 9.6886022e-01, 9.7142682e-01, 9.7388643e-01, 9.7623846e-01, ...
               9.7848231e-01, 9.8061742e-01, 9.8264328e-01, 9.8455937e-01, 9.8636523e-01, 9.8806039e-01, 9.8964445e-01, 9.9111701e-01, 9.9247771e-01, 9.9372620e-01, ...
               9.9486218e-01, 9.9588537e-01, 9.9679551e-01, 9.9759237e-01, 9.9827577e-01, 9.9884552e-01, 9.9930150e-01, 9.9964358e-01, 9.9987168e-01, 9.9998574e-01, ...
               1.0000000e+00, 9.9921931e-01, 9.9687846e-01, 9.9298110e-01, 9.8753331e-01, 9.8054362e-01, 9.7202291e-01, 9.6198451e-01, 9.5044409e-01, 9.3741966e-01, ...
               9.2293156e-01, 9.0700241e-01, 8.8965709e-01, 8.7092267e-01, 8.5082841e-01, 8.2940569e-01, 8.0668794e-01, 7.8271065e-01, 7.5751124e-01, 7.3112907e-01, ...
               7.0360534e-01, 6.7498300e-01, 6.4530676e-01, 6.1462295e-01, 5.8297948e-01, 5.5042575e-01, 5.1701261e-01, 4.8279220e-01, 4.4781798e-01, 4.1214454e-01, ...
               3.7582758e-01, 3.3892382e-01, 3.0149086e-01, 2.6358717e-01, 2.2527191e-01, 1.8660492e-01, 1.4764656e-01, 1.0845768e-01, 6.9099448e-02, 2.9633328e-02];
    C_wlag = [1.0001000e+00, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, 9.7671347e-01, ...
              9.7671347e-01];
	end

  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %% Variables that need to be passed when creating an object 
  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	% These variables are related to the Frame of the current window 
	properties 
    speech_3frames; % This is 3 frame worth of data samples passed to this class
    
    lp_fil_y2;    % Low pass filter Y2 component
    lp_fil_y1;    % Low pass filter Y1 component
    lp_fil_x2;    % Low pass filter X2 component
    lp_fil_x1;    % Low pass filter X1 component
	end 

  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %% Variables that are created during the encoder function  
  %%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	properties (Access = public) 
		prv_frame; % Previous frame raw samples (This should be out of the HP filter)
		cur_frame; % Current frame raw samples
		nxt_frame; % Next frame raw samples

		cur_subfrm1;   % Subframe 1 samples
		cur_subfrm2;   % Subframe 2 samples
    prp_cur_frame; % Preprocessed current frame

    r_dash;        % Modified auto correlation coefficients
    a;             % Auto correlation coefficients 
		lpc_coeff;     % Unquantized LPC coefficients (formant filter)
		lpc_err;       % Error magnitued for the LPC coefficients
	end

	% Functions used for this call
	methods (Access = public)
    % Register the functions here 
    obj = init(obj);          % Function to initialize the constant and other variables for the design 
    obj = pre_process(obj);   % Function to do the preprocessing of the speech samples 
		obj = gen_lpc(obj);       % Function to generate the lpc coeffcicients 
		obj = auto_corr(obj);     % Function to generate the autocorrelation of the given window 

    obj = encode(obj);        % Function to encode the samples, and this is the super function that calls all other 
                              % functions
	end


end % End of class definition 


