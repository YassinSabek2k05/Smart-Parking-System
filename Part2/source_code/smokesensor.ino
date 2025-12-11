// 1. PIN DEFINITIONS
const int smokeSensorPin = A0;  // Analog input from MQ-2 Sensor
const int fpgaTriggerPin = 2;   // Output to FPGA (Through Voltage Divider!)

// 2. THRESHOLD SETTING
// Open Serial Monitor to see your specific values. 
// Set this number slightly higher than your "Clean Air" value.
const int smokeThreshold = 100; 

void setup() {
  pinMode(fpgaTriggerPin, OUTPUT);
  Serial.begin(9600); // For debugging
}

void loop() {
  // 1. Read the Sensor
  int sensorValue = analogRead(smokeSensorPin);

  // 2. Debugging (Optional: View this in Serial Monitor)
  Serial.print("Smoke Level: ");
  Serial.print(sensorValue);

  // 3. Logic Check
  if (sensorValue > smokeThreshold) {
    Serial.println(" | STATUS: FIRE! (Sending Signal)");
    digitalWrite(fpgaTriggerPin, HIGH); // Send 5V (Becomes 3.3V at FPGA)
    delay(3000);
  } else {
    Serial.println(" | STATUS: Safe");
    digitalWrite(fpgaTriggerPin, LOW);  // Send 0V
  }

  // 4. THE DELAY
  // This slows down the checking to 10 times a second.
  // It prevents the signal from jittering if the smoke level is right on the edge.
  delay(100); 
}