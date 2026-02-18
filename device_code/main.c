/*
 * SafeNeck – Particle Boron 404X Firmware
 * ========================================
 * Hardware:
 *   • Particle Boron 404X  (cellular connectivity)
 *   • Adafruit BNO085 9-DOF IMU  (I2C – fall detection)
 *   • Adafruit Mini GPS PA1010D   (I2C – STEMMA QT / Qwiic)
 *
 * Behaviour:
 *   1. Reads GPS coordinates every PUBLISH_INTERVAL seconds and publishes
 *      them to the Particle Cloud event "safeneck/location".
 *   2. Continuously monitors the BNO085 accelerometer for sudden
 *      free-fall → impact patterns. When a fall is detected it
 *      immediately publishes a "safeneck/fall" event.
 *   3. Reports battery level alongside every location publish.
 *   4. A Particle Cloud webhook forwards every event to the Firebase
 *      Realtime Database for the companion Flutter app to consume.
 *
 * Wiring (all via STEMMA QT / Qwiic I2C daisy-chain):
 *   Boron SDA  → BNO085 SDA  → GPS SDA
 *   Boron SCL  → BNO085 SCL  → GPS SCL
 *   Boron 3V3  → BNO085 VIN  → GPS VIN
 *   Boron GND  → BNO085 GND  → GPS GND
 *
 * Build with Particle Device OS (compile as C++ – Particle toolchain).
 * Rename to main.ino or main.cpp for the Particle CLI if needed.
 * -----------------------------------------------------------------------*/

#include "Particle.h"
#include <Wire.h>
#include <math.h>

/* ── Feature flags ─────────────────────────────────────────────────── */
SYSTEM_MODE(AUTOMATIC);            /* auto-connect cellular             */
SYSTEM_THREAD(ENABLED);            /* non-blocking system thread        */

/* ── Configuration ─────────────────────────────────────────────────── */
#define PUBLISH_INTERVAL_SEC   30  /* seconds between location publishes */
#define FALL_COOLDOWN_SEC      60  /* ignore repeat fall alerts          */
#define GPS_I2C_ADDR           0x10  /* PA1010D default I2C address      */
#define BNO085_I2C_ADDR        0x4A  /* BNO085 default I2C address       */
#define FALL_ACCEL_THRESHOLD   2.5   /* g – spike that counts as impact  */
#define FREEFALL_THRESHOLD     0.4   /* g – below this is free-fall      */
#define GPS_READ_BUFFER        255

/* ── Global state ──────────────────────────────────────────────────── */
unsigned long lastPublishMs    = 0;
unsigned long lastFallAlertMs  = 0;

double gpsLat   = 0.0;
double gpsLon   = 0.0;
float  gpsSpeed = 0.0;
bool   gpsFix   = false;

float  accelX = 0.0, accelY = 0.0, accelZ = 0.0;
float  accelMagnitude = 1.0;

bool   fallDetected    = false;
bool   inFreeFall      = false;
unsigned long freeFallStart = 0;

char   publishBuf[256];

/* ── Forward declarations ──────────────────────────────────────────── */
void  readGPS();
void  parseNMEA(const char *sentence);
double nmeaToDecimal(const char *raw, char hemisphere);
void  readBNO085();
void  checkFall();
void  publishLocation();
void  publishFallAlert();
float getBatteryLevel();

/* ─────────────────────────────────────────────────────────────────────
 *  SETUP
 * ───────────────────────────────────────────────────────────────────── */
void setup() {
    Serial.begin(115200);
    Wire.begin();
    delay(1000);

    /* ── Initialise BNO085 ──────────────────────────────────────────
     *  The BNO085 needs a "set feature command" to enable the
     *  accelerometer report.  A minimal soft-reset + enable sequence
     *  is sent over I2C.  For a production build swap this out for
     *  Adafruit's BNO08x library; here we use raw I2C for clarity.
     * ────────────────────────────────────────────────────────────── */
    Wire.beginTransmission(BNO085_I2C_ADDR);
    Wire.write(0x01);            /* product-id request (wake sensor)   */
    Wire.endTransmission();
    delay(300);

    /* Enable accelerometer report at 50 Hz (20 ms interval).
     * SHTP "Set Feature Command" for report 0x01 (accelerometer).    */
    uint8_t enableAccel[] = {
        0x15, 0x00,              /* length (LSB, MSB)                  */
        0x02,                    /* channel: control                   */
        0x00,                    /* sequence                           */
        0xFD,                    /* Set Feature Command                */
        0x01,                    /* report id: accelerometer           */
        0x00, 0x00,              /* feature flags                      */
        0x00, 0x00,              /* change sensitivity                 */
        0x20, 0x4E, 0x00, 0x00  /* report interval 20 000 µs (50 Hz) */
    };
    Wire.beginTransmission(BNO085_I2C_ADDR);
    Wire.write(enableAccel, sizeof(enableAccel));
    Wire.endTransmission();
    delay(100);

    /* ── Initialise GPS (PA1010D) ──────────────────────────────────
     *  Send PMTK command to set update rate to 1 Hz and enable
     *  only GGA + RMC sentences to reduce I2C traffic.
     * ────────────────────────────────────────────────────────────── */
    const char *pmtkRMCGGA = "$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n";
    Wire.beginTransmission(GPS_I2C_ADDR);
    Wire.write((const uint8_t *)pmtkRMCGGA, strlen(pmtkRMCGGA));
    Wire.endTransmission();
    delay(100);

    const char *pmtk1Hz = "$PMTK220,1000*1F\r\n";
    Wire.beginTransmission(GPS_I2C_ADDR);
    Wire.write((const uint8_t *)pmtk1Hz, strlen(pmtk1Hz));
    Wire.endTransmission();
    delay(100);

    Serial.println("[SafeNeck] Setup complete – sensors initialised.");
}

/* ─────────────────────────────────────────────────────────────────────
 *  LOOP  –  runs continuously
 * ───────────────────────────────────────────────────────────────────── */
void loop() {
    /* 1.  Read sensors ------------------------------------------------ */
    readGPS();
    readBNO085();

    /* 2.  Fall detection ---------------------------------------------- */
    checkFall();
    if (fallDetected) {
        unsigned long now = millis();
        if ((now - lastFallAlertMs) > (FALL_COOLDOWN_SEC * 1000UL)) {
            publishFallAlert();
            lastFallAlertMs = now;
        }
        fallDetected = false;
    }

    /* 3.  Periodic location publish ----------------------------------- */
    unsigned long now = millis();
    if ((now - lastPublishMs) > (PUBLISH_INTERVAL_SEC * 1000UL)) {
        publishLocation();
        lastPublishMs = now;
    }

    delay(20);  /* ~50 Hz sensor loop */
}

/* ─────────────────────────────────────────────────────────────────────
 *  GPS  –  read NMEA sentences from PA1010D over I2C
 * ───────────────────────────────────────────────────────────────────── */
void readGPS() {
    char buf[GPS_READ_BUFFER + 1];
    uint8_t idx = 0;

    Wire.requestFrom(GPS_I2C_ADDR, GPS_READ_BUFFER);
    while (Wire.available() && idx < GPS_READ_BUFFER) {
        char c = Wire.read();
        if (c == '\n' || c == '\r') {
            if (idx > 0) {
                buf[idx] = '\0';
                parseNMEA(buf);
                idx = 0;
            }
        } else if (c != 0x0A && c != 0xFF) {   /* skip padding bytes */
            buf[idx++] = c;
        }
    }
}

/* Parse a $GPRMC or $GPGGA sentence for lat/lon/speed ─────────────── */
void parseNMEA(const char *sentence) {
    if (strstr(sentence, "$GPRMC") == sentence ||
        strstr(sentence, "$GNRMC") == sentence) {
        /*  $GPRMC,time,status,lat,N/S,lon,E/W,speed,...
         *  fields[0]=id  [1]=time  [2]=A/V  [3]=lat  [4]=N/S
         *           [5]=lon [6]=E/W [7]=speed                        */
        char copy[GPS_READ_BUFFER + 1];
        strncpy(copy, sentence, GPS_READ_BUFFER);
        copy[GPS_READ_BUFFER] = '\0';

        char *fields[15];
        int   fi = 0;
        char *tok = strtok(copy, ",");
        while (tok && fi < 15) {
            fields[fi++] = tok;
            tok = strtok(NULL, ",");
        }

        if (fi >= 8 && fields[2][0] == 'A') {
            gpsLat   = nmeaToDecimal(fields[3], fields[4][0]);
            gpsLon   = nmeaToDecimal(fields[5], fields[6][0]);
            gpsSpeed = atof(fields[7]) * 1.852;  /* knots → km/h     */
            gpsFix   = true;
        } else {
            gpsFix = false;
        }
    }
}

/* Convert NMEA ddmm.mmmm → decimal degrees ───────────────────────── */
double nmeaToDecimal(const char *raw, char hemisphere) {
    double val   = atof(raw);
    int    deg   = (int)(val / 100);
    double min   = val - (deg * 100);
    double dec   = deg + (min / 60.0);
    if (hemisphere == 'S' || hemisphere == 'W') dec = -dec;
    return dec;
}

/* ─────────────────────────────────────────────────────────────────────
 *  BNO085  –  read accelerometer via I2C (SHTP protocol, simplified)
 * ───────────────────────────────────────────────────────────────────── */
void readBNO085() {
    uint8_t header[4];
    Wire.requestFrom(BNO085_I2C_ADDR, 4);
    if (Wire.available() < 4) return;
    for (int i = 0; i < 4; i++) header[i] = Wire.read();

    uint16_t packetLen = (uint16_t)header[0] | ((uint16_t)(header[1] & 0x7F) << 8);
    if (packetLen == 0 || packetLen > 128) return;

    uint8_t body[128];
    uint16_t toRead = packetLen - 4;
    if (toRead > 124) toRead = 124;
    Wire.requestFrom(BNO085_I2C_ADDR, (int)toRead);
    for (uint16_t i = 0; i < toRead && Wire.available(); i++) {
        body[i] = Wire.read();
    }

    /* Look for accelerometer report (report id 0x01) */
    if (toRead >= 10 && body[0] == 0x01) {
        /*  Q-point for accelerometer is 8  →  divide by 256          */
        int16_t rawX = (int16_t)((uint16_t)body[4] | ((uint16_t)body[5] << 8));
        int16_t rawY = (int16_t)((uint16_t)body[6] | ((uint16_t)body[7] << 8));
        int16_t rawZ = (int16_t)((uint16_t)body[8] | ((uint16_t)body[9] << 8));

        accelX = rawX / 256.0f;  /* m/s² → roughly g when /9.81      */
        accelY = rawY / 256.0f;
        accelZ = rawZ / 256.0f;

        accelMagnitude = sqrtf(accelX * accelX +
                               accelY * accelY +
                               accelZ * accelZ) / 9.81f;  /* in g    */
    }
}

/* ─────────────────────────────────────────────────────────────────────
 *  FALL DETECTION  –  free-fall → impact pattern
 * ───────────────────────────────────────────────────────────────────── */
void checkFall() {
    unsigned long now = millis();

    if (!inFreeFall && accelMagnitude < FREEFALL_THRESHOLD) {
        /* Entered free-fall */
        inFreeFall    = true;
        freeFallStart = now;
    }

    if (inFreeFall) {
        /* If high-g impact follows within 500 ms → fall detected */
        if (accelMagnitude > FALL_ACCEL_THRESHOLD) {
            if ((now - freeFallStart) < 500) {
                fallDetected = true;
                Serial.println("[SafeNeck] ** FALL DETECTED **");
            }
            inFreeFall = false;
        }
        /* Timeout – no impact, cancel */
        if ((now - freeFallStart) > 1000) {
            inFreeFall = false;
        }
    }
}

/* ─────────────────────────────────────────────────────────────────────
 *  PUBLISH helpers  –  Particle Cloud events
 *
 *  Events are forwarded to Firebase RTDB via a Particle Webhook:
 *    Event name  →  "safeneck/location"  or  "safeneck/fall"
 *    Data format →  JSON string
 *
 *  Configure a Particle Integration (Webhook) to POST to:
 *    https://<project>.firebaseio.com/devices/{{PARTICLE_DEVICE_ID}}.json
 * ───────────────────────────────────────────────────────────────────── */
void publishLocation() {
    if (!Particle.connected()) return;

    float battery = getBatteryLevel();

    snprintf(publishBuf, sizeof(publishBuf),
        "{\"lat\":%.6f,\"lon\":%.6f,\"spd\":%.1f,\"fix\":%s,"
        "\"bat\":%.1f,\"ts\":%lu}",
        gpsLat, gpsLon, gpsSpeed,
        gpsFix ? "true" : "false",
        battery, (unsigned long)Time.now());

    bool ok = Particle.publish("safeneck/location", publishBuf,
                               PRIVATE | WITH_ACK);
    if (ok) {
        Serial.printlnf("[SafeNeck] Published location – lat %.6f  lon %.6f  bat %.0f%%",
                        gpsLat, gpsLon, battery);
    } else {
        Serial.println("[SafeNeck] Publish location FAILED");
    }
}

void publishFallAlert() {
    if (!Particle.connected()) return;

    float battery = getBatteryLevel();

    snprintf(publishBuf, sizeof(publishBuf),
        "{\"lat\":%.6f,\"lon\":%.6f,\"bat\":%.1f,"
        "\"type\":\"fall\",\"ts\":%lu}",
        gpsLat, gpsLon, battery, (unsigned long)Time.now());

    bool ok = Particle.publish("safeneck/fall", publishBuf,
                               PRIVATE | WITH_ACK);
    if (ok) {
        Serial.println("[SafeNeck] ** Published FALL ALERT **");
    } else {
        Serial.println("[SafeNeck] Publish fall alert FAILED");
    }
}

/* ─────────────────────────────────────────────────────────────────────
 *  BATTERY  –  read the Boron's LiPo fuel gauge
 * ───────────────────────────────────────────────────────────────────── */
float getBatteryLevel() {
    FuelGauge fuel;
    return fuel.getSoC();   /* returns 0.0 – 100.0 % */
}