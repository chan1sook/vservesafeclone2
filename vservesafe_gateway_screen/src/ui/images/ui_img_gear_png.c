// This file was generated by SquareLine Studio
// SquareLine Studio version: SquareLine Studio 1.3.2
// LVGL version: 8.3.6
// Project name: Vservesafe_gateway_screen

#include "../ui.h"

#ifndef LV_ATTRIBUTE_MEM_ALIGN
#define LV_ATTRIBUTE_MEM_ALIGN
#endif

// IMAGE DATA: assets\gear.png
const LV_ATTRIBUTE_MEM_ALIGN uint8_t ui_img_gear_png_data[] = {
0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x02,0x00,0x00,0x87,0x00,0x00,0xEC,0x00,0x00,0xEB,0x00,0x00,0x85,0x00,0x00,0x02,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x72,0x00,0x00,0xFF,0x00,0x00,0xAC,0x00,0x00,0xAD,0x00,0x00,0xFF,0x00,0x00,0x70,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1D,0x00,0x00,0x44,0x00,0x00,0x19,0xFF,0xFF,0x00,0x00,0x00,0x04,0x00,0x00,0xDB,0x00,0x00,0xBD,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xBE,0x00,0x00,0xDB,0x00,0x00,0x03,
    0xFF,0xFF,0x00,0x00,0x00,0x19,0x00,0x00,0x44,0x00,0x00,0x1C,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x6A,0x00,0x00,0xFB,0x00,0x00,0xFF,0x00,0x00,0xFC,0x00,0x00,0xAF,0x00,0x00,0xC5,0x00,0x00,0xFF,0x00,0x00,0x45,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x46,0x00,0x00,0xFF,0x00,0x00,0xC5,0x00,0x00,0xAF,0x00,0x00,0xFC,0x00,0x00,0xFF,0x00,0x00,0xFB,0x00,0x00,0x68,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1D,0x00,0x00,0xFB,0x00,0x00,0xB8,0x00,0x00,0x3C,0x00,0x00,0x87,0x00,0x00,0xD6,0x00,0x00,0xCC,0x00,0x00,0x59,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5B,0x00,0x00,0xCC,0x00,0x00,0xD6,0x00,0x00,0x87,0x00,0x00,0x3C,0x00,0x00,0xB9,0x00,0x00,0xFB,0x00,0x00,0x1B,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x49,0x00,0x00,0xFF,0x00,0x00,0x3D,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x3E,0x00,0x00,0xFF,0x00,0x00,0x47,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x19,0x00,0x00,0xFB,0x00,0x00,0x87,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x87,0x00,0x00,0xFC,0x00,0x00,0x18,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xAE,0x00,0x00,0xD6,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x2C,0x00,0x00,0x9C,0x00,0x00,0xD2,0x00,0x00,0xD2,0x00,0x00,0xA5,0x00,0x00,0x3D,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xD8,0x00,0x00,0xAD,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x04,0x00,0x00,0xC6,0x00,0x00,0xCC,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5D,0x00,0x00,0xFA,0x00,0x00,0xF2,0x00,0x00,0xBB,0x00,0x00,0xBB,0x00,0x00,0xF3,0x00,0x00,0xFF,0x00,0x00,0x76,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xCE,0x00,0x00,0xC4,0x00,0x00,0x03,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x02,0x00,0x00,0x71,0x00,0x00,0xDB,0x00,0x00,0xFF,0x00,0x00,0x5A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x2C,0x00,0x00,0xFA,0x00,0x00,0xC1,0x00,0x00,0x18,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x19,0x00,0x00,0xC1,0x00,0x00,0xFD,0x00,0x00,0x39,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5B,0x00,0x00,0xFF,0x00,0x00,0xDB,0x00,0x00,0x71,0x00,0x00,0x02,0x00,0x00,0x87,0x00,0x00,0xFF,0x00,0x00,0xBD,0x00,0x00,0x45,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x9C,0x00,0x00,0xF2,0x00,0x00,0x18,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x19,0x00,0x00,0xF3,
    0x00,0x00,0xA1,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x45,0x00,0x00,0xBD,0x00,0x00,0xFF,0x00,0x00,0x86,0x00,0x00,0xEC,0x00,0x00,0xAB,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xD1,0x00,0x00,0xBB,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xBC,0x00,0x00,0xD2,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xAB,0x00,0x00,0xEB,0x00,0x00,0xEB,0x00,0x00,0xAC,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xD1,0x00,0x00,0xAE,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xAF,0x00,0x00,0xD2,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xAC,0x00,0x00,0xEA,0x00,0x00,0x85,0x00,0x00,0xFF,0x00,0x00,0xBF,0x00,0x00,0x53,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x9B,
    0x00,0x00,0xEB,0x00,0x00,0x10,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x11,0x00,0x00,0xEC,0x00,0x00,0xA1,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x47,0x00,0x00,0xBE,0x00,0x00,0xFF,0x00,0x00,0x84,0x00,0x00,0x02,0x00,0x00,0x70,0x00,0x00,0xDB,0x00,0x00,0xFF,0x00,0x00,0x5C,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x2B,0x00,0x00,0xF9,0x00,0x00,0xB3,0x00,0x00,0x12,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x13,0x00,0x00,0xB5,0x00,0x00,0xFD,0x00,0x00,0x37,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5D,0x00,0x00,0xFF,0x00,0x00,0xDB,0x00,0x00,0x6F,0x00,0x00,0x02,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x03,0x00,0x00,0xC5,0x00,0x00,0xCD,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5B,0x00,0x00,0xF9,0x00,0x00,0xEE,0x00,0x00,0xB8,0x00,0x00,0xB8,0x00,0x00,0xEF,0x00,0x00,0xFE,0x00,0x00,0x73,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xCE,0x00,0x00,0xC3,0x00,0x00,0x03,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xAE,0x00,0x00,0xDF,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x2A,0x00,0x00,0x9A,0x00,0x00,0xD1,0x00,0x00,0xD2,0x00,0x00,0xA2,0x00,0x00,0x3A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xD8,0x00,0x00,0xAD,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1A,0x00,0x00,0xFC,0x00,0x00,0x8A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x88,0x00,0x00,0xFB,0x00,0x00,0x18,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x49,0x00,0x00,0xFF,0x00,0x00,0x3D,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x3E,0x00,0x00,0xFF,0x00,0x00,0x47,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1C,0x00,0x00,0xFB,0x00,0x00,0xB9,0x00,0x00,0x3D,0x00,0x00,0x87,0x00,0x00,0xD8,0x00,0x00,0xCE,0x00,0x00,0x5B,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x5C,0x00,0x00,0xCD,0x00,0x00,0xD8,0x00,0x00,0x88,0x00,0x00,0x3D,0x00,0x00,0xBA,0x00,0x00,0xFA,0x00,0x00,0x1A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x69,0x00,0x00,0xFB,0x00,0x00,0xFF,0x00,0x00,0xFC,0x00,0x00,0xAE,0x00,0x00,0xC4,0x00,0x00,0xFF,0x00,0x00,0x45,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x46,0x00,0x00,0xFF,0x00,0x00,0xC3,0x00,0x00,0xAE,0x00,0x00,0xFC,0x00,0x00,0xFF,0x00,0x00,0xFB,0x00,0x00,0x67,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x1B,0x00,0x00,0x44,0x00,0x00,0x18,0xFF,0xFF,0x00,
    0x00,0x00,0x03,0x00,0x00,0xDB,0x00,0x00,0xBD,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0xBE,0x00,0x00,0xDB,0x00,0x00,0x03,0xFF,0xFF,0x00,0x00,0x00,0x18,0x00,0x00,0x44,0x00,0x00,0x1A,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x71,0x00,0x00,0xFF,0x00,0x00,0xAC,0x00,0x00,0xAD,0x00,0x00,0xFF,0x00,0x00,0x6F,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0x00,0x00,0x02,0x00,0x00,0x86,0x00,0x00,0xEB,0x00,0x00,0xEA,0x00,0x00,0x85,0x00,0x00,0x02,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,
    };
const lv_img_dsc_t ui_img_gear_png = {
   .header.always_zero = 0,
   .header.w = 24,
   .header.h = 24,
   .data_size = sizeof(ui_img_gear_png_data),
   .header.cf = LV_IMG_CF_TRUE_COLOR_ALPHA,
   .data = ui_img_gear_png_data};

