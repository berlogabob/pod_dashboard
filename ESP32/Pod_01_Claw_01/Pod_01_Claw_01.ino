#include <ESP32Servo.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// ==================== Wi-Fi СЕТИ ====================
struct WiFiNetwork {
  const char* ssid;
  const char* password;
};

WiFiNetwork networks[] = {
  {"MEO-2hzF96460", "FpxA9bv8"},      // домашняя
  {"Nothing32", "212855625"}          // hotspot
};
const int numNetworks = 2;

// ==================== Firebase ====================
#define FIREBASE_HOST "booking-ee47f-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "m3uCFaiui2EXuQdpZGuuIgwgarKXH5lojbhUgF5b"

const String device_id = "Pod_01_Claw_01";
const String basePath = "/devices/" + device_id + "/";

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ==================== Пины ====================
const int servoPin = 13;
const int limitPin = 14;  // NC: HIGH = pressed

Servo clawServo;

// ==================== Настраиваемые переменные из Firebase ====================
int stop_adjust = 0;           // по умолчанию 0, подстрой под свой серво (например 6)
int opening_time_sec = 5;      // по умолчанию 5 сек
int closing_time_sec = 5;      // по умолчанию 5 сек

// ==================== Состояние ====================
int lock_state = 0;
bool last_limit_pressed = false;
int open_cycles = 0;
unsigned long process_start = 0;

void setup() {
  Serial.begin(115200);

  pinMode(limitPin, INPUT_PULLUP);
  clawServo.attach(servoPin);
  applyStop();
  delay(500);
  applyStop();

  // Wi-Fi
  bool connected = false;
  for (int i = 0; i < numNetworks; i++) {
    Serial.print("Trying WiFi: ");
    Serial.println(networks[i].ssid);
    WiFi.begin(networks[i].ssid, networks[i].password);
    unsigned long start = millis();
    while (millis() - start < 15000) {
      if (WiFi.status() == WL_CONNECTED) {
        Serial.println("Connected to " + String(networks[i].ssid));
        connected = true;
        break;
      }
      delay(500);
      Serial.print(".");
    }
    if (connected) break;
  }

  if (!connected) {
    Serial.println("No WiFi. Retry later...");
    return;
  }

  // Firebase
  config.database_url = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Создаём пути
  ensurePath("lock_state", 0);
  ensurePath("limit_switch", 0);
  ensurePath("open_cycles", 0);
  ensurePath("stop_adjust", 0);
  ensurePath("opening_time_sec", 5);
  ensurePath("closing_time_sec", 5);

  // Читаем начальные значения
  int val;
  if (getFBInt("lock_state", val)) lock_state = val;
  if (getFBInt("open_cycles", val)) open_cycles = val;
  if (getFBInt("stop_adjust", val)) stop_adjust = val;
  if (getFBInt("opening_time_sec", val)) opening_time_sec = val;
  if (getFBInt("closing_time_sec", val)) closing_time_sec = val;

  Serial.println("Initial lock_state: " + String(lock_state));
  Serial.println("stop_adjust: " + String(stop_adjust));
  Serial.println("opening_time_sec: " + String(opening_time_sec));
  Serial.println("closing_time_sec: " + String(closing_time_sec));
  applyStop();
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    delay(10000);
    ESP.restart();
  }

  // Чтение состояния и настроек
  static unsigned long last_read = 0;
  if (millis() - last_read > 2000) {
    int fb_state;
    if (getFBInt("lock_state", fb_state)) {
      if (fb_state >= 0 && fb_state <= 3 && fb_state != lock_state) {
        lock_state = fb_state;
        if (lock_state == 1 || lock_state == 3) {
          process_start = millis();
          Serial.println("Start rotation, state = " + String(lock_state));
        }
      }
    }

    // Чтение настроек
    int new_val;
    if (getFBInt("stop_adjust", new_val) && new_val != stop_adjust) {
      stop_adjust = new_val;
      Serial.println("New stop_adjust = " + String(stop_adjust));
      applyStop();
    }
    if (getFBInt("opening_time_sec", new_val) && new_val != opening_time_sec) {
      opening_time_sec = new_val;
      Serial.println("New opening_time_sec = " + String(opening_time_sec));
    }
    if (getFBInt("closing_time_sec", new_val) && new_val != closing_time_sec) {
      closing_time_sec = new_val;
      Serial.println("New closing_time_sec = " + String(closing_time_sec));
    }

    last_read = millis();
  }

  // Лимит-свитч
  bool current_pressed = (digitalRead(limitPin) == HIGH);
  setFBInt("limit_switch", current_pressed ? 1 : 0);

  // Отслеживание отжатия
  if (last_limit_pressed && !current_pressed) {
    open_cycles++;
    setFBInt("open_cycles", open_cycles);
    Serial.println("Limit released → open_cycles = " + String(open_cycles));
  }
  last_limit_pressed = current_pressed;

  // Управление серво
  if (lock_state == 3) {  // closing
    Serial.println("Closing started (CW)");
    rotateCW();
    if (current_pressed) {
      localStopAndClosed();
    } else if (millis() - process_start >= closing_time_sec * 1000UL) {
      localStopAndOpen();
    }
  }
  else if (lock_state == 1) {  // opening
    Serial.println("Opening started (CCW)");
    rotateCCW();
    if (millis() - process_start >= opening_time_sec * 1000UL) {
      localStopAndOpen();
    }
  }
  else {
    applyStop();
  }

  // Timestamp
  static unsigned long last_ts = 0;
  if (millis() - last_ts > 10000) {
    setFBTimestamp("timestamp");
    last_ts = millis();
  }

  delay(50);
}

// ==================== Функции ====================
void applyStop() {
  clawServo.write(90 + stop_adjust);
}

void rotateCW() { clawServo.write(0); }      // поменяй на 180 если направление обратное
void rotateCCW() { clawServo.write(180); }

bool getFBInt(const String& path, int& value) {
  String full = basePath + path;
  if (Firebase.RTDB.getInt(&fbdo, full.c_str(), &value)) {
    return true;
  }
  Serial.println("get failed: " + path);
  return false;
}

bool setFBInt(const String& path, int value) {
  String full = basePath + path;
  if (Firebase.RTDB.setInt(&fbdo, full.c_str(), value)) {
    Serial.println("set OK: " + path + " = " + String(value));
    return true;
  } else {
    Serial.println("set FAILED: " + path + " error: " + fbdo.errorReason());
    return false;
  }
}

void ensurePath(const String& path, int defaultVal) {
  int val;
  if (!getFBInt(path, val)) {
    setFBInt(path, defaultVal);
  }
}

void setFBTimestamp(const String& path) {
  String full = basePath + path;
  unsigned long ts = millis() / 1000;
  if (Firebase.RTDB.setInt(&fbdo, full.c_str(), ts)) {
    Serial.println("timestamp updated");
  }
}

void localStopAndClosed() {
  applyStop();
  lock_state = 0;
  open_cycles = 0;
  setFBInt("lock_state", 0);
  setFBInt("open_cycles", 0);
  Serial.println("LOCALLY CLOSED → state 0, cycles reset");
}

void localStopAndOpen() {
  applyStop();
  lock_state = 2;
  setFBInt("lock_state", 2);
  Serial.println("TIMEOUT → state 2 (open)");
}
