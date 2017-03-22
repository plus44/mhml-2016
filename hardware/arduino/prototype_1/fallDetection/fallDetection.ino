
#include <avr/io.h>
#include <avr/interrupt.h>
#include "MPU9250.h"
#include <SPI.h>
#include <Wire.h>


//const int cs =53;
//const int g = 100;
float rawData[100][3];
float magAcc[100];
float features[3];
int pointer;
MPU9250 myIMU

void getFeatures(float &features[3], float magAcc[100]){
  //float features[3];
  features[0] = 0;          //maen
  features[1] = magAcc[0];  //max
  features[2] = magAcc[0];  //min
  for int i=1;i<100;i++
  {
    meanAcc += magAcc[i];
    if(magAcc[i] >  features[1])   features[1] = magAcc[i];
    if(magAcc[i] <  features[2])   features[2] = magAcc[i];
  }
 // return features;
}

int accelerationMode(int x, int y, int z) {

  int acc;

  acc = sqrt(x * x + y * y + z * z);

  return acc;

}

void setup() {

  //Init I2C and Serial Comms
  wire.begin();
  Serial.begin(57600);

  //pinMode(cs, OUTPUT);
  //digitalWrite(cs, HIGH); // davekw7x: If it's low, the Wiznet chip corrupts the SPI bus
  byte c = myIMU.readByte(MPU9250_ADDRESS, WHO_AM_I_MPU9250);
  Serial.print("MPU9250 "); Serial.print("I AM "); Serial.print(c, HEX);
  Serial.print(" I should be "); Serial.println(0x71, HEX);

  if (c == 0x71)
  {
    myIMU.MPU9250SelfTest(myIMU.SelfTest);


    // Calibrate gyro and accelerometers, load biases in bias registers
    myIMU.calibrateMPU9250(myIMU.gyroBias, myIMU.accelBias);


    myIMU.initMPU9250();
    Serial.print("AK8963 "); Serial.print("I AM "); Serial.print(d, HEX);
    Serial.print(" I should be "); Serial.println(0x48, HEX);

    // Get magnetometer calibration from AK8963 ROM
    myIMU.initAK8963(myIMU.magCalibration);

  }
  else
  {
    Serial.print("Could not connect to MPU9250: 0x");
    Serial.println(c, HEX);
    while (1) ; // Loop forever if communication doesn't happen
  }

  pointer = 0;
}


void loop() {
  // On interrupt, check if data ready interrupt
  if (myIMU.readByte(MPU9250_ADDRESS, INT_STATUS) & 0x01)
  {
    myIMU.delt_t = millis() - myIMU.count;
    myIMU.readAccelData(myIMU.accelCount);  // Read the x/y/z adc values
    myIMU.getAres();
    myIMU.ax = (float)myIMU.accelCount[0] * myIMU.aRes; // - accelBias[0];
    myIMU.ay = (float)myIMU.accelCount[1] * myIMU.aRes; // - accelBias[1];
    myIMU.az = (float)myIMU.accelCount[2] * myIMU.aRes; // - accelBias[2];

    rawData[pointer][1] = myIMU.ax;
    rawData[pointer][2] = myIMU.ay;
    rawData[pointer][3] = myIMU.az;
    magAcc[pointer] = accelerationMode(myIMU.ax, myIMU.ay, myIMU.aZ)
    pointer++;

    if (pointer == 100)
    {
      getFeatures(features, magAcc);
    }
  }
}


int minFinder(int x, int y, int z) {

  //This function finds the minimum of 3 numbers

  if (x < y) {

    if (z < x) return z;
    else return x;

  } else {

    if (y < z) return y;
    else return z;
  }

}

/*
ISR(TIMER1_COMPA_vect) {

  ISRCounter++;

  digitalWrite(testPin, !digitalRead(testPin)); //Test with oscilloscope if interrupt is working correctly

  const float max_scale = 3; //Volts

  float zero = (max_scale * 1024 / 3.3) / 2; //3.3V is reference voltage of ADC

  //Analogue Conversion takes 100 microseconds

  //Read XYZ value from sensor: Raw Data
  //samples[pointer][0] = (analogRead(AnalogPin_X) - zero) * 50 / 27;
  //samples[pointer][1] = (analogRead(AnalogPin_Y) - zero) * 50 / 27;
  //samples[pointer][2] = (analogRead(AnalogPin_Z) - zero) * 50 / 27;

  samples[pointer][0] = (analogRead(AnalogPin_X) - 333) * 100 / 38;
  samples[pointer][1] = (analogRead(AnalogPin_Y) - 335) * 100 / 39;
  samples[pointer][2] = (analogRead(AnalogPin_Z) - 338) * 100 / 40;

  //0.174:3.3 = x:1024 1g in bits
  //1g = 54 --> *50/27 --> 1g = 100
  //samples[][] = k * 10^-2 g

  //Low pass filter for gravity
  ISRindex = pointer - 1;
  if (pointer == 0) ISRindex  = sampleSize - 1;

  gravity[pointer][0] = 0.9 * gravity[ISRindex][0] + 0.1 * samples[pointer][0];
  gravity[pointer][1] = 0.9 * gravity[ISRindex][1] + 0.1 * samples[pointer][1];
  gravity[pointer][2] = 0.9 * gravity[ISRindex][2] + 0.1 * samples[pointer][2];


  pointer++; //increment pointer

  if (pointer == sampleSize) pointer = 0; //reset pointer if it overflows array length



  if (ISRCounter >= 200) {

    ISRCounter = 200;

    int fallen1 = fallFinder_1();
    int fallen2 = fallFinder_2();
    int fallen3 = fallFinder_3(); //May not work
    int fallen4 = fallFinder_4();

    if (fallen1) {

      digitalWrite(pin_f_1, HIGH);

      Serial.println("fallen1");

    }
    if (fallen2) {

      digitalWrite(pin_f_2, HIGH);

    }

    if (fallen3) {

      Serial.println("fallen3");

    }

    if (fallen4) {

      digitalWrite(pin_f_4, HIGH);

    }

  }

}*/
