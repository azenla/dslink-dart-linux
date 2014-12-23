import "package:dslink/link.dart";

import "package:linux/cpu.dart";
import "package:linux/leds.dart";

void main() {
  var link = new DSLink("Linux", host: "rnd.iot-dsa.org");
  var ledsNode = link.createRootNode("LEDs");
  var cpusNode = link.createRootNode("CPUs");
  var leds = LED.list();
  var cpus = CPU.list();  

  for (var led in leds) {
    var node = ledsNode.createChild(led.deviceName);
    var brightnessNode = node.createChild("Brightness", value: led.brightness);
    node.createAction("SetBrightness", params: {
      "brightness": ValueType.INTEGER
    }, execute: (args) {
      led.brightness = args["brightness"].toInteger();
    });
    
    poller(() {
      brightnessNode.value = led.brightness;
    }).pollEverySecond();
    
    node.createChild("MaxBrightness", value: led.maxBrightness);
  }

  for (var cpu in cpus) {
    var cpuNode = cpusNode.createChild("CPU ${cpu.processor}");
    var loadNode = cpuNode.createChild("Load", value: cpu.getUsage());
    var modelNode = cpuNode.createChild("Model", value: cpu.modelName);

    poller(() {
      loadNode.value = cpu.getUsage();
    }).pollEverySecond();
  }
  
  link.connect().then((_) {
    print("Connected.");
  });
}
