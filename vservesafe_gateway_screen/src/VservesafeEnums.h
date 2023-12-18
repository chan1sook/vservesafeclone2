#ifndef __VSERVESAFE_ENUMS__
#define __VSERVESAFE_ENUMS__

#include "ui/ui.h"

typedef enum
{
  VSERVESAFE_WL_WAITING,
  VSERVESAFE_WL_CONNECTED,
  VSERVESAFE_WL_DISCONNECTED,
  VSERVESAFE_WL_CONNECT_FAILED,
} coldsenses_wifi_state;

typedef enum
{
  VSERVESAFE_TAG_WAITING,
  VSERVESAFE_TAG_SCANNED,
  VSERVESAFE_TAG_NOT_SCAN,
} coldsenses_tag_state;

typedef enum
{
  VSERVESAFE_MQTT_WAITING,
  VSERVESAFE_MQTT_CONNECTED,
  VSERVESAFE_MQTT_DISCONNECTED,
  VSERVESAFE_MQTT_CONNECT_FAILED,
} coldsenses_mqtt_state;

typedef enum
{
  VSERVESAFE_OPTION_SET_WIFI_SSID,
  VSERVESAFE_OPTION_SET_WIFI_PASSWORD,
  VSERVESAFE_OPTION_SET_GPS_LATITUDE,
  VSERVESAFE_OPTION_SET_GPS_LONGITUDE,
  VSERVESAFE_OPTION_TOGGLE_ALARM_BUZZER,
  VSERVESAFE_OPTION_CHECK_VERSION,
} coldsenses_option;

typedef enum
{
  VSERVESAFE_NO_TARGET,
  VSERVESAFE_TARGET_WIFI_SSID,
  VSERVESAFE_TARGET_WIFI_PASSWORD,
  VSERVESAFE_TARGET_GPS_LATITUDE,
  VSERVESAFE_TARGET_GPS_LONGITUDE,
  VSERVESAFE_TARGET_ALARM_BUZZER,
} coldsenses_input_target;

typedef enum
{
  VSERVESAFE_NO_ACTION,
  VSERVESAFE_ACTION_SAVE_CONFIRM,
  VSERVESAFE_ACTION_SAVE_RESET,
  VSERVESAFE_ACTION_SAVE_CANCEL,
  VSERVESAFE_ACTION_INPUT_CONFIRM,
  VSERVESAFE_ACTION_INPUT_RESET,
  VSERVESAFE_ACTION_INPUT_CANCEL,
  VSERVESAFE_ACTION_AFTER_CHECK_VERSION,
} coldsenses_after_alarm_action;

typedef struct
{
  lv_obj_t *tag_panel;
  lv_obj_t *inner_panel;
  lv_obj_t *mac_label;
  lv_obj_t *name_label;
  lv_obj_t *temp_label;
  lv_obj_t *humid_label;
} ui_coldsenses_tag_holder;

typedef struct
{
  lv_obj_t *option_panel;
  lv_obj_t *text_label;
  lv_obj_t *mark_edit_img;
  lv_obj_t *mark_arrow_right;
  coldsenses_option type;
} ui_coldsenses_option_holder;

#endif