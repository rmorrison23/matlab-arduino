#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>

Adafruit_LSM303_Accel_Unified accel = Adafruit_LSM303_Accel_Unified(54321);

// 0.101971621g = 1m/s^2
const float scaleG = 0.101971621;

int mode = -1;
float accelRead = 0;

void setup() { 
  Serial.begin(9600);
  accel.begin();
  // check serial communication 
  Serial.println('a');
  char a = 'b';
  while(a != 'a') {
    a = Serial.read();
  }
}

void loop() {
  if(Serial.available() > 0) {
    mode = Serial.read();
    if(mode == 'R') {
      sensors_event_t accelEvent; 
      accel.getEvent(&accelEvent);
      accelRead = accelEvent.acceleration.x * scaleG;
      Serial.println(accelRead);
      accelRead = accelEvent.acceleration.y * scaleG;
      Serial.println(accelRead);
      accelRead = accelEvent.acceleration.z * scaleG;
      Serial.println(accelRead);
    }
    delay(20);
  }
}
