#ifndef __VSERVESAFE_BLE__
#define __VSERVESAFE_BLE__

#include <Arduino.h>
#include "vservesafe_conf.h"

#include <NimBLEDevice.h>

std::string prettyMacAddress(std::string rawMacAddress);

typedef enum
{
    VSERVESAFE_SCANMODE_NOSCAN,
    VSERVESAFE_SCANMODE_ALLSCAN,
    VSERVESAFE_SCANMODE_SELECTED_SCAN,
} coldsenses_scan_mode;

typedef enum
{
    VSERVESAFE_NOTIFY_NODATA,
    VSERVESAFE_NOTIFY_NORMAL,
    VSERVESAFE_NOTIFY_HIGH,
    VSERVESAFE_NOTIFY_LOW,
} coldsenses_notify_result;

typedef struct
{
    uint32_t ts;
    std::string name;
    std::string rawMacAddress;
    double tempC;
    double humidRH;
    uint16_t battMv;
    uint8_t battPercent;
    uint8_t counter;
    uint8_t flag;
} MiTagData;

typedef struct
{
    std::string rawMacAddress;
    bool isNotify;
    double lowC;
    double highC;
} MiTagNotifyData;

class MiTagScanner
{
private:
    BLEScan *_pBLEScan;
    MiTagData _tags[MAX_TAGS_REMEMBER];
    int _tagsCount = 0;
    MiTagNotifyData _notifyDataArr[MAX_NOTIFY_REMEMBER];
    int _notifyCount = 0;

    void _addMiTagData(MiTagData &tagData);
    void _clearMiTagData();
    void _parseRawDataTo(std::string &rawData, MiTagData &to);
#if VSERVESAFE_DEBUG_BLE
    void _debugBLEData(std::string &rawData);
#endif

public:
    static NimBLEUUID TARGET_UUID;
    static std::string prettyRawData(std::string &rawData);
    static std::string toRawMacAddress(std::string macAddress);

    void init();
    void clearTagsResults();
    void scan();
    int getTagsCount();
    int getActiveTagCount();
    int findTagData(std::string &rawMacAddress);
    MiTagData *getTagDataAt(int i);
    bool isTagActive(MiTagData *tagData);
    bool isMiTagDataValid(std::string &rawData);

    int getTagNotifyDataCount();
    void addTagNotifyData(MiTagNotifyData &notifyData);
    void clearTagNotifyDataResults();
    int findTagNotifyData(std::string &rawMacAddress);
    bool isTagNotifyDataExists(std::string &rawMacAddress);
    coldsenses_notify_result getTagNotifyResult(std::string &rawMacAddress);
};

#endif