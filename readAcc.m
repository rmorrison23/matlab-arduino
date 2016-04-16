% reads the accelerometer via serial port
% returns x,y,z vector
% usage: raw = readAcc(serialDevice)

function readings = readAcc(acc)

% notify serial device (accelerometer) ready-to-read
fprintf(acc.dev,'R');

% the order must agree with order in arduino sketch
readings(1) = fscanf(acc.dev,'%f');
readings(2) = fscanf(acc.dev,'%f');
readings(3) = fscanf(acc.dev,'%f');

end