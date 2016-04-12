% Serial device class used to manage communication between arduino/matlab
% Not exactly necessary to do this as a class,
% just practice/experimenting with matlab classes....

classdef Serial_Dev
    % Serial_Dev: start and stop serial device communication
    % EX: uno = Serial_Dev(1);
    %     uno.stop();
    
    properties
        comPort
        serialFlag
        dev
    end
    
    methods
        % constructor
        function obj = Serial_Dev(port)
            % com port strings here are particular to Mac OS X,
            % Windows is 'COM1', 'COM2', etc.
            % Linux is '/dev/ttyUSB0', etc.
            if port == 1
                %obj.comPort = '/dev/tty.usbmodem1411';
                obj.comPort = '/dev/cu.usbmodem1411';
            elseif port == 2
                obj.comPort = '/dev/tty.usbmodem1421';
            end
            
            % setup/init/open serial object
            obj.serialFlag = 1;
            obj.dev = serial(obj.comPort);
            set(obj.dev,'DataBits',8);
            set(obj.dev,'StopBits',1);
            set(obj.dev,'BaudRate',9600);
            set(obj.dev,'Parity','none');
            fopen(obj.dev);
            
            % handshake btwn matlab & serial device
            a = 'b';
            while(a ~= 'a')
                a = fread(obj.dev,1,'uchar');
            end
            if(a == 'a')
                disp('serial read');
            end
            fprintf(obj.dev,'%c','a');
            mbox = msgbox('Serial Communication setup.'); uiwait(mbox);
            fscanf(obj.dev,'%u');
        end
    end
    
    methods (Static)
        % this must be called when you're done to properly close serial
        % EX: uno.stop();
        function serialFlag = stop()
            serialFlag = 0;
            clear
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            close all
            clc
            disp('Serial Port Closed')
        end
    end
end

