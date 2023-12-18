import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;

import 'package:duration/locale.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:vservesafe/src/components/scrollable_container.dart';
import 'package:vservesafe/src/components/tabs_component.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/models/iot_data.dart';
import 'package:vservesafe/src/models/iot_device.dart';
import 'package:vservesafe/src/models/site_data.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:duration/duration.dart';

class IotDashboardView extends StatefulWidget {
  const IotDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
    this.startPageIndex,
  });

  final SettingsController settingsController;
  final UserController userController;
  final int? startPageIndex;

  static const routeName = '/iot';
  @override
  State<IotDashboardView> createState() => _IotDashboardViewState();
}

class _IotDashboardViewState extends State<IotDashboardView>
    with TickerProviderStateMixin {
  late Timer _timer;
  String? _selectedMacAddress;
  late io.Socket _socket;
  final Map<String, VserveIoTData> _iotData = {};
  final Map<String, VserveIoTDeviceData> _deviceData = {};
  late TabController _tabController;
  VserveSiteData? _site;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 1, vsync: this);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final site = widget.userController.selectedSite;

      if (_site != site) {
        _site = site;
        _loadingData = true;
        _loadAllData();
        setState(() {});
      }
    });

    _socketIO();

    _site = widget.userController.selectedSite;
    _loadAllData();
    developer.log("${widget.startPageIndex}", name: "Route Args");
  }

  void _socketIO() {
    final uri = Uri.parse(ApiService.socketIoPath);
    final host = uri.hasPort
        ? "${uri.scheme}://${uri.host}:${uri.port}"
        : "${uri.scheme}://${uri.host}";
    final subpath = "${uri.path}/socket.io";

    developer.log("SIO Host: $host", name: "SocketIO");
    developer.log("SIO Path: $subpath", name: "SocketIO");

    _socket = io.io(
      host,
      io.OptionBuilder().setTransports(['websocket']).setPath(subpath).build(),
    );
    _socket.onConnect((_) {
      developer.log("Connected", name: "SocketIO");
    });
    _socket.onError((err) {
      developer.log(err.toString(), name: "SocketIO");
    });

    _socket.on('vsafe-iot-set', (data) {
      if (_iotData.containsKey(data["key"])) {
        if (data["value"] is Map<String, dynamic>) {
          _iotData[data["key"]] = VserveIoTData.parseFromRawData(data["value"]);
        }
        setState(() {});
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();

    _socket.dispose();
    _socketIO();

    _loadingData = true;
    _site = widget.userController.selectedSite;
    _loadAllData();
  }

  Future<void> _loadIoTData() async {
    try {
      final response = await ApiService.dio
          .get("${ApiService.baseUrlPath}/iot/lists", queryParameters: {
        "site_id": _site?.id,
      });
      final listData = response.data["lists"] as Map<String, dynamic>;
      _iotData.clear();
      for (final entry in listData.entries) {
        if (entry.value is Map<String, dynamic>) {
          _iotData[entry.key] = VserveIoTData.parseFromRawData(entry.value);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "IoT");
    }
  }

  Future<void> _loadIoTDeviceData() async {
    try {
      final response = await ApiService.dio
          .get("${ApiService.baseUrlPath}/devices/all", queryParameters: {
        "site_id": _site?.id,
      });
      final deviceData = response.data["devices"] as List<dynamic>;
      _deviceData.clear();
      for (final entry in deviceData) {
        if (entry is Map<String, dynamic>) {
          final data = VserveIoTDeviceData.parseFromRawData(entry);
          _deviceData[data.macAddress] = data;
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "IoT");
    }
  }

  void _loadAllData() {
    Future.wait([_loadIoTDeviceData(), _loadIoTData()]).then((value) {
      if (context.mounted) {
        _loadingData = false;
        setState(() {});
      }
    }).catchError((err) {
      developer.log("Error $err", name: "IoT");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VserveTabBarComponent(
                tabs: [
                  VserveHorizontalTabComponent(
                    icon: const FaIcon(FontAwesomeIcons.tablet),
                    label: Text(
                        AppLocalizations.of(context)!.iotDashbordDeviceTab),
                  ),
                  if (_selectedMacAddress != null)
                    VserveHorizontalTabComponent(
                      icon: const FaIcon(FontAwesomeIcons.chartBar),
                      label: Text(
                          AppLocalizations.of(context)!.iotDashbordChartTab),
                    ),
                ],
                controller: _tabController,
                onTap: (index) {
                  _tabController.index = index;
                  setState(() {});
                },
              ),
              if (_tabController.index == 0)
                _IoTDevicesView(
                  iotData: _iotData,
                  deviceData: _deviceData,
                  isLoading: _loadingData,
                  onSelectDevice: (macAddress) {
                    _selectedMacAddress = macAddress;
                    _tabController =
                        TabController(length: 2, vsync: this, initialIndex: 1);
                    _tabController.index = 1;
                    setState(() {});
                  },
                ),
              if (_tabController.index == 1)
                _IoTDashboardView(
                  macAddress: _selectedMacAddress,
                  settingsController: widget.settingsController,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _socket.dispose();

    super.dispose();
  }
}

class _IoTDevicesView extends StatefulWidget {
  const _IoTDevicesView({
    required this.iotData,
    required this.deviceData,
    this.isLoading,
    this.onSelectDevice,
  });

  final Map<String, VserveIoTData> iotData;
  final Map<String, VserveIoTDeviceData> deviceData;
  final bool? isLoading;
  final Function(String)? onSelectDevice;

  @override
  State<_IoTDevicesView> createState() => _IoTDevicesViewState();
}

class _IoTDevicesViewState extends State<_IoTDevicesView> {
  List<String> _selectedTypesFilter = [];
  late Timer _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Timer(const Duration(seconds: 100), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<VserveIoTDeviceData> filteredDevices = _filterDevices();
    List<String> allTypesFilter = _getAllTypeFilters();

    return widget.isLoading == true
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Text(
                AppLocalizations.of(context)!.loadingDialogText,
                style: const TextStyle(fontSize: 21),
              ),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!
                            .iotDashbordDeviceFilter),
                        const SizedBox(width: 7),
                        Expanded(
                          child: MultiSelectDialogField<String>(
                            buttonText: Text(AppLocalizations.of(context)!
                                .iotDashbordDeviceFilterType),
                            title: Text(AppLocalizations.of(context)!
                                .iotDashbordDeviceFilterType),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            initialValue: _selectedTypesFilter
                                .where((ele) => allTypesFilter.contains(ele))
                                .toList(),
                            searchable: true,
                            items: allTypesFilter.map((e) {
                              return MultiSelectItem(e, e);
                            }).toList(),
                            listType: MultiSelectListType.CHIP,
                            chipDisplay: MultiSelectChipDisplay.none(),
                            onConfirm: (values) {
                              _selectedTypesFilter = values;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    MultiSelectChipDisplay<String>(
                      items: _selectedTypesFilter.map((ele) {
                        return MultiSelectItem(ele, ele);
                      }).toList(),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                primary: false,
                shrinkWrap: true,
                itemCount: filteredDevices.length,
                itemBuilder: (context, index) {
                  VserveIoTDeviceData targetDevice = filteredDevices[index];
                  VserveIoTData? data = widget.iotData[targetDevice.macAddress];

                  String value = "-";
                  if (data != null) {
                    if (data.temp != null || data.humid != null) {
                      value = _formatRefrigeratorData(data);
                    } else {
                      value = _formatGeneralData(data);
                    }
                  }

                  return ListTile(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(targetDevice.name),
                        Text(
                          targetDevice.macAddress,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: Text(targetDevice.type),
                    leading: Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline(data) ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: Text(
                      value,
                      textAlign: TextAlign.end,
                    ),
                    onTap: () {
                      widget.onSelectDevice?.call(targetDevice.macAddress);
                    },
                  );
                },
              ),
            ],
          );
  }

  List<String> _getAllTypeFilters() {
    List<String> types = [];
    for (final device in widget.deviceData.values) {
      if (!types.contains(device.type)) {
        types.add(device.type);
      }
    }
    types.sort((a, b) => a.compareTo(b));
    return types;
  }

  List<VserveIoTDeviceData> _filterDevices() {
    var lists = widget.deviceData.values;
    if (_selectedTypesFilter.isEmpty) {
      return lists.toList();
    }

    List<VserveIoTDeviceData> filterDevices = [];

    for (final device in lists) {
      if (_selectedTypesFilter.contains(device.type)) {
        filterDevices.add(device);
      }
    }
    return filterDevices;
  }

  String _formatRefrigeratorData(VserveIoTData data) {
    String result = "";
    if (data.temp != null) {
      result += "${data.temp} °C\n";
    }
    if (data.humid != null) {
      result += "${data.humid} %RH\n";
    }
    return result.trimRight();
  }

  bool _isOnline(VserveIoTData? data) {
    return data != null &&
        data.datetime != null &&
        DateTime.now().difference(data.datetime!) < const Duration(minutes: 5);
  }

  String _formatGeneralData(VserveIoTData data) {
    if (data.value != null) {
      return "${data.value}";
    } else {
      return "-";
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }
}

class _IoTDashboardView extends StatefulWidget {
  const _IoTDashboardView({
    required this.settingsController,
    this.macAddress,
  });

  final SettingsController settingsController;
  final String? macAddress;

  @override
  State<_IoTDashboardView> createState() => _IoTDashboardViewState();
}

class _IoTDashboardViewState extends State<_IoTDashboardView> {
  final List<Duration> _allDurations = [
    const Duration(minutes: 5),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 4),
    const Duration(hours: 12),
    const Duration(hours: 24),
    const Duration(days: 3),
    const Duration(days: 7),
  ];
  Duration _duration = const Duration(hours: 1);
  DateTime _startTimeChart = DateTime.now();
  bool _loading = true;
  List<FlSpot> _valueData = [];
  List<FlSpot> _tempData = [];
  List<FlSpot> _humidData = [];

  @override
  void initState() {
    super.initState();

    _loadSeriesData();
  }

  void _loadSeriesData() async {
    if (widget.macAddress == null) {
      return;
    }

    try {
      final currentTime = DateTime.now();
      final startTime = currentTime.subtract(_duration);
      final response = await ApiService.dio.get(
          "${ApiService.baseUrlPath}/iot/range_single/${widget.macAddress}",
          queryParameters: {
            "start_ts": startTime.millisecondsSinceEpoch,
            "end_ts": currentTime.millisecondsSinceEpoch,
          });

      final listData = response.data["lists"] as Map<String, dynamic>;
      final filterData = listData[widget.macAddress];
      List<FlSpot> valueList = [];
      List<FlSpot> tempList = [];
      List<FlSpot> humidList = [];
      _startTimeChart = startTime;
      if (filterData is List<dynamic>) {
        for (final f in filterData) {
          if (f is Map<String, dynamic> && f["time"] is num) {
            final d = f["time"] - startTime.millisecondsSinceEpoch.toDouble();
            final fraction = d * 100.0 / _duration.inMilliseconds.toDouble();
            if (f["value"] is num) {
              valueList.add(FlSpot(fraction, 1.0 * f["value"]));
            }
            if (f["temp"] is num) {
              tempList.add(FlSpot(fraction, 1.0 * f["temp"]));
            }
            if (f["humid"] is num) {
              humidList.add(FlSpot(fraction, 1.0 * f["humid"]));
            }
          }
        }
      }
      _valueData = _lttb(valueList, 250);
      _tempData = _lttb(tempList, 250);
      _humidData = _lttb(humidList, 250);

      if (mounted) {
        _loading = false;
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "IoT");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 21),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Duration>(
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            ),
            value: _duration,
            onChanged: (value) {
              if (value != null) {
                _duration = value;
                _loading = true;
                _loadSeriesData();
                setState(() {});
              }
            },
            items: _allDurations.map((duration) {
              return DropdownMenuItem<Duration>(
                value: duration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      prettyDuration(duration,
                          locale: DurationLocale.fromLanguageCode(widget
                                  .settingsController.locale.languageCode) ??
                              const EnglishDurationLocale()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 21),
          ScrollableContainerComponent(
            child: _chartWidget,
          )
        ],
      ),
    );
  }

  Widget get _chartWidget {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.macAddress ?? "Chart",
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 21),
        _loading
            ? Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Text(
                    AppLocalizations.of(context)!.loadingDialogText,
                    style: const TextStyle(fontSize: 21),
                  ),
                ),
              )
            : AspectRatio(
                aspectRatio: 2.25,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.white.withOpacity(0.8),
                              tooltipBorder:
                                  const BorderSide(color: Colors.grey),
                              getTooltipItems:
                                  (List<LineBarSpot> touchedSpots) {
                                return touchedSpots
                                    .map((LineBarSpot touchedSpot) {
                                  final textStyle = TextStyle(
                                    color: touchedSpot
                                            .bar.gradient?.colors.first ??
                                        touchedSpot.bar.color ??
                                        Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );

                                  String value = touchedSpot.y.toString();
                                  switch (touchedSpot.barIndex) {
                                    case 0:
                                      value = "Value: $value";
                                      break;
                                    case 1:
                                      value = "Temp: $value";
                                      break;
                                    case 2:
                                      value = "Humid: $value";
                                      break;
                                  }

                                  return LineTooltipItem(value, textStyle);
                                }).toList();
                              }),
                        ),
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: 100 / (width / 100),
                              getTitlesWidget: _bottomTitleWidgets,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: _leftTitles,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey, width: 2),
                            left: BorderSide(color: Colors.grey, width: 2),
                            right: BorderSide(color: Colors.transparent),
                            top: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: false,
                            color: Colors.purple,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                            spots: _valueData,
                          ),
                          LineChartBarData(
                            isCurved: false,
                            color: Colors.red,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                            spots: _tempData,
                          ),
                          LineChartBarData(
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                            spots: _humidData,
                          )
                        ],
                        minX: 0,
                        maxX: 100,
                        minY: _barMin,
                        maxY: _barMax,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  double get _barMin {
    final allData = _valueData + _tempData + _humidData;
    return allData.isEmpty
        ? 0
        : allData.map((ele) => ele.y).reduce(math.min).floorToDouble();
  }

  double get _barMax {
    final allData = _valueData + _tempData + _humidData;
    return allData.isEmpty
        ? 100
        : allData.map((ele) => ele.y).reduce(math.max).ceilToDouble();
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    if (meta.max == value) {
      return Container();
    }

    final actualDate = _startTimeChart.add(_duration * (value / 100.0));
    String timeFormat = DateFormat(
            "EEE HH:mm", widget.settingsController.locale.toLanguageTag())
        .format(actualDate.toLocal());

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 20,
      child: Text(
        timeFormat,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  SideTitles get _leftTitles => SideTitles(
        getTitlesWidget: _leftTitleWidgets,
        showTitles: true,
        reservedSize: 64,
      );

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(value.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center);
  }

  List<FlSpot> _lttb(List<FlSpot> data, int threshold) {
    if (threshold <= 0 || data.length <= threshold) {
      return data;
    }

    List<FlSpot> sortedData = List<FlSpot>.from(data);
    sortedData.sort((a, b) {
      return (a.x - b.x).sign.toInt();
    });

    List<FlSpot> sampled = [];
    int sampledIndex = 0;

    // Bucket size. Leave room for start and end data points
    double every = (data.length - 2) / (threshold - 2);

    FlSpot maxAreaPoint = FlSpot.nullSpot;
    double maxArea;
    double area;
    int a = 0;
    int nextA = 0;

    sampled[sampledIndex++] = data[a]; // Always add the first point

    for (int i = 0; i < threshold - 2; i++) {
      // Calculate point average for next bucket (containing c)
      double avgX = 0;
      double avgY = 0;
      var avgRangeStart = ((i + 1) * every).floor() + 1;
      var avgRangeEnd = ((i + 2) * every).floor() + 1;
      avgRangeEnd = avgRangeEnd < data.length ? avgRangeEnd : data.length;

      var avgRangeLength = avgRangeEnd - avgRangeStart;

      for (; avgRangeStart < avgRangeEnd; avgRangeStart++) {
        avgX += sortedData[avgRangeStart].x;
        avgY += sortedData[avgRangeStart].y;
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      // Get the range for this bucket
      var rangeOffs = ((i + 0) * every).floor() + 1,
          rangeTo = ((i + 1) * every).floor() + 1;

      // Point a
      var pointAx = sortedData[a].x, // enforce Number (value may be Date)
          pointAy = sortedData[a].y;

      maxArea = area = -1;

      for (; rangeOffs < rangeTo; rangeOffs++) {
        // Calculate triangle area over three buckets
        area = ((pointAx - avgX) * (sortedData[rangeOffs].x - pointAy) -
                    (pointAx - sortedData[rangeOffs].x) * (avgY - pointAy))
                .abs() *
            0.5;
        if (area > maxArea) {
          maxArea = area;
          maxAreaPoint = data[rangeOffs];
          nextA = rangeOffs; // Next a is this b
        }
      }

      sampled[sampledIndex++] = maxAreaPoint;
      a = nextA; // This a is the next a (chosen b)
    }

    sampled[sampledIndex++] = data[data.length - 1]; // Always add last

    return sampled;
  }
}
