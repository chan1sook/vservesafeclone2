// This file was generated by SquareLine Studio
// SquareLine Studio version: SquareLine Studio 1.3.2
// LVGL version: 8.3.6
// Project name: Vservesafe_gateway_screen

#include "../ui.h"

#ifndef LV_ATTRIBUTE_MEM_ALIGN
#define LV_ATTRIBUTE_MEM_ALIGN
#endif

// IMAGE DATA: assets\arrow_cc.png
const LV_ATTRIBUTE_MEM_ALIGN uint8_t ui_img_arrow_cc_png_data[] = {
0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x33,0x00,0x00,0xD3,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x49,0x00,0x00,0xF2,0x00,0x00,0xFF,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x6F,0x00,0x00,0xFD,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0x54,0x00,0x00,0x39,0x00,0x00,0x06,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x26,0x00,0x00,0xFA,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,
    0x00,0x00,0xFF,0x00,0x00,0xF5,0x00,0x00,0x9D,0x00,0x00,0x26,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x43,0x00,0x00,0xEE,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0x33,0x00,0x00,0x56,0x00,0x00,0x9D,0x00,0x00,0xF6,0x00,0x00,0xF7,0x00,0x00,0x6C,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x24,0x00,0x00,0xD8,0x00,0x00,0xFF,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1A,0x00,0x00,0xB5,0x00,0x00,0xFF,0x00,0x00,0x7F,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x14,0x00,0x00,0x9E,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x03,0x00,0x00,0xA1,0x00,0x00,0xFE,0x00,0x00,0x50,0xFF,0xFF,0x00,0x00,0x00,0x05,0x00,0x00,0x58,
    0x00,0x00,0x03,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x06,0x00,0x00,0xCF,0x00,0x00,0xE1,0x00,0x00,0x09,0x00,0x00,0x5D,0x00,0x00,0xFF,0x00,0x00,0x28,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x44,0x00,0x00,0xFF,0x00,0x00,0x5C,0x00,0x00,0xB1,0x00,0x00,0xDD,0x00,0x00,0x01,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x01,0x00,0x00,0xDE,0x00,0x00,0xAF,0x00,0x00,0xE3,0x00,0x00,0xA0,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xA3,0x00,0x00,0xE2,0x00,0x00,0xF9,0x00,0x00,0x84,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x89,0x00,0x00,0xF6,0x00,0x00,0xF5,0x00,0x00,0x8A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x8E,0x00,0x00,0xF3,0x00,0x00,0xD3,0x00,0x00,0xB3,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xB6,0x00,0x00,0xD1,0x00,0x00,0x93,0x00,0x00,0xF3,0x00,0x00,0x0B,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x0D,0x00,0x00,0xF4,0x00,0x00,0x93,0x00,0x00,0x38,0x00,0x00,0xFF,0x00,0x00,0x73,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x75,0x00,0x00,0xFF,0x00,0x00,0x36,0xFF,0xFF,0x00,0x00,0x00,0xB6,0x00,0x00,0xF3,0x00,0x00,0x25,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x27,0x00,0x00,0xF4,0x00,0x00,0xB4,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1C,0x00,0x00,0xEB,0x00,0x00,0xE0,0x00,0x00,0x26,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x27,
    0x00,0x00,0xE0,0x00,0x00,0xEA,0x00,0x00,0x1D,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x32,0x00,0x00,0xEC,0x00,0x00,0xF2,0x00,0x00,0x72,0x00,0x00,0x0A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x0B,0x00,0x00,0x73,0x00,0x00,0xF1,0x00,0x00,0xEB,0x00,0x00,0x33,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1E,0x00,0x00,0xBC,0x00,0x00,0xFF,0x00,0x00,0xF4,0x00,0x00,0xB6,0x00,0x00,0x8E,0x00,0x00,0x8E,0x00,0x00,0xB6,0x00,0x00,0xF4,0x00,0x00,0xFF,0x00,0x00,0xBC,0x00,0x00,0x1F,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x3F,0x00,0x00,0x9B,0x00,0x00,0xD6,0x00,0x00,0xFA,0x00,0x00,0xEF,0x00,0x00,0xD5,0x00,0x00,0x9B,0x00,0x00,0x3F,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,};
const lv_img_dsc_t ui_img_arrow_cc_png = {
   .header.always_zero = 0,
   .header.w = 18,
   .header.h = 21,
   .data_size = sizeof(ui_img_arrow_cc_png_data),
   .header.cf = LV_IMG_CF_TRUE_COLOR_ALPHA,
   .data = ui_img_arrow_cc_png_data};

