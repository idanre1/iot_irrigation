#include <SoftwareSerial.h>


SoftwareSerial swSerial(10, 12); // RX, TX
char cmd = 0;
void setup() {
// Open serial communications and wait for port to open:
//    Serial.begin(115200);
//    Serial.println("Ready!");

    // set the data rate for the SoftwareSerial port
    // for HC-05 use 38400 when powering
    swSerial.begin(38400);
//    swSerial.println("Ready!");
//    swSerial.println("GO");
}

void loop() {
    // run over and over
    if (swSerial.available()) {
        cmd = swSerial.read();
        swSerial.println(cmd);
        if(cmd == '1')              // Checks whether value of data is equal to 1
            swSerial.println("ON");
        else if (cmd == '0')
            swSerial.println("OFF");
        else
            swSerial.println("ERROR");

//        if (Serial.available())
//        swSerial.write(Serial.read());
    }
}
