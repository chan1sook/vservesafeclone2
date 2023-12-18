class VserveIoTData {
  DateTime? datetime;
  double? value;
  double? temp;
  double? humid;

  VserveIoTData({this.datetime, this.value, this.temp, this.humid});

  static VserveIoTData parseFromRawData(Map<String, dynamic> data) {
    final result = VserveIoTData();

    if (data["time"] is num) {
      int? value = int.tryParse("${data['time']}");
      if (value != null) {
        result.datetime = DateTime.fromMillisecondsSinceEpoch(value);
      }
    }
    if (data["value"] is num) {
      result.value = 1.0 * data["value"];
    }
    if (data["temp"] is num) {
      result.temp = 1.0 * data["temp"];
    }
    if (data["humid"] is num) {
      result.humid = 1.0 * data["humid"];
    }
    return result;
  }
}
