#include "BLE.h"

std::string prettyMacAddress(std::string rawMacAddress)
{
  String buffer = "";
  for (int i = 0; i < 6; i++)
  {
    if (i > 0)
    {
      buffer += ":";
    }
    uint8_t b = rawMacAddress[i];
    if (b < 0x10)
    {
      buffer += '0';
    }
    buffer += String(b, 16);
  }
  return buffer.c_str();
}

NimBLEUUID MiTagScanner::TARGET_UUID = NimBLEUUID("181a");

void MiTagScanner::init()
{
  BLEDevice::init("");
  this->_pBLEScan = BLEDevice::getScan();
  this->_pBLEScan->setActiveScan(true);
  this->_pBLEScan->setInterval(100);
  this->_pBLEScan->setWindow(99);
  this->_pBLEScan->start(0, nullptr, false);
}

void MiTagScanner::clearTagsResults()
{
  this->_tagsCount = 0;
}

void MiTagScanner::scan()
{
  BLEScanResults foundDevices = this->_pBLEScan->getResults();
  int nDevice = foundDevices.getCount();
  for (int i = 0; i < nDevice; i++)
  {
    NimBLEAdvertisedDevice device = foundDevices.getDevice(i);

    std::string rawData = device.getServiceData(TARGET_UUID);
#if VSERVESAFE_DEBUG_BLE
    _debugBLEData(rawData);
#endif

    if (this->isMiTagDataValid(rawData))
    {
      MiTagData data;
      data.name = device.getName();
      data.ts = millis();
      this->_parseRawDataTo(rawData, data);
      this->_addMiTagData(data);
    }
  }

  Serial.print("Devices found: ");
  Serial.println(nDevice);
  Serial.print("Tags found: ");
  Serial.println(this->_tagsCount);
  Serial.println("Scan done!");

  this->_pBLEScan->clearResults();
  // this->_pBLEScan->start(0, nullptr, false);
}

int MiTagScanner::getTagsCount()
{
  return this->_tagsCount;
}

int MiTagScanner::getActiveTagCount()
{
  int onlines = 0;
  for (int i = 0; i < this->_tagsCount; i++)
  {
    if (isTagActive(getTagDataAt(i)))
    {
      onlines += 1;
    }
  }

  return onlines;
}

int MiTagScanner::findTagData(std::string &rawMacAddress)
{
  for (int i = 0; i < this->_tagsCount; i++)
  {
    if (rawMacAddress == this->_tags[i].rawMacAddress)
    {
      return i;
    }
  }
  return -1;
}

MiTagData *MiTagScanner::getTagDataAt(int i)
{
  if (i < 0 || i >= this->_tagsCount)
  {
    return NULL;
  }
  return &(this->_tags[i]);
}

bool MiTagScanner::isTagActive(MiTagData *tagData)
{
  return tagData && (millis() - (*tagData).ts) <= TAG_ONLINE_TIEMOUT;
}

bool MiTagScanner::isMiTagDataValid(std::string &rawData)
{
  return rawData.length() == 15;
}

void MiTagScanner::_addMiTagData(MiTagData &tagData)
{
  int index = this->findTagData(tagData.rawMacAddress);
  if (index != -1)
  {
    this->_tags[index] = tagData;
    return;
  }

  if (this->_tagsCount < MAX_TAGS_REMEMBER)
  {
    this->_tags[this->_tagsCount] = tagData;
    this->_tagsCount += 1;
    return;
  }

  int targetIndex = -1;
  uint32_t tsPrev = 0;
  for (int i = 0; i < this->_tagsCount; i++)
  {
    if (this->_tags[i].ts > tsPrev)
    {
      tsPrev = this->_tags[i].ts;
      targetIndex = i;
    }
  }

  if (targetIndex != -1)
  {
    this->_tags[targetIndex] = tagData;
  }
}

void MiTagScanner::_clearMiTagData()
{
  this->_tagsCount = 0;
}

void MiTagScanner::_parseRawDataTo(std::string &rawData, MiTagData &to)
{
  to.rawMacAddress = "";
  for (int i = 5; i >= 0; i--)
  {
    to.rawMacAddress += rawData[i];
  }

  int tempRaw = rawData[6] + (rawData[7] << 8);
  to.tempC = tempRaw / 100.0;

  int humidRaw = rawData[8] + (rawData[9] << 8);
  to.humidRH = humidRaw / 100.0;

  to.battMv = rawData[10] + (rawData[11] << 8);
  to.battPercent = rawData[12];
  to.counter = rawData[13];
  to.flag = rawData[14];
}

int MiTagScanner::getTagNotifyDataCount()
{
  return this->_notifyCount;
}

void MiTagScanner::addTagNotifyData(MiTagNotifyData &notifyData)
{
  for (int i = 0; i < this->_notifyCount; i++)
  {
    if (notifyData.rawMacAddress == this->_notifyDataArr[i].rawMacAddress)
    {
      this->_notifyDataArr[i] = notifyData;
      return;
    }
  }

  if (this->_notifyCount < MAX_NOTIFY_REMEMBER)
  {
    this->_notifyDataArr[this->_notifyCount] = notifyData;
    this->_notifyCount += 1;
    return;
  }
}

void MiTagScanner::clearTagNotifyDataResults()
{
  this->_notifyCount = 0;
}

int MiTagScanner::findTagNotifyData(std::string &rawMacAddress)
{
  for (int i = 0; i < this->_notifyCount; i++)
  {
    if (rawMacAddress == this->_notifyDataArr[i].rawMacAddress)
    {
      return i;
    }
  }
  return -1;
}

bool MiTagScanner::isTagNotifyDataExists(std::string &rawMacAddress)
{
  return this->findTagNotifyData(rawMacAddress) != -1;
}

coldsenses_notify_result MiTagScanner::getTagNotifyResult(std::string &rawMacAddress)
{
  int notifyIndex = this->findTagNotifyData(rawMacAddress);
  int tagIndex = this->findTagData(rawMacAddress);
  if (notifyIndex == -1 || tagIndex == -1)
  {
    return VSERVESAFE_NOTIFY_NODATA;
  }

  MiTagData data = this->_tags[tagIndex];
  MiTagNotifyData notifyData = this->_notifyDataArr[notifyIndex];

  if (!notifyData.isNotify)
  {
    return VSERVESAFE_NOTIFY_NORMAL;
  }
  if (data.tempC >= notifyData.highC)
  {
    return VSERVESAFE_NOTIFY_HIGH;
  }
  else if (data.tempC <= notifyData.lowC)
  {
    return VSERVESAFE_NOTIFY_LOW;
  }
  else
  {
    return VSERVESAFE_NOTIFY_NORMAL;
  }
}

std::string MiTagScanner::prettyRawData(std::string &rawData)
{
  String buffer = "[";
  int len = rawData.length();
  for (int i = 0; i < len; i++)
  {
    if (i > 0)
    {
      buffer += ',';
    }
    buffer += (int)rawData[i];
  }
  buffer += ']';
  return buffer.c_str();
}

std::string MiTagScanner::toRawMacAddress(std::string macAddress)
{
  std::string result;
  for (int i = 0; i < macAddress.length(); i += 2)
  {
    char m = (char)strtol(macAddress.substr(i, 2).c_str(), nullptr, 16);
    result += m;
  }
  return result;
}

#if VSERVESAFE_DEBUG_BLE

void MiTagScanner::_debugBLEData(std::string &rawData)
{
  int len = rawData.length();
  Serial.print("Data: ");
  Serial.println(MiTagScanner.prettyRawData(rawData).c_str());
}
#endif