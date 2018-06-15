function lab8sp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc

% Load the Data into Matlab
data = getecg;

% Prompt the user for the sampling rate.
samprate = input('\nInput the Sampling Rate (Hz) used to sample the ECG: ');

% Find indicies of R waves (threshold crossings)
intbegin = getindicies(data,samprate);

% Prompt user to choose Triggered Averaging, Heart Rate Variability, Or
to exit.
choice = 3;
while choice ~= 0
     while (choice ~= 0 && choice ~= 1 && choice ~= 2)
         clc
         q1; % Ask Question 1
         choice = input(' Your Choice: ');
     end

     % Run Triggered Averaging, Heart Rate Variability, or Exit
     if(choice == 1)
         trigav(data,samprate,intbegin); % Perform Triggered Averaging
         choice = 3;
     elseif(choice == 2)
         hrvar(data,samprate,intbegin); % Perform Heart Rate Variability
Analysis
         choice = 3;
     end
end
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=getecg
% Open a Window and allow the user to browse for the file.
[filename,pathname,filterindex]=uigetfile({'*.dat','Data files(*.dat)'},'Choose a .dat file');
disp('Loading ECG data...')
eval(['data = load (''',pathname,filename,''');']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function intbegin=getindicies(data,samprate)
% Find indicies of R waves (threshold crossings)

% Plot the first few seconds of the Waveform
Nsec = 5;
M = Nsec * samprate; % Number of points for Nsec seconds (at sampling
rate input above)

time_ex = (0:M-1)/samprate;
ecg_ex = data(1:M);

figure(1)
clf
plot(time_ex,ecg_ex);
title(['First ',num2str(Nsec),' secs of ECG Waveform']);
xlabel('Time (sec)'); ylabel('Voltage');

% Prompt user for threshold voltage
disp(' ')
disp('Based on the displayed portion of your ECG waveform (see Figure 1),');
threshold = input('Input a threshold voltage for triggering on the Rwaves: ');

M = length(data); % Find number of rows (i.e. # samples in ECG file)

% Find 1st threshold crossing (i.e. R-wave)
n = 1;
for i=1:(2 * samprate) % look for 2 seconds
     if((data(i) > threshold) & (data(i-1) < threshold)) % a threshold
crossing
         intbegin(n) = i;
         n=n+1;
         break;
     end
end

% Find all threshold crossings insisting that they be at least .4
% sec apart to avoid spurious small intervals due to noise
for i=1:M
     if(i > intbegin(n-1) + 0.4*samprate & data(i) > threshold & data(i-1) < threshold) % a threshold crossing
         intbegin(n) = i;
         n = n + 1;
     end
end

% Ignore 1st and last QRS complex to avoid problems (we will 'back up'.25 sec)
intbegin = intbegin(2:end-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trigav(data,samprate,intbegin)
%% Perform Triggered Averaging %%%%%%%%

num_aves = input('\nInput the number of triggered QRS intervals toaverage: '); % Input Number of Averages
if num_aves > length(intbegin)
     num_aves = length(intbegin);
end

disp(' ')
disp('Input the duration of the interval (secs) to be averaged. Thisinterval should be');
duration = input('slightly shorter than the average R-R interval (pulserate): '); % Input R-R duration
% 'back up' by 0.25 sec before R wave to show P & Q waves
intbegin = intbegin - floor(samprate/4);

% Find number of points in 1 cycle
npts = floor(duration*samprate);
time=(0:npts-1)/samprate;
tr_ave=zeros(size(time))';

% Take Average of num_aves Blocks of Data
for n = 1:num_aves
     tr_ave = tr_ave + data(intbegin(n):intbegin(n)+npts-1);
end
tr_ave = tr_ave/num_aves;

% Compute spectrum (spectral density)
fftmag = abs(fft(tr_ave)).^2/npts;
fftfr = samprate/npts*(0:npts-1);
ind = 2:floor(npts/2); % Indicies for plotting spectrum (ignore DC)

% Plot Results
figure
subplot(2,1,1),plot(time,tr_ave);
xlabel('Time (sec)'); ylabel('Voltage');
title(['Triggered Average of ',num2str(num_aves),' QRS Waveforms']);

subplot(2,1,2),plot(fftfr(ind),fftmag(ind))
xlabel('Frequency (Hz)'), ylabel('Magnitude')
set(gca,'TickLength',[0,0],'Xlim',[0,100])

disp('Hit a key to continue.........')
pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hrvar(data,samprate,intbegin)
% Perform Heart Rate Variability Analysis

close all
% Convert R-Wave indicies from sample numbers into secs
itimes = intbegin/samprate;

% Compute inter-beat intervals
interval = diff(itimes);

nintervals = length(interval);
itimes = itimes(1:nintervals);

figure
subplot(2,1,1)
plot(itimes,interval,'.')
title('Heart Rate Intervals');
xlabel('Beat Time (sec)'),ylabel('Interval (sec)')
subplot(2,1,2)
hist(interval)
xlabel('Interval (sec)'), ylabel('Count')

clc
disp(' ')
disp('Now the spectrum of this heart rate signal will be computed.')
disp('.................Hit a key to continue...............')
pause

% Compute spectrum (spectral density)
fftmag = abs(fft(interval)).^2/nintervals;

% Assume pts are evenly spaced at mean interval.
avghr=1/mean(interval);

% Multiply frequency vector by avg Heart rate to convert to "Hz"
fftfr = avghr/nintervals*(0:nintervals-1);

ind = 2:floor(nintervals/2); % Indicies for plotting spectrum (ignore DC)

subplot(2,1,1), plot(itimes,interval)
title('Heart Rate Intervals');
xlabel('Beat Time (sec)'),ylabel('Interval (sec)')
subplot(2,1,2), plot(fftfr(ind),fftmag(ind))
ylabel('Magnitude Spectrum'), xlabel('Frequency (Hz)')
xlims = get(gca,'XLim')

q2
pause
q3
pause

T = 0.25; % For 4 Hz samples
%npts = 512;
npts = floor(itimes(end)/T);
hrtime = (0:npts-1)*T; % An evenly spaced time vector w/ sample period T

n=2;
for i = 1:npts-1
     if(hrtime(i) >= itimes(n))
         n = n + 1;
     end
     if(hrtime(i+1) < itimes(n))
         hrate(i) = 2*T/interval(n-1);
     else
         hrate(i) = (hrtime(i+1) - itimes(n))/interval(n) +(itimes(n)-hrtime(i-1))/interval(n-1);
     end
end
hrate(1) = hrate(2);
hrate(npts) = hrate(npts-1); % Fill in these values to avoid problems
with unequal size arrays

% convert array into units of rate (see Berger et al.)
hrate = hrate * (1/T) / 2;

figure
subplot(2,1,1), plot(hrtime,hrate);
%plot(itimes,interval,hrtime,1./hrate*T*4)
title('Heart Rate computed at 4 Hz intervals');
xlabel('Time (sec)'), ylabel('Heart Rate (Hz)')

fftmag1 = abs(fft(hrate)).^2/npts;
fftfr1 = 1./(npts*T)*(0:npts-1); % 1/dur = 1/(npts * T sec/pt)
ind1 = 2:floor(npts/2); % Indicies for plotting spectrum (ignore DC)

subplot(2,1,2), plot(fftfr1(ind1),fftmag1(ind1))
set(gca,'TickLength',[0,0],'Xlim',xlims)
xlabel('Frequency (Hz)'), ylabel('Spectral Density')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q1
% Ask question 1
clc
disp('Choose:')
disp(' 1 for Triggered Average of ECG')
disp(' 2 for Heart Rate Variability Analysis')
disp(' 0 to Exit')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q2
% Ask question 2
clc
disp('The spectrum of the heart rate signal is shown in the Figure.')
disp('Note, however, that there are some problems with this spectrum!!')
disp(' ')
disp('The computer takes the heart-rate signal and subjects it to a');
disp('discrete-time Fourier transform, but this transform ASSUMES that');
disp('the samples of the signal are EVENLY SPACED in time. Yet, our');
disp('samples are not spaced evenly, but are rather spaced at intervals');
disp('of 1/beat (and the length of the beat clearly fluctuates!).');
disp('This operation thus results in a DISTORTED estimate of the spectrum');
disp('of the heart-rate. If we were using the results of this analysisin');
disp('a clinical setting, such distortion could be dangerous - ');
disp('let''s fix it!');
disp(' ');
disp('...............Hit a key to continue.............');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q3
% Ask question 3
clc
disp('We CAN compute a heart-rate signal that provides values that areevenly');
disp('spaced in time by using a method described by Berger et al (1986).');
disp('We''ll simply compute a heart-rate value every 0.25 sec (thisgives us');
disp('an evenly spaced signal with a 4 Hz sampling rate). Each heart-rate');
disp('value will be computed based on the distance between our time point');disp('and the closest R-waves (see Matlab code to see how this iscomputed.)');
disp(' ');
disp('The next plot will show the new heart-rate signal and the computed');disp('spectrum. The degree of heart-rate variability, or SinusArrhythmia,');
disp('is indicated by the amount of power in the spectrum (or the AREAunder');
disp('the spectral density function. The spectral density function is the');
disp('square of the spectral magnitude function.)');
disp(' ');
disp('...............Hit a key to continue.............');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 