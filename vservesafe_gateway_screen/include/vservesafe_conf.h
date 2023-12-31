#ifndef __VSERVESAFE_CONF_
#define __VSERVESAFE_CONF_

#define VSERVESAFE_GATEWAY_VERSION (2)
#define VSERVESAFE_GATEWAY_VERSION_FULL ("0.2.0")

#ifndef VSERVESAFE_DEBUG_BLE
#define VSERVESAFE_DEBUG_BLE (0)
#endif

#ifndef VSERVESAFE_DEBUG_WIFI
#define VSERVESAFE_DEBUG_WIFI (0)
#endif

#ifndef VSERVESAFE_DEBUG_EEPROM
#define VSERVESAFE_DEBUG_EEPROM (1)
#endif

#ifndef VSERVESAFE_DEBUG_TICK
#define VSERVESAFE_DEBUG_TICK (0)
#endif

#ifndef VSERVESAFE_DEBUG_MQTT
#define VSERVESAFE_DEBUG_MQTT (1)
#endif

#ifndef MAX_TAGS_REMEMBER
#define MAX_TAGS_REMEMBER (16)
#endif

#ifndef MAX_NOTIFY_REMEMBER
#define MAX_NOTIFY_REMEMBER (64)
#endif

#ifndef TAG_ONLINE_TIEMOUT
#define TAG_ONLINE_TIEMOUT (60000)
#endif

#ifndef VSERVESAFE_ALLOW_EEPROM
#define VSERVESAFE_ALLOW_EEPROM (1)
#endif

#ifndef VSERVESAFE_FAKE_MQTT
#define VSERVESAFE_FAKE_MQTT (0)
#endif

#define SSID_MAXLENGTH (32)
#define WIFIPW_MAXLENGTH (64)

// #define VSERVESAFE_MQTT_SERVER_URL ("192.168.1.2")
// #define VSERVESAFE_MQTT_SERVER_PORT (3062)

#ifndef VSERVESAFE_MQTT_SERVER_URL
#define VSERVESAFE_MQTT_SERVER_URL ("vservesafe.sensesiot.net")
#endif

#ifndef VSERVESAFE_MQTT_SERVER_PORT
#define VSERVESAFE_MQTT_SERVER_PORT (3062)
#endif

#define EEPROM_HEADER_KEY (0b0011010100101011000011111001111110101010010011001000111101000100L)

#define EEPROM_HEADER_ADDR (0)
#define EEPROM_VERSION_ADDR (EEPROM_HEADER_ADDR + sizeof(uint64_t))
#define EEPROM_SSID_ADDR (EEPROM_VERSION_ADDR + sizeof(uint16_t))
#define EEPROM_WIFIPW_ADDR (EEPROM_SSID_ADDR + SSID_MAXLENGTH + 1)
#define EEPROM_GPSLAT_ADDR (EEPROM_WIFIPW_ADDR + WIFIPW_MAXLENGTH + 1)
#define EEPROM_GPSLONG_ADDR (EEPROM_GPSLAT_ADDR + sizeof(double))
#define EEPROM_BUZZER_ENABLE_ADDR (EEPROM_GPSLONG_ADDR + sizeof(double))
#define EEPROM_TOTAL_BYTES (EEPROM_BUZZER_ENABLE_ADDR + sizeof(bool))
#endif