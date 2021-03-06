% VNA 2017 test script.
% This script tests the TIME command, which is meant to get the analyzer
% to make a measurement at one frequency, and instead of downsampling to DC,
% it just sends the data back in the variable, "voltage".
% Rob Frohne, May 2017.

clc; clear;

fMin = 10e6; % Note:  We need to figure out what the aliased frequency is
% and make sure it doesn't interfere with our measurement even with the LPF.

% Load the package
pkg load instrument-control
% Check if serial support exists
if (exist("serial") != 3)
  disp("No Serial Support");
endif
% Instantiate the Serial Port
% Naturally, set the COM port # to match your device
% Use this crazy notation for any COM port number: 1 - 255
%s1 = serial("/dev/pts/2");
s1 = serial("/tmp/ttyDUMMY"); % $ 
%s1 = serial("/dev/ttyACM0"); % This needs debugged.  It is missing data.
pause(1); % Wait a second as it takes some ports a while to wake up
% Set the port parameters
set(s1,'baudrate', 115200);
set(s1,'bytesize', 8);
set(s1,'parity', 'n');
set(s1,'stopbits', 1);
set(s1,'timeout', 255); % 12.3 Seconds as an example here
% Optional commands, these can be 'on' or 'off'
%set(s1, 'requesttosend', 'on');
% Sets the RTS line
%set(s1, 'dataterminalready', 'on'); % Sets the DTR line
% Optional - Flush input and output buffers
srl_flush(s1);
%string_to_send = strcat("^SAMPLERATE,","$\n");
%srl_write(s1,string_to_send);
%Fs = str2num(ReadToTermination(s1,10));
%N = str2num(ReadToTermination(s1,10));
%F_IF = str2num(ReadToTermination(s1,10));
F_IF = 155;
N = 3840/2;
Fs=8000;  
T = 1/Fs;
%srl_flush(s1);
string_to_send = strcat("^TIME,",num2str(uint64(fMin)),"$\n");
srl_write(s1,string_to_send);
ref(1,:) = str2num(ReadToTermination(s1,10));
pause(1);
meas(1,:)= str2num(ReadToTermination(s1,10));
ref=ref-2^13;
meas=meas-2^13;
t=0:T:(N-1)*T;
figure(1)
plot(t,ref);
hold on
plot(t,meas,"linewidth",1)
legend('ref','meas')
title('Results')
xlabel('Time (s)')
figure(2)
f=-1/2/T:1/N/T:1/2/T-1/N/T;
Ref = fft(hanning(length(ref))'.*ref);
Meas = fft(hanning(length(meas))'.*meas);
%Ref(F_IF*N/Fs+1)
%Meas(F_IF*N/Fs+1)
H1 = abs(Meas(round(F_IF*N/Fs+1))/Ref(round(F_IF*N/Fs+1)))
H3 = abs(Meas(round(3*F_IF*N/Fs+1))/Ref(round(3*F_IF*N/Fs+1)))
H5 = abs(Meas(round(5*F_IF*N/Fs+1))/Ref(round(5*F_IF*N/Fs+1)))
H7 = abs(Meas(round(7*F_IF*N/Fs+1))/Ref(round(7*F_IF*N/Fs+1)))
%plot(f,abs(fftshift(Ref)),"linewidth",1)
xlabel('frequency (Hz)')
title('Reference Response');
figure(3)
plot(f,abs(fftshift(Meas)),"linewidth",1)
xlabel('frequency (Hz)')
title('Measured Response');\
figure(4)
plot(f,20*log10(abs(fftshift(Ref))),"linewidth",1)
xlabel('frequency (Hz)')
title('Reference Response');
figure(5)
plot(f,20*log10(abs(fftshift(Meas))),"linewidth",1)
xlabel('frequency (Hz)')
title('Measured Response');
figure(6)
plot(t,ref)
title('Reference Channel')
xlabel('Time (s)')
figure(7)
plot(t,meas)
title('Measured Channel')
xlabel('Time (s)')
% Finally, Close the port
fclose(s1);
