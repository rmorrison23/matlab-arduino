% accelVectors.m - inits serial, creates GUI/plot, creates gif
function accelVectors

% initialize a serial object
accel = Serial_Dev(1);

% initialize figure for vector plots
f = figure('Visible','off');
handleList = guihandles(f);
handleList.firstFrame = true;
guidata(f,handleList);
% ax = axes('box','on'); %enclose the plot in axes limit

% the stop button
quit = uicontrol('Style','pushbutton','String','Quit',...
    'Position',[450 0 100 25],...
    'Callback',@quit_Callback,...
    'UserData',1);

% for displaying values in side of plot (optional)
read1 = uicontrol('style','text');
read2 = uicontrol('style','text');

% settings for plot
f.Units = 'normalized';
quit.Units = 'normalized';
f.Name = 'Accelerometer Vectors';
movegui(f,'center');
f.Visible = 'on';

% callback to stop the loop/plot
    function quit_Callback(source,eventdata)
        quit.UserData = 0;
    end

while (quit.UserData == 1)
    
    [gx,gy,gz] = readAcc(accel);
    
    % display read-values in side of plot
    vars = {sprintf('%s','gX:');sprintf('%s','gY:');sprintf('%s','gZ:')};
    readings = {num2str(gx,'%.2f');num2str(gy,'%.2f');num2str(gz,'%.2f')};
    set(read1,'String',vars,'Position',[465 195 30 80]);
    set(read2,'String',readings,'Position',[487 195 45 80]);
    
    cla;    %clear everything from the current axis
    
    %plot X acceleration vector
    line([0 gx], [0 0], [0 0], 'Color', 'r', 'LineWidth', 2, 'Marker', 'o');
    
    %plot Y acceleration vector
    line([0 0], [0 gy], [0 0], 'Color', 'b', 'LineWidth', 2, 'Marker', 'o');
    
    %plot Z acceleration vector
    line([0 0], [0 0], [0 gz], 'Color', 'g', 'LineWidth', 2, 'Marker', 'o');
    
    % resultant
    line([0 gx], [0 gy], [0 gz], 'Color', 'k', 'LineWidth', 2, 'Marker', 'o');
    
    limits = 1.5; %limit plot to +/- 1.5g in all directions
    axis([-limits limits -limits limits -limits limits]);
    grid on;
    xlabel('X Accel (g)')
    ylabel('Y Accel (g)')
    zlabel('Z Accel (g)')
    title('LSM303DLHC Accelerometer Readings');
    legend('gx','gy','gz','r');
    drawnow;
    
    % setup gif recording
    frame = getframe(1);
    img = frame2im(frame);
    [imind,cm] = rgb2ind(img,256);
    outfile = 'testgif.gif';
    
    % create on first iteration, append on subsequent ones
    if handleList.firstFrame
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
        handleList.firstFrame = false;
    else
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
    end
end

% turn off plot and shut-down serial communication
f.Visible = 'off';
accel.stop();

end