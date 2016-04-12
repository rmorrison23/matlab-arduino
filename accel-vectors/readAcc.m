% reads the accelerometer via serial port
% returns x,y,z vector
% usage: [gx gy gz] = readAcc(serialDevice)

function [gx, gy, gz] = readAcc(acc)

% notify serial device (accelerometer) ready-to-read
fprintf(acc.dev,'R');

% the order must agree with order in arduino sketch
reading(1) = fscanf(acc.dev,'%f');
reading(2) = fscanf(acc.dev,'%f');
reading(3) = fscanf(acc.dev,'%f');

gx = reading(1);
gy = reading(2);
gz = reading(3);
end