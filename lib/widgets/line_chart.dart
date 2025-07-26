import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/utils/data_normalization.dart';
import 'package:treering/db/database_helper.dart';
import 'compute_stats.dart';
import 'package:treering/widgets/tooltip.dart';

enum TooltipType { mood, avgChange }

class LineChartWidget extends StatefulWidget {
  final Moodidi? selectedMoodidi;
  final int visibleCount;

  //final Widget Function(MoodEntry entry) buildMoodTooltip;
  //final Widget Function(double value) buildAvgTooltip;

  const LineChartWidget({
    Key? key,
    required this.selectedMoodidi,
    required this.visibleCount,
    //required this.buildMoodTooltip,
    //required this.buildAvgTooltip,
  }) : super(key: key);

  @override
  State<LineChartWidget> createState() => LineChartWidgetState();
}

class LineChartWidgetState extends State<LineChartWidget> {
  Offset? _tooltipOffset;
  MoodEntry? _tappedEntry;
  bool _showTooltip = false;

  late List<MoodEntry> _moodEntries;
  late List<FlSpot> _cumulativeAvgSpots;
  late double _avg;

  late List<FlSpot> _normalizedSpots;

  late List<FlSpot> _moodSpots;
  late List<FlSpot> _yesSpots;
  late List<FlSpot> _yesAvgSpots;
  late List<FlSpot> _noSpots;
  late List<FlSpot> _noAvgSpots;
  


  // Public read-only accessors:
  List<FlSpot> get moodSpots => _moodSpots;
  List<FlSpot> get yesSpots => _yesSpots;
  List<FlSpot> get noSpots => _noSpots;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the selectedMoodidi has changed
    if (oldWidget.selectedMoodidi != widget.selectedMoodidi) {
      _loadData();
    }
  }


  Future<void> _loadData() async {
    List<MoodEntry> moodEntries = [];
    final yesSpots = <FlSpot>[];
    final yesAvgSpots = <FlSpot>[];
    final noSpots = <FlSpot>[];
    final noAvgSpots = <FlSpot>[];
    //List<FlSpot> normalizedSpots = [];

    moodEntries = (await DatabaseHelper.instance.getAllMoodEntries()).take(widget.visibleCount).toList().reversed.toList();

    if (widget.selectedMoodidi != null) {
      if (widget.selectedMoodidi!.isNumeric) {
        // Normalized moodidiEntries curve 
        final keyword = widget.selectedMoodidi!.keyword;
        final moodVals = moodEntries.map((e) => e.rating.toDouble()).toList();
        final moodidiRawVals = moodEntries.map((e) => e.responses?[keyword]).toList();

        final normalizedSpots = normalizeSeries(
          original: moodVals,
          rawSeries: moodidiRawVals,
        );

        setState(() {
          _normalizedSpots = normalizedSpots;
        });

      } else {     
        for (int i = 0; i < moodEntries.length; i++) {
          final entry = moodEntries[i];
          final x = i.toDouble();
          final y = entry.rating.toDouble();
          final key = widget.selectedMoodidi!.keyword;

          if (entry.responses?[key] == true) {
            yesSpots.add(FlSpot(x, y));
          } else if (entry.responses?[key] == false) {
            noSpots.add(FlSpot(x, y));
          }
        }

        final yesAvg = yesSpots.isNotEmpty
            ? yesSpots.map((s) => s.y).reduce((a, b) => a + b) / yesSpots.length
            : 0.0;
        final noAvg = noSpots.isNotEmpty
            ? noSpots.map((s) => s.y).reduce((a, b) => a + b) / noSpots.length
            : 0.0;
        
        final int lastX = moodEntries.length - 1;

        yesAvgSpots.addAll([
          FlSpot(0, yesAvg),
          FlSpot(lastX.toDouble(), yesAvg),
        ]);
        noAvgSpots.addAll([
          FlSpot(0, noAvg),
          FlSpot(lastX.toDouble(), noAvg),
        ]);

        setState(() {
          _yesSpots = yesSpots;
          _yesAvgSpots = yesAvgSpots;
          _noSpots = noSpots;
          _noAvgSpots = noAvgSpots;
        });
      }
    }

    final avg = moodEntries.isEmpty
        ? 0.0
        : moodEntries.map((e) => e.rating).reduce((a, b) => a + b) / moodEntries.length;

    final moodSpots = <FlSpot>[];
    final cumulativeAvgSpots = <FlSpot>[];
    double sum = 0;
    for (int i = 0; i < moodEntries.length; i++) {
      final r = moodEntries[i].rating.toDouble();
      moodSpots.add(FlSpot(i.toDouble(), r));
      sum += r;
      cumulativeAvgSpots.add(FlSpot(i.toDouble(), sum / (i + 1)));
    }

    setState(() {
      _moodEntries = moodEntries;
      _moodSpots = moodSpots;
      _cumulativeAvgSpots = cumulativeAvgSpots;
      _avg = avg;
    });
  }

  Widget _buildLegend() {
    final legendItems = <Widget>[];

    // Case 1: Default mood plot
    if (widget.selectedMoodidi == null) {
      legendItems.addAll([
        _legendItem(Colors.green, 'Mood'),
        _legendItem(Colors.yellow.shade200, 'Cumulative Avg'),
        _legendItem(const Color.fromARGB(255, 136, 136, 136), 'Average'),
      ]);
    }

    // Case 2: Yes/No moodidi selected
    else if (!widget.selectedMoodidi!.isNumeric) {
      final keyword = widget.selectedMoodidi!.keyword;
      legendItems.addAll([
        _legendItem(const Color.fromARGB(255, 27, 155, 214), 'Moodidi $keyword - yes'),
        _legendItem(const Color.fromARGB(255, 8, 70, 179), 'yes line avg'),
        _legendItem(Colors.orangeAccent, 'Moodidi $keyword - no'),
        _legendItem(const Color.fromARGB(255, 167, 97, 17), 'no line avg'),
      ]);
    }

    // Case 3: Numeric moodidi selected (show mood plot + normalized curve)
    else if (widget.selectedMoodidi!.isNumeric) {
      final keyword = widget.selectedMoodidi!.keyword;
      legendItems.addAll([
        _legendItem(Colors.green, 'Mood'),
        _legendItem(Colors.grey, 'Average'),
        _legendItem(const Color.fromARGB(255, 20, 186, 236), 'Normalized\n$keyword'),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: legendItems,
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_moodEntries.isEmpty) {
      return const SizedBox(
        height: 470,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 470,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(                     // avg
                      spots: List.generate(
                        _moodSpots.length,
                        (i) => FlSpot(_moodSpots[i].x, _avg),
                      ),
                      barWidth: 1.5,
                      color: Colors.grey,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                    if (widget.selectedMoodidi != null && !widget.selectedMoodidi!.isNumeric) ...[
                      LineChartBarData(                      // yes entries
                        spots: _yesSpots,
                        color: const Color.fromARGB(255, 27, 155, 214),
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(                      // yes Avg entries
                        spots: _yesAvgSpots,
                        barWidth: 1.5,
                        color: const Color.fromARGB(255, 47, 44, 206),
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(                      // No entries
                        spots: _noSpots,
                        color: const Color.fromARGB(255, 235, 177, 20),
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(                      // No Avg entries
                        spots: _noAvgSpots,
                        barWidth: 1.5,
                        color: const Color.fromARGB(255, 167, 97, 17),
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                    ] else if (widget.selectedMoodidi != null && widget.selectedMoodidi!.isNumeric) ...[
                      LineChartBarData(                     // mood plot
                        spots: List.generate(_moodEntries.length,
                          (i) => FlSpot(i.toDouble(), _moodEntries[i].rating.toDouble()),
                        ),
                        color:  Colors.green,
                        dotData: FlDotData(show: true),
                      ),
                      LineChartBarData(                    // normalized
                        // spots: List.generate(_normalizedMoodidiEntries.length,
                        //   (i) => FlSpot(i.toDouble(), _normalizedMoodidiEntries[i]),
                        // ),
                        spots: _normalizedSpots,
                        dotData: FlDotData(show: false),
                        isCurved: true,
                      ),
                    ] else ...[
                      LineChartBarData(                     // mood plot
                        spots: _moodSpots,
                        color:  Colors.green,
                        barWidth: 2,
                        dotData: const FlDotData(show: true),
                      ),
                      LineChartBarData(                      // culmulative
                        spots: _cumulativeAvgSpots,
                        isCurved: true,
                        barWidth: 2,
                        color: Colors.yellow.shade200,
                        dotData: const FlDotData(show: false),
                      ),
                    ] 
                    // axis
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (widget.visibleCount / 7).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(
                            "${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                      final spot = response?.lineBarSpots?.first;

                      if (spot != null && event is FlLongPressStart || event is FlTapDownEvent) {
                        setState(() {
                          _tooltipOffset = event.localPosition;
                          _tappedEntry = _moodEntries[spot!.x.toInt()];
                          _showTooltip = true;
                        });
                      } else if (event is FlLongPressEnd || event is FlPanEndEvent || event is FlTapUpEvent) {
                        setState(() {
                          _showTooltip = false;
                        });
                      }
                    },
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((index) => null).toList();
                    }, // optional
                    //touchTooltipData: LineTouchTooltipData(tooltipPadding: EdgeInsets.zero, tooltipMargin: 0),
                    touchTooltipData: LineTouchTooltipData(
                      tooltipMargin: 0,
                      tooltipPadding: EdgeInsets.zero,
                      getTooltipItems: (_) => [],
                    ),
                  ),
                ),
              ),
            ),
            if (_showTooltip && _tooltipOffset != null && _tappedEntry != null)
              Positioned(
                left: _tooltipOffset!.dx,
                top: _tooltipOffset!.dy - 100,
                child: buildMoodTooltip(context, _tappedEntry!),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: _buildLegend(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ComputeStats(moodidi: widget.selectedMoodidi),
      ],
    );
  }

      /*  lineTouchData: LineTouchData(
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (!event.isInterestedForInteractions  || response == null) return;
            final spot = response.lineBarSpots?.first;  
            if (spot != null) {
              final barIndex = spot.barIndex;// Optional: prevent overflow

              setState(() {
                _tooltipOffset = event.localPosition;
                _tooltipType = TooltipType.mood;
                _tappedEntry = _moodEntries[spot.x.toInt()];
                if (barIndex == 0) {
                //_tooltipType = TooltipType.avg;
                // } else if (barIndex == 1) {
                //   _tooltipType = TooltipType.moodidi;
                //   _tappedMoodidiValue = normalizedMoodidiValues[spot.x.toInt()];
                } else {
                  _tooltipType = null;
                }
              });
            }             
          },
        ) */


  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<List<dynamic>>(
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(child: Text('No data yet.'));
  //       }        
  //       return FutureBuilder<List<double>>(
  //         future: _normalizedMoodidiEntries,
  //         builder: (context, normSnapshot) {
  //           final normalizedMoodidiValues = normSnapshot.data ?? [];

  //           return Container(
  //             height: 470,
       /*       child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      lineBarsData: [
                      ], 


                        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                          if (!event.isInterestedForInteractions  || response == null) return;
                          final spot = response.lineBarSpots?.first;  
                          if (spot != null) {
                            //final barIndex = spot.barIndex;// Optional: prevent overflow

                            setState(() {
                              _tooltipOffset = event.localPosition;
                              _tooltipType = TooltipType.mood;
                              _tappedEntry = moodEntries[spot.x.toInt()];
                              // if (barIndex == 0) {
                              //   _tooltipType = TooltipType.mood;
                              // // } else if (barIndex == 1) {
                              // //   _tooltipType = TooltipType.moodidi;
                              // //   _tappedMoodidiValue = normalizedMoodidiValues[spot.x.toInt()];
                              // } else {
                              //   _tooltipType = null;
                              // }
                            });
                          }             
                        },
                      ),

                    ),
                  ),    */
                 /* if (_tooltipOffset != null)
                    Positioned(
                      left: (_tooltipOffset!.dx).clamp(8.0, MediaQuery.of(context).size.width - 150),
                      top: (_tooltipOffset!.dy).clamp(8.0, MediaQuery.of(context).size.height - 150),
                      child: _tooltipType == TooltipType.mood
                        ? widget.buildMoodTooltip(_tappedEntry!)
                        : widget.buildAvgTooltip(_tappedAvgValue!),
                    ), 
                ],
              ),*/
//             );
//           },
//         );
//       },
//     );
//   }
// 
}