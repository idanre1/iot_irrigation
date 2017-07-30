#include <weather_control.h>

SoftwareSerial swSerial(10, 12); // RX, TX
char cmd = 0;

int led = 13; // Pin 13 has an LED connected on most Arduino boards.
int state = -1;

void setup() {
	// initialize the digital pin as an output.
	pinMode(led, OUTPUT);     
	digitalWrite(led, LOW);
	// Open serial communications and wait for port to open:
//	Serial.begin(115200);
//	Serial.println("Ready!");

	// set the data rate for the SoftwareSerial port
	// for HC-05 use 38400 when powering
	swSerial.begin(38400);
//    swSerial.println("Ready!");
//	swSerial.println("GO");
}

void loop() {
	// run over and over
	if (swSerial.available()) {
		cmd = swSerial.read();
//		swSerial.println(cmd);
		if(cmd == '1') {             // Checks whether value of data is equal to 1
			if (state == 1)
				swSerial.println("Already ON");
			else {
				swSerial.println("Turning ON");
				turnOn();
				state=1;
				digitalWrite(led, HIGH);
			}
		}
		else if (cmd == '2')
			if (state == 2)
				swSerial.println("Already OFF");
			else {
				swSerial.println("Turning OFF");
				turnOff();
				state=2;
				digitalWrite(led, LOW);
			}
		else
			swSerial.println("ERROR");

//		if (Serial.available())
//		swSerial.write(Serial.read());
	}
}