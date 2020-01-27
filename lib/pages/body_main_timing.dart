//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:enterprise/contatns.dart';
import 'package:enterprise/db.dart';
import 'package:enterprise/pages/page_main.dart';
import 'package:enterprise/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../models.dart';

class BodyMain extends StatefulWidget {
  final Profile profile;

  BodyMain(
    this.profile,
  );

  BodyMainState createState() => BodyMainState();
}

class BodyMainState extends State<BodyMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(widget.profile),
      body: TimingMain(),
    );
  }
}

class TimingMain extends StatefulWidget {
  @override
  _TimingMainState createState() => _TimingMainState();
}

class _TimingMainState extends State<TimingMain> {
  String currentTimeStatus = '';
  String userID;
  Future<List<Timing>> operations;
  Future<List<charts.Series<ChartData, String>>> listChartData;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWidgetState());
  }

  void _initWidgetState() async {
    final prefs = await SharedPreferences.getInstance();
    String _userID = prefs.getString(KEY_USER_ID) ?? "";

    operations = _getOperations(_userID);
    listChartData = _createChartData(operations);

    String _currentTimeStatus =
        await DBProvider.db.getTimingCurrentByUser(_userID);

    setState(() {
      userID = _userID;
      currentTimeStatus = _currentTimeStatus;
    });
  }

  Future<List<Timing>> _getOperations(String userID) async {
    final dateTimeNow = DateTime.now();
    final beginningDay = Utility.beginningOfDay(dateTimeNow);

    return await DBProvider.db.getUserTiming(beginningDay, userID);
  }

  Future<List<charts.Series<ChartData, String>>> _createChartData(
      Future<List<Timing>> listTiming) async {
    List<Timing> _listTiming = await listTiming;
    List<ChartData> _chartData = [];
    double timingHours = 0.0;

    for (var _timing in _listTiming) {
      if (_timing.operation == TIMING_STATUS_WORKDAY) {
        continue;
      }

      DateTime endDate = _timing.endDate;
      if (endDate == null) {
        endDate = DateTime.now();
      }

      double duration = (endDate.millisecondsSinceEpoch -
              _timing.startDate.millisecondsSinceEpoch) /
          3600000;
      timingHours += duration;

      int existIndex = _chartData
          .indexWhere((record) => record.title.contains(_timing.operation));
      if (existIndex == -1) {
        _chartData
            .add(new ChartData(title: _timing.operation, value: duration));
      } else {
        _chartData[existIndex].value += duration;
      }
    }

    for (var _record in _chartData) {
      _record.title = operationAlias[_record.title] +
          ' - ' +
          _record.value.toStringAsFixed(2) +
          ' год';
      _record.value =
          ((_record.value / timingHours * 100.0).round().toDouble());
    }

    return [
      new charts.Series<ChartData, String>(
        id: 'operation',
        domainFn: (ChartData record, _) => record.title,
        measureFn: (ChartData record, _) => record.value,
        data: _chartData,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (ChartData row, _) => '${row.title}: ${row.value}',
      )
    ];
  }

  handleOperation(String timingOperation) async {
    final dateTimeNow = DateTime.now();
    final dayBegin =
        new DateTime(dateTimeNow.year, dateTimeNow.month, dateTimeNow.day);

    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(KEY_USER_ID) ?? "";

    if (timingOperation == TIMING_STATUS_WORKDAY) {
      Timing timing = Timing(
        date: dayBegin,
        userID: userID,
        operation: timingOperation,
        startDate: dateTimeNow,
      );

      await DBProvider.db.newTiming(timing);
    } else if (timingOperation == '') {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }

      listTiming = await DBProvider.db.getTimingOpenWorkday(dayBegin, userID);
      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }
    } else if (timingOperation == TIMING_STATUS_JOB ||
        timingOperation == TIMING_STATUS_LANCH ||
        timingOperation == TIMING_STATUS_BREAK) {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }

      Timing timing = Timing(
          date: dayBegin,
          userID: userID,
          operation: timingOperation,
          startDate: dateTimeNow);

      await DBProvider.db.newTiming(timing);
    } else if (timingOperation == TIMING_STATUS_STOP) {
      List<Timing> listTiming =
          await DBProvider.db.getTimingOpenOperation(dayBegin, userID);

      for (var timing in listTiming) {
        timing.endDate = dateTimeNow;
        await DBProvider.db.endTimingOperation(timing);
      }
    }

    operations = _getOperations(userID);
    listChartData = _createChartData(operations);

    prefs.setString(KEY_CURRENT_STATUS, timingOperation);
    setState(() {
      currentTimeStatus = timingOperation;
    });
  }

  Map<String, String> operationAlias = {
    TIMING_STATUS_WORKDAY: "Турнікет",
    TIMING_STATUS_JOB: "Робота",
    TIMING_STATUS_LANCH: "Обід",
    TIMING_STATUS_BREAK: "Перерва",
  };

  String formatISO8601DataToTime(String strDataTime) {
    if (strDataTime.isEmpty) return "";

    DateTime _dateTime = DateTime.parse(strDataTime);
    return formatDate(_dateTime, [hh, ':', nn, ':', ss]);
  }

  Widget rowIcon(String operation) {
    switch (operation) {
      case TIMING_STATUS_WORKDAY:
        return Icon(FontAwesomeIcons.building);
      case TIMING_STATUS_JOB:
        return Icon(FontAwesomeIcons.hammer);
      case TIMING_STATUS_LANCH:
        return Icon(Icons.fastfood);
      case TIMING_STATUS_BREAK:
        return Icon(Icons.toys);
      default:
        return SizedBox(
          width: 24.0,
        );
    }
  }

  Widget dataTable(listTiming) {
    List<DataRow> dataRows = [];

    for (var timing in listTiming) {
      dataRows.add(DataRow(cells: <DataCell>[
        DataCell(Row(
          children: <Widget>[
            rowIcon(timing.operation),
            SizedBox(
              width: 10.0,
            ),
            Text(operationAlias[timing.operation]),
          ],
        )),
        DataCell(Text(timing.startDate != null
            ? formatDate(timing.startDate, [hh, ':', nn, ':', ss])
            : "")),
        DataCell(Text(timing.endDate != null
            ? formatDate(timing.endDate, [hh, ':', nn, ':', ss])
            : "")),
      ]));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Статус'),
          ),
          DataColumn(
            label: Text('Початок'),
          ),
          DataColumn(
            label: Text('Кінець'),
          )
        ],
        rows: dataRows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Хронометраж'),
            pinned: true,
            floating: false,
            expandedHeight: 300.0,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.history),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/timinghistory',
                    arguments: "",
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder(
                  future: listChartData,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                        return DonutAutoLabelChart(
                          snapshot.data,
                          animate: true,
                        );
                      default:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  }),
//              background: DonutAutoLabelChart.withSampleData(),
            ),
          ),
          SliverFillRemaining(
//            child: Center(
//              child: Text('Center text'),
//            ),
            child: ListView(children: [
              FutureBuilder(
                  future: operations,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                        return dataTable(snapshot.data);
                      default:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  }), //
            ]),
          ),
        ],
      ),
      floatingActionButton: TimingFAB(currentTimeStatus, (String value) {
        if (currentTimeStatus != value) {
          handleOperation(value);
        }
      }),
    );
  }
}

class TimingFAB extends StatefulWidget {
  final String timingStatus;
  final Function(String value) onPressed;

  TimingFAB(
    this.timingStatus,
    this.onPressed,
  );

  @override
  _TimingFABState createState() => _TimingFABState();
}

class _TimingFABState extends State<TimingFAB> {
  String currentTimingStatus;

  Widget workdayFAB() {
    return FloatingActionButton(
      onPressed: () {
        widget.onPressed(TIMING_STATUS_WORKDAY);
      },
      child: Icon(FontAwesomeIcons.building),
    );
  }

  SpeedDialChild jobSDC() {
    return SpeedDialChild(
      label: "Почати роботу",
      child: Icon(FontAwesomeIcons.hammer),
      onTap: () {
        widget.onPressed(TIMING_STATUS_JOB);
      },
    );
  }

  SpeedDialChild lanchSDC() {
    return SpeedDialChild(
      label: "Обід",
      child: Icon(Icons.fastfood),
      onTap: () {
        widget.onPressed(TIMING_STATUS_LANCH);
      },
    );
  }

  SpeedDialChild breakSDC() {
    return SpeedDialChild(
      label: "Перерва",
      child: Icon(Icons.toys),
      onTap: () {
        widget.onPressed(TIMING_STATUS_BREAK);
      },
    );
  }

  SpeedDialChild stopSDC() {
    return SpeedDialChild(
      label: "Завершити роботу",
      child: Icon(Icons.stop),
      onTap: () {
        setState(() {
          widget.onPressed(TIMING_STATUS_STOP);
        });
      },
    );
  }

  SpeedDialChild homeSDC() {
    return SpeedDialChild(
      label: "Турнікет (вихід)",
      child: Icon(Icons.home),
      onTap: () {
        setState(() {
          widget.onPressed('');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.timingStatus) {
      case '':
        return workdayFAB();
      case (TIMING_STATUS_WORKDAY):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            breakSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_STOP):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            breakSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_JOB):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            lanchSDC(),
            breakSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_LANCH):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            breakSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      case (TIMING_STATUS_BREAK):
        return SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          closeManually: false,
          children: [
            jobSDC(),
            lanchSDC(),
            stopSDC(),
            homeSDC(),
          ],
        );
      default:
        return workdayFAB();
    }
  }
}

class DonutAutoLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DonutAutoLabelChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutAutoLabelChart.withSampleData() {
    return new DonutAutoLabelChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        //
        // [ArcLabelDecorator] will automatically position the label inside the
        // arc if the label will fit. If the label will not fit, it will draw
        // outside of the arc with a leader line. Labels can always display
        // inside or outside using [LabelPosition].
        //
        // Text style for inside / outside can be controlled independently by
        // setting [insideLabelStyleSpec] and [outsideLabelStyleSpec].
        //
        // Example configuring different styles for inside/outside:
        //       new charts.ArcLabelDecorator(
        //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
        //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 100,
            startAngle: 30,
            arcRendererDecorators: [new charts.ArcLabelDecorator()]));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, String>> _createSampleData() {
    final data = [
      new LinearSales('рообота', 100),
      new LinearSales('обід', 75),
      new LinearSales('перерви', 25),
    ];

    return [
      new charts.Series<LinearSales, String>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearSales row, _) => '${row.year}: ${row.sales}',
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final String year;
  final int sales;

  LinearSales(this.year, this.sales);
}
