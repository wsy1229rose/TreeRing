import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treering/models/mood_entry.dart';
import 'package:treering/models/moodidi_entry.dart';
import 'package:treering/models/moodidi.dart';
import 'package:treering/utils/data_normalization.dart';
import 'package:treering/db/database_helper.dart';
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
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  // Offset? _tooltipOffset;
  // TooltipType? _tooltipType;
  // MoodEntry? _tappedEntry;
  // double? _tappedAvgValue;

  late List<MoodEntry> _moodEntries;
    late List<FlSpot> _cumulativeAvgSpots;
  late double _avg;

  late List<double> _normalizedMoodidiEntries;

  late List<FlSpot> _moodSpots;
  late List<FlSpot> _yesSpots;
  late List<FlSpot> _yesAvgSpots;
  late List<FlSpot> _noSpots;
  late List<FlSpot> _noAvgSpots;

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
    List<double> normalizedMoodidiEntries = [];
    final yesSpots = <FlSpot>[];
    final yesAvgSpots = <FlSpot>[];
    final noSpots = <FlSpot>[];
    final noAvgSpots = <FlSpot>[];

    moodEntries = (await DatabaseHelper.instance.getAllMoodEntries()).take(widget.visibleCount).toList().reversed.toList();

    if (widget.selectedMoodidi != null) {
      if (widget.selectedMoodidi!.isNumeric) {
        List<MoodidiEntry> moodidiEntries = [];
        
        moodidiEntries = (await DatabaseHelper.instance.getAllMoodidiEntries(widget.selectedMoodidi!.keyword)).take(widget.visibleCount).toList().reversed.toList();
        //debugPrint('[LINE_CHART_moodidiEntries] got ${moodidiEntries.length} moodidi entries');
        final moodList = moodEntries.map((e) => e.rating.toDouble()).toList();
        final moodidiList = moodidiEntries.map((e) => e.entry.toDouble()).toList();
        normalizedMoodidiEntries = normalizeSeries(original: moodList, series: moodidiList);

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
        yesAvgSpots.addAll(yesSpots.map((s) => FlSpot(s.x, yesAvg)));

        final noAvg = noSpots.isNotEmpty
            ? noSpots.map((s) => s.y).reduce((a, b) => a + b) / noSpots.length
            : 0.0;
        noAvgSpots.addAll(noSpots.map((s) => FlSpot(s.x, noAvg)));
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
      _normalizedMoodidiEntries = normalizedMoodidiEntries;
      _yesSpots = yesSpots;
      _yesAvgSpots = yesAvgSpots;
      _noSpots = noSpots;
     _noAvgSpots = noAvgSpots;
      _moodSpots = moodSpots;
      _cumulativeAvgSpots = cumulativeAvgSpots;
      _avg = avg;
    });
  }


@override
Widget build(BuildContext context) {
  return SizedBox(
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
              color: const Color.fromARGB(255, 34, 33, 146),
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(                      // No entries
              spots: _noSpots,
              color: const Color.fromARGB(255, 235, 177, 20),
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(                      // No Avg entries
              spots: _yesAvgSpots,
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
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(                    // normalized
              spots: List.generate(_normalizedMoodidiEntries.length,
                (i) => FlSpot(i.toDouble(), _normalizedMoodidiEntries[i]),
              ),
              color: Colors.deepPurple,
              isCurved: true,
              dotData: FlDotData(show: true),
            ),
          ] else ...[
            LineChartBarData(                     // mood plot
              spots: _moodSpots,
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
        ],
      ),
    ),
  );
}


  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<List<dynamic>>(
  //     future: Future.wait([_allMoodEntriesFuture,
  //     _allMoodidiEntriesFuture ?? Future.value([]), // fallback if null
  //     ]),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(child: Text('No data yet.'));
  //       }        
  //       return FutureBuilder<List<double>>(
  //         future: _normalizedMoodidiEntries,
  //         builder: (context, normSnapshot) {
  //  //         final normalizedMoodidiValues = normSnapshot.data ?? [];

  //           return Container(
  //             height: 470,
       /*       child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      lineBarsData: [
                          if (widget.selectedMoodidi != null && !widget.selectedMoodidi!.isNumeric) ...[
                          LineChartBarData(                     // yes mood plot
                            // spots: yesEntries
                            //     .map((e) => FlSpot(e.timestamp.millisecondsSinceEpoch.toDouble(), e.rating.toDouble()))
                            //     .toList(),
                            spots: List.generate(yesEntries.length,
                              (i) => FlSpot(i.toDouble(), yesEntries[i].entry.toDouble())
                            ),
                            color: const Color.fromARGB(255, 55, 188, 250),
                            dotData: FlDotData(show: true),
                          ),
                          LineChartBarData(                     // no mood plot
                            spots: List.generate(noEntries.length,
                              (i) => FlSpot(i.toDouble(), noEntries[i].entry.toDouble())
                            ),
                            color: Colors.lightGreen,
                            dotData: FlDotData(show: true),
                          ),
                        ] else if (widget.selectedMoodidi != null && widget.selectedMoodidi!.isNumeric) ...[
                          LineChartBarData(                     // mood plot
                            spots: spots,
                            color: const Color.fromARGB(255, 11, 125, 218),
                            dotData: FlDotData(show: true),
                          ),
                          LineChartBarData(                     // normalized moodidi plot
                            spots: List.generate(
                              normalizedMoodidiValues.length,
                              (i) => FlSpot(i.toDouble(), normalizedMoodidiValues[i],
                              ),
                            ),
                            isCurved: true,
                            color: const Color.fromARGB(255, 238, 109, 152),
                            dotData: FlDotData(show: true),
                          ),
                        ] else ...[
                          LineChartBarData(                     // mood plot
                            spots: spots,
                            barWidth: 2,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(                     // avg
                            spots: List.generate(
                              spots.length,
                              (i) => FlSpot(spots[i].x, avg),
                            ),
                            barWidth: 1.5,
                            color: Colors.grey,
                            dashArray: [5, 5],
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(                      // culmulative
                            spots: cumulativeAvgSpots,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.yellow.shade200,
                            dotData: const FlDotData(show: false),
                          ),
                        ] 
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
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),                       
                      // LineTouch
                      lineTouchData: LineTouchData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchSpots.map((spots) {
                            final entry = entries[spot.x.toInt()];
                            final buffer = StringBuffe();

                            // Line 1: Mood
                            buffer.writeln('Mood: ${entry.rating}');

                            // Line 2: Avg
                            buffer.writeln('Avg: ${spot.y.toStringAsFixed(2)}');

                            // (Optional) Line 3: Cumulative Avg, if you're calculating it:
                            // buffer.writeln('Cum. Avg: ${...}');

                            // Line 4: Description
                            if (entry.description?.isNotEmpty == true) {
                              buffer.writeln('Note: ${entry.description!}');
                            }

                            return LineTooltipItem(
                              buffer.toString(), // ✅ plain string
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        } */

                    /*    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
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