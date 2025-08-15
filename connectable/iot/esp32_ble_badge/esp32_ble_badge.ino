/*
  ESP32 BLE Badge - รับข้อความไม่เกิน 20 ตัวอักษรจากมือถือ และพิมพ์ออก Serial
  ใช้ UUID ให้ตรงกับแอป:
    Service:      6e400001-b5a3-f393-e0a9-e50e24dcca9e
    Characteristic: 6e400003-b5a3-f393-e0a9-e50e24dcca9e (Write Without Response)
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID        "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
bool deviceConnected = false;

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) { deviceConnected = true; }
  void onDisconnect(BLEServer* pServer) { deviceConnected = false; }
};

class WriteCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* c) {
    std::string value = c->getValue();
    if (value.length() == 0) return;
    // ตัดให้ไม่เกิน 20 ตัวอักษร (MTU ปกติ)
    if (value.length() > 20) value = value.substr(0, 20);
    Serial.print("Received: ");
    Serial.println(value.c_str());
    // TODO: แสดงบน e-paper/LED matrix ตามฮาร์ดแวร์ของคุณ
  }
};

void setup() {
  Serial.begin(115200);
  BLEDevice::init("ConnectAble Badge");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE_NR | BLECharacteristic::PROPERTY_WRITE
  );
  pCharacteristic->setCallbacks(new WriteCallbacks());
  pService->start();

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();
  Serial.println("BLE Badge ready.");
}

void loop() {
  delay(1000);
}
