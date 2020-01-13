import mqtt.*;
import processing.serial.*;
Serial serial;

MQTTClient client;

String applicationId = "microbit1"; //personal for your application
String portName = null;  //explicit port like COM1 or /dev/cu.usbmodem1422 for your application
String mqttHost = "127.0.0.1";
String mqttUser = "user";
String mqttPass = "pass";

//init, happens once
void setup()
{
  // get list
  String[] ports = Serial.list();
  if(ports.length == 0) {
      println("[DEBUG]  no serial ports found!");
      exit();
      return;
  }

  // no specific port specified take the first
  if(portName == null) {
    println("[DEBUG] available ports:");
    for(int i=0;i<ports.length;i++) {
      println("\t" + ports[i]);
    }
    portName = ports[0];
  }

  //
  println("[DEBUG] reading from: " + portName);

  serial = new Serial(this, portName, 115200);
  client = new MQTTClient(this);
  client.connect("mqtt://" + mqttUser + ":" + mqttPass + "@" + mqttHost, "processing");
  size(512, 512);
}

//main run loop called as often as possible
void draw()
{
  if(serial.available() > 0)
  {
    String s = serial.readStringUntil('\r');
    if (s != null) {
      String command = s.trim();
      client.publish("/out/" + applicationId, command);
      println("[DEBUG] out: " + command);
    }
  }
}

//keyboard event
void keyPressed() {
  if (key == ' ') {
    println("[DEBUG] space hit");
  }
}

//mqtt callbacks
void clientConnected() {
  println("[DEBUG] MQTT connected");
  client.subscribe("/in/" + applicationId);
}

void messageReceived(String topic, byte[] payload) {
  String command = new String(payload);
  println("[DEBUG] in: " + command);
  serial.write(command);
  serial.write("\n\r");
}

void connectionLost() {
  println("[DEBUG] MQTT connection lost");
}
