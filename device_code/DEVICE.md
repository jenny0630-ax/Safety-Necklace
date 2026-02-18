# SafeNeck – Device Hardware & Firmware

## Hardware Components
- **Boron 404X Kit** (cellular LTE-M / 2G connectivity)
- **Adafruit 9-DOF Orientation IMU Fusion Breakout – BNO085** (STEMMA QT / Qwiic) – fall detection
- **Adafruit Mini GPS PA1010D** (STEMMA QT / Qwiic) – real-time location tracking

## Wiring (I2C daisy-chain via STEMMA QT / Qwiic)
```
Boron SDA → BNO085 SDA → GPS SDA
Boron SCL → BNO085 SCL → GPS SCL
Boron 3V3 → BNO085 VIN → GPS VIN
Boron GND → BNO085 GND → GPS GND
```

## Firmware Overview (`main.c`)
The firmware runs on Particle Device OS and performs three main tasks:

1. **GPS Tracking** – Reads NMEA sentences from the PA1010D over I2C every loop cycle. Publishes latitude, longitude, speed, and GPS fix status to Particle Cloud every 30 seconds.

2. **Fall Detection** – Continuously reads the BNO085 accelerometer at ~50 Hz. Detects a free-fall → impact pattern (acceleration drops below 0.4 g then spikes above 2.5 g within 500 ms). On detection, immediately publishes a `safeneck/fall` alert.

3. **Battery Monitoring** – Reads the Boron's on-board LiPo fuel gauge and includes the battery percentage in every publish.

## Particle Cloud Events
| Event Name | Trigger | Data |
|---|---|---|
| `safeneck/location` | Every 30 s | `{lat, lon, spd, fix, bat, ts}` |
| `safeneck/fall` | Fall detected | `{lat, lon, bat, type:"fall", ts}` |

## Firebase Integration
Configure a **Particle Webhook Integration** to forward events to Firebase Realtime Database:
- URL: `https://<project-id>.firebaseio.com/users/<uid>/devices/{{PARTICLE_DEVICE_ID}}/location.json`
- Method: `PUT`
- The companion Flutter app streams this data in real time.

## Building & Flashing
```bash
# Using Particle CLI
particle compile boron main.c --saveTo firmware.bin
particle flash <device-name> firmware.bin
```