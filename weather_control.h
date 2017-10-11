//-----------------------------------------------------------------------------
// Includes
//-----------------------------------------------------------------------------
// This is the library for the TB6612 that contains the class Motor and all the
// functions
#include <SparkFun_TB6612.h>
#include <SoftwareSerial.h>

// Pins for all inputs, keep in mind the PWM defines must be on PWM pins
// the default pins listed are the ones used on the Redbot (ROB-12097) with
// the exception of STBY which the Redbot controls with a physical switch
#define AIN1 2
#define AIN2 4
#define PWMA 5

#define BIN1 7
#define BIN2 8
#define PWMB 6

#define STBY 9


//-----------------------------------------------------------------------------
// Schmatics:
//-----------------------------------------------------------------------------
// D7:   Act as AIN1. Output thresholdPin(D3) via LP_filter will be connected to that input.
// D6:   Act as AIN0. Vin for sampled signal
// AREF: Connect with capacitor to 5V
// Vin:  ADCPIN aka Vin. Currently A0 connected to level shifter. A1 is connected to 1.8V
// LED:  When comparator trigger is latched, led is high
//-----------------------------------------------------------------------------
// Pins for all inputs, keep in mind the PWM defines must be on PWM pins
// the default pins listed are the ones used on the Redbot (ROB-12097) with
// the exception of STBY which the Redbot controls with a physical switch
#define AIN1 2
#define AIN2 4
#define PWMA 5

#define BIN1 7
#define BIN2 8
#define PWMB 6

#define STBY 9

//-----------------------------------------------------------------------------
// Defines and Typedefs
//-----------------------------------------------------------------------------
#define SOLENOID_DELAY 40 // [mSec]

//-----------------------------------------------------------------------------
// Global Constants
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Function Prototypes
//-----------------------------------------------------------------------------
void turnOn(void);
void turnOff(void);
bool verifyCMD();

//-----------------------------------------------------------------------------
// Global Variables
//-----------------------------------------------------------------------------
//extern volatile  boolean wait;
//extern          uint16_t waitDuration;
