// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

class DynamicPieChart extends StatefulWidget {
  const DynamicPieChart({
    Key? key,
    this.width,
    this.height,
    required this.goodValue,
    required this.badValue,
    this.goodColor,
    this.badColor,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double goodValue;
  final double badValue;
  final Color? goodColor;
  final Color? badColor;

  @override
  _DynamicPieChartState createState() => _DynamicPieChartState();
}

class _DynamicPieChartState extends State<DynamicPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final totalValue = widget.goodValue + widget.badValue;
    final goodPercentage =
        totalValue > 0 ? (widget.goodValue / totalValue) * 100 : 0;

    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Teks Persentase di Tengah
          Text(
            '${goodPercentage.toStringAsFixed(0)}%',
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  fontFamily: 'Roboto',
                  color:
                      widget.goodColor ?? FlutterFlowTheme.of(context).success,
                  fontWeight: FontWeight.bold,
                ),
          ),
          // Pie Chart
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2, // Jarak antar slice
              centerSpaceRadius: 80, // Ukuran lubang donat
              sections: showingSections(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      // Efek "explode" jika disentuh atau untuk data "Bad"
      final double radius = isTouched ? 110.0 : 100.0;
      final double fontSize = isTouched ? 20.0 : 16.0;

      switch (i) {
        case 0: // Good Data
          return PieChartSectionData(
            color: widget.goodColor ?? FlutterFlowTheme.of(context).success,
            value: widget.goodValue,
            title:
                '${(widget.goodValue / (widget.goodValue + widget.badValue) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 1: // Bad Data
          return PieChartSectionData(
            color: widget.badColor ?? FlutterFlowTheme.of(context).error,
            value: widget.badValue,
            title:
                '${(widget.badValue / (widget.goodValue + widget.badValue) * 100).toStringAsFixed(0)}%',
            radius: radius + 5, // Sedikit lebih besar untuk menonjol
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Error();
      }
    });
  }
}
