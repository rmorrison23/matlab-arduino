% accel_ema.m - create raw and exponential-averaged filtered plots
%               from accelerometer readings
function accel_ema

% initialize a serial object
accel = Serial_Dev(1);

% figure
f = figure('Position',[0,0,900,400],...
    'Name','Accelerometer Vectors - Raw and Filtered','Visible','off');

% gif recording setup
gifHandle = guihandles(f);
gifHandle.firstFrame = true;
gifHandle.outFile = 'accel-ema.gif';
guidata(f,gifHandle);

% stop button (stop plotting/serial comm)
quit = uicontrol('Style','pushbutton','String','Quit',...
    'Position',[790 15 100 25],...
    'Callback',@quit_Callback,...
    'UserData',1);

% slider (changes alpha 0-1)
slide = uicontrol('Style','slider','Callback',@slide_callback,...
    'Position',[765,130,100,200],'Min',0,'Max',1,'SliderStep',[0.10,0.10]);

% display alpha value
slideVal = uicontrol('style','text','Position',[815,335,75,20],...
    'FontSize',10,'FontWeight','bold');

% display high, mid, low alpha states
range = uicontrol('style','text','Position',[420,335,75,40],...
    'FontSize',10,'FontWeight','normal','FontSize',15,...
    'ForegroundColor','blue');

movegui(f,'center');
f.Visible = 'on';

% stop the loop/plot callback
    function quit_Callback(source,~)
        source.UserData = 0;
    end

% slider callback
    function slide_callback(source,~)
        alpha = source.Value;
        
        if alpha == 0.1;
            set(range,'String','High Filtering','Visible','on');
        elseif alpha == 0.5
            set(range,'String','Medium Filtering','Visible','on');
        elseif alpha == 1
            set(range,'String','No Filtering','Visible','on');
        else
            set(range,'Visible','off');
        end
    end

gFilt = zeros(1,3);
alpha = 0.1;

while (quit.UserData == 1)
    
    % raw accelrometer readings
    raw = readAcc(accel);
    
    % apply ema filter
    for i=1:3
        gFilt(i) = (1 - alpha) * gFilt(i) + alpha * raw(i);
    end
    
    subplot(1,2,1);
    cla;    %clear everything from current axis
    
    % plot x,y,z,r acceleration vectors
    line([0 raw(1)], [0 0], [0 0], 'Color', 'r', 'LineWidth', 2, 'Marker', 'o');
    line([0 0], [0 raw(2)], [0 0], 'Color', 'b', 'LineWidth', 2, 'Marker', 'o');
    line([0 0], [0 0], [0 raw(3)], 'Color', 'g', 'LineWidth', 2, 'Marker', 'o');
    line([0 raw(1)], [0 raw(2)], [0 raw(3)], 'Color', 'k', 'LineWidth', 2, 'Marker', 'o');
    
    limits = 1.5; %limit plot to +/- 1.5g in all directions
    axis([-limits limits -limits limits -limits limits]);
    axis square;
    grid on;
    xlabel('X Accel (g)');
    ylabel('Y Accel (g)');
    zlabel('Z Accel (g)');
    title('Raw Readings');
    
    subplot(1,2,2);
    cla;    %clear everything from the current axis
    
    % plot x,y,z,r acceleration vectors
    line([0 gFilt(1)], [0 0], [0 0], 'Color', 'r', 'LineWidth', 2, 'Marker', 'o');
    line([0 0], [0 gFilt(2)], [0 0], 'Color', 'b', 'LineWidth', 2, 'Marker', 'o');
    line([0 0], [0 0], [0 gFilt(3)], 'Color', 'g', 'LineWidth', 2, 'Marker', 'o');
    line([0 gFilt(1)], [0 gFilt(2)], [0 gFilt(3)], 'Color', 'k', 'LineWidth', 2, 'Marker', 'o');
    
    limits = 1.5; %limit plot to +/- 1.5g in all directions
    axis([-limits limits -limits limits -limits limits]);
    grid on;
    axis square;
    xlabel('X Accel (g)')
    ylabel('Y Accel (g)')
    zlabel('Z Accel (g)')
    title('EMA-Filtered');
    
    % print alpha value from slider
    set(slideVal,'String',['alpha=',num2str(alpha,'%.3f')]);
    
    drawnow;
    
    % setup gif recording
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