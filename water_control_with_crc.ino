#include <weather_control.h>

//SoftwareSerial swSerial(10, 12); // RX, TX
char cmd = 0;

int led = 13; // Pin 13 has an LED connected on most Arduino boards.
int state = -1;


void setup() {
	// initialize the digital pin as an output.
	pinMode(led, OUTPUT);     
	digitalWrite(led, LOW);
	// Open serial communications and wait for port to open:

	// set the data rate for the SoftwareSerial port
	// for HC-05 use 38400 when powering
	Serial.begin(38400);
    Serial.print("state: ");
    Serial.println(state);
    Serial.println("Ready!");
}

void loop() {
	// run over and over
	if (Serial.available()) {
		cmd = Serial.read();
		if(cmd == '1' && verifyCMD()) {             // Checks whether value of data is equal to 1
			if (state == 1)
				Serial.println("Already ON");
			else {
				Serial.println("Turning ON");
				state=1;
				turnOn();
				digitalWrite(led, HIGH);
			}
		}
		else if (cmd == '2' && verifyCMD()) {
			if (state == 2)
				Serial.println("Already OFF");
			else {
				Serial.println("Turning OFF");
				state=2;
				turnOff();
				digitalWrite(led, LOW);
			}
		}
		else if (cmd == 'H' && verifyCMD()) {
			if (state == 1)
				Serial.println("HELP INFO ON");
			else if (state == 2)
				Serial.println("HELP INFO OFF");
			else if (state == -1)
				Serial.println("HELP INFO RESET");
			else
				Serial.println("HELP INFO UNKNOWN");
		}
		else {
			// Un-verified command
			Serial.print("ERROR:");
			Serial.println(cmd);
		}
	}
	delay (100);
}


bool verifyCMD() {
	char crc;
	crc = random(0,127);
	Serial.println(crc);
	while (Serial.available() == 0) { } // make sure first byte is arrived

	if (Serial.read() == crc)
		return true;
	else
		return false;
}
