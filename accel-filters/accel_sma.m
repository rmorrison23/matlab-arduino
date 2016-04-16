% accel_sma.m - create raw and moving-averaged filtered plots
%               from accelerometer readings

function accel_sma

% initialize a serial object
accel = Serial_Dev(1);

% figure
f = figure('Position',[0,0,900,400],...
    'Name','Accelerometer Vectors - Raw and Filtered','Visible','off');

% gif recording setup
gifHandle = guihandles(f);
gifHandle.firstFrame = true;
gifHandle.outFile = 'accel-sma.gif';
guidata(f,gifHandle);

% stop button (quits plotting)
quit = uicontrol('Style','pushbutton','String','Quit',...
    'Position',[840 15 50 40],...
    'Callback',@quit_Callback,...
    'UserData',1);

% slider (changes # of taps 1-10)
slide = uicontrol('Style','slider','Callback',@slide_callback,...
    'Position',[765,130,100,200],'Min',0,'Max',10,'SliderStep',[0.1,0.1],...
    'Value',0);

% display slider/tap value
slideVal = uicontrol('style','text','String','Taps = ',...
    'Position',[825,335,35,20],'FontSize',10,'FontWeight','bold');

tapVal = uicontrol('style','text','Position',[860,335,15,20],...
    'String','0','FontSize',10,'FontWeight','bold');

% display high, mid, low filteing states
range = uicontrol('style','text','String','No Filtering',...
    'Position',[15,100,75,40],...
    'FontSize',10,'FontWeight','normal','FontSize',15,...
    'ForegroundColor','blue','Visible','on');

movegui(f,'center');
f.Visible = 'on';

% stop loop/plot callback
    function quit_Callback(source,~)
        source.UserData = 0;
    end

% slider callback
    function slide_callback(source,~)
        taps = int32(source.Value);
        set(tapVal,'String',num2str(taps,'%.0f'),'Visible','on');
        
        if source.Value == 0
            set(range,'String','No Filtering','Visible','on');
        elseif source.Value == 5
            set(range,'String','Medium Filtering','Visible','on');
        elseif source.Value == 10
            set(range,'String','High Filtering','Visible','on');
        else
            set(range,'Visible','off');
        end
    end

% TO-DO: combine xyz readings into one matrix
buf_len = 100;
i = 1:buf_len;
xRaw = zeros(buf_len,1);
yRaw = zeros(buf_len,1);
zRaw = zeros(buf_len,1);
gxFilt = zeros(buf_len,1);
gyFilt = zeros(buf_len,1);
gzFilt = zeros(buf_len,1);
taps = 0;

while (quit.UserData == 1)
    
    % raw accelrometer readings
    raw_buf = readAcc(accel);
    
    % drop first values, append new values to end
    xRaw = [xRaw(2:end);raw_buf(1)];
    yRaw = [yRaw(2:end);raw_buf(2)];
    zRaw = [zRaw(2:end);raw_buf(3)];
    
    % apply filter to x,y,z
    gxFilt = [gxFilt(2:end);...
        mean(xRaw(buf_len:-1:buf_len-taps+1))];
    gyFilt = [gyFilt(2:end);...
        mean(yRaw(buf_len:-1:buf_len-taps+1))];
    gzFilt = [gzFilt(2:end);...
        mean(zRaw(buf_len:-1:buf_len-taps+1))];
    
    % raw x values
    subplot(2,1,1);
    %        plot(i,xRaw,'r',i,yRaw,'b',i,zRaw,'g','LineWidth',1.5);
    plot(i,xRaw,i,yRaw,i,zRaw,'LineWidth',1.25);
    axis([1,buf_len,-2,2]);
    xlabel('time');
    ylabel('Mag: XYZ accelerations');
    title('Raw Readings');
    
    % filtered x values
    subplot(2,1,2);
    %        plot(i,gxFilt,'r',i,gyFilt,'b',i,gzFilt,'g','LineWidth',2);
    plot(i,gxFilt,i,gyFilt,i,gzFilt,'LineWidth',1.25);
    axis([1,buf_len,-2,2]);
    xlabel('time');
    ylabel('Mag: XYZ accelerations');
    title('Simple Moving Average Filtered');
    
    drawnow;
    
    % gif recording
    img = frame2im(getframe(f));
    [imind,cm] = rgb2ind(img,256);
    
    % create on first iteration, append on subsequent ones
    if gifHandle.firstFrame
        imwrite(imind,cm,gifHandle.outFile,'gif','DelayTime',0,'loopcount',inf);
        gifHandle.firstFrame = false;
    else
        imwrite(imind,cm,gifHandle.outFile,'gif','DelayTime',0,'writemode','append');
    end
end

% turn off plot and shut-down serial communication
f.Visible = 'off';
accel.stop();

end