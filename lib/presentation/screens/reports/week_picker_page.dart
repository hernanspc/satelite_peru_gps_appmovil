import 'dart:io';

import 'package:flutter/material.dart';

import 'package:excel/excel.dart' as xcel;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:satelite_peru_gps/domains/models/autos_models/ReportsReponse.dart';
import 'package:satelite_peru_gps/presentation/components/buttons/CustomShareButton.dart';
import 'package:satelite_peru_gps/presentation/components/buttons/rounded_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../color_picker_dialog.dart';
import '../color_selector_btn.dart';
import '../event.dart';

/// Page with the [WeekPicker].
class WeekPickerPage extends StatefulWidget {
  /// Custom events.
  final List<Event> events;

  ///
  const WeekPickerPage({Key? key, this.events = const []}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeekPickerPageState();
}

class _WeekPickerPageState extends State<WeekPickerPage> {
  DateTime _selectedDate = DateTime.now();
  // final DateTime _firstDate = DateTime.now().subtract(Duration(days: 45));
  DateTime _firstDate =
      DateTime.now().subtract(Duration(days: 365)); // 1 año atrás
  // final DateTime _lastDate = DateTime.now().add(Duration(days: 45));
  DateTime _lastDate = DateTime.now(); // Hoy

  DatePeriod? _selectedPeriod;

  Color selectedPeriodStartColor = Colors.blue;
  Color selectedPeriodLastColor = Colors.green;
  Color selectedPeriodMiddleColor = Colors.blue;

  CarsService carsService = CarsService();
  List<Map<String, dynamic>> reportData = [];
  bool _isLoading = false;

  bool _isTableVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedPeriodLastColor = Colors.lightGreen.withOpacity(0.8);
    selectedPeriodMiddleColor = Colors.lightGreen.withOpacity(0.4);
    selectedPeriodStartColor = Colors.lightGreen.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    final String placaVehiculo = extra['placa'] as String;
    final int vehiculo_id = extra['vehiculo_id'] as int;

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    DatePickerRangeStyles styles = DatePickerRangeStyles(
      displayedPeriodTitle: TextStyle(
        color: isLightMode ? Colors.black : Colors.white,
      ),
      selectedPeriodLastDecoration: BoxDecoration(
          color: selectedPeriodLastColor,
          borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(10.0), bottomEnd: Radius.circular(10.0))),
      selectedPeriodStartDecoration: BoxDecoration(
        color: selectedPeriodStartColor,
        borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(10.0),
            bottomStart: Radius.circular(10.0)),
      ),
      selectedPeriodMiddleDecoration: BoxDecoration(
        color: selectedPeriodMiddleColor,
        shape: BoxShape.rectangle,
      ),
      dayHeaderStyle: const DayHeaderStyle(
        textStyle: TextStyle(
          color: Color(0xff6456FF),
          fontWeight: FontWeight.bold,
        ),
      ),
      defaultDateTextStyle: TextStyle(
        color: isLightMode ? Colors.black : Colors.white,
      ),
    );

    void _showErrorDialog(BuildContext context) {
      showDialog(
        context: context,
        // barrierDismissible:
        //     false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Center(child: Text('¡Ocurrió un error!')),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Icon(Icons.error, color: Colors.red, size: 48.0),
                  SizedBox(height: 16.0),
                  Center(child: Text('No se pudo obtener el reporte.')),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void hanldleVueltasKilometraje(BuildContext context, int vehiculoId) async {
      DateTime dateTime = DateTime.parse(_selectedDate.toString());
      String formattedDateStart = DateFormat('yyyy-MM-dd').format(dateTime);

      DateTime dateTimeEnd = DateTime.parse(_selectedPeriod!.end.toString());
      String formattedDateEnd = DateFormat('yyyy-MM-dd').format(dateTimeEnd);

      setState(() {
        _isLoading = true;
      });

      ReportResponse? response = await carsService.getReportBus(
        idVehiculo: vehiculoId,
        fecha: formattedDateStart,
        fechaEnd: formattedDateEnd,
        type: 'week',
      );

      setState(() {
        _isLoading = false;
      });

      if (response != null && response.success) {
        final reporte = response.reporte;
        setState(() {
          reportData = [
            {
              "placa": reporte.placa,
              "reporte_kilometraje": reporte.reporteKilometraje,
              "reporte_fecha_desde": reporte.reporteFechaDesde,
              "reporte_fecha_hasta": reporte.reporteFechaHasta,
              "type": reporte.type,
              "km_vuelta": reporte.flota.kmVuelta
            }
          ];
        });
        print('Reporte: ${reporte.toJson()}');
        _isTableVisible = true; // Mostrar la tabla después de cargar los datos
      } else {
        print('No se pudo obtener el reporte.');
        _isTableVisible = false; // Ocultar la tabla si hay error
        _showErrorDialog(context);
      }
    }

    Future<void> exportToExcel() async {
      // Solicitar permisos
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permiso de almacenamiento denegado');
        return;
      }

      var excel = xcel.Excel.createExcel();
      xcel.Sheet sheetObject = excel['Sheet1'];
      sheetObject.appendRow(["Placa", "Fecha", "Km recorrido", "Vueltas"]);

      for (var item in reportData) {
        sheetObject.appendRow(
          [
            item["placa"],
            '${item["reporte_fecha_desde"].toString().substring(0, 10)}\nhasta\n${_selectedPeriod!.end.toString().substring(0, 10).substring(0, 10)}',
            item["reporte_kilometraje"].toStringAsFixed(2),
            item["km_vuelta"],
          ],
        );
      }

      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/report.xlsx';
      File file = File(filePath);
      file.writeAsBytesSync(excel.encode()!);
      OpenFile.open(filePath);
      print("Excel file saved at $filePath");
    }

    Future<void> exportToPdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ["Placa", "Fecha", "Km recorrido", "Vueltas"],
              cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              data: reportData.map((item) {
                final int vueltas = (item['reporte_kilometraje'] != null &&
                        item['km_vuelta'] != null &&
                        item['km_vuelta'] > 0)
                    ? (item['reporte_kilometraje'] / item['km_vuelta']).floor()
                    : 0;

                return [
                  item["placa"],
                  '${item["reporte_fecha_desde"].toString().substring(0, 10)}\nhasta\n${_selectedPeriod!.end.toString().substring(0, 10).substring(0, 10)}',
                  item["reporte_kilometraje"].toStringAsFixed(2),
                  vueltas,
                ];
              }).toList(),
            );
          },
        ),
      );

      // Obtiene el directorio donde se guardará el archivo
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/report.pdf';
      File file = File(filePath);

      // Guarda el archivo PDF en el sistema de archivos
      await file.writeAsBytes(await pdf.save());

      print("PDF file saved at $filePath");

      // Comparte el archivo PDF usando share_plus
      // await Share.shareXFiles([file.path], text: '¡Mira este archivo PDF!');
      await Share.shareXFiles([XFile(file.path)],
          text: '¡Mira este archivo PDF!');
    }

    bool isEqualsDateSelected = reportData.length > 0
        ? reportData[0]["reporte_fecha_desde"].toString().substring(0, 10) ==
            _selectedDate.toString().substring(0, 10)
        : false;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WeekPicker(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
            onSelectionError: _onSelectionError,
            eventDecorationBuilder: _eventDecorationBuilder,
            selectableDayPredicate: (DateTime day) {
              return day.isBefore(_lastDate) || day.isAtSameMomentAs(_lastDate);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RoundedButton(
                  isDisabled: _isLoading || isEqualsDateSelected ? true : false,
                  text: 'Buscar',
                  color: const Color(0xff6456FF),
                  isLoading: _isLoading,
                  press: () {
                    hanldleVueltasKilometraje(context, vehiculo_id);
                  },
                ),
                const SizedBox(height: 10.0),
                _isLoading
                    ? SkeletonLoader(
                        builder: Column(
                        children: List.generate(
                          2, // Número de filas de carga
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(child: _buildSkeletonCell()),
                                Expanded(child: _buildSkeletonCell()),
                                Expanded(child: _buildSkeletonCell()),
                                Expanded(child: _buildSkeletonCell()),
                              ],
                            ),
                          ),
                        ),
                      ))
                    : _isTableVisible || isEqualsDateSelected
                        ?
                        // reportData.isNotEmpty
                        Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildHeaderRow(isLightMode),
                                    ..._buildDataRows(
                                        placaVehiculo, isLightMode),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                      child: CustomShareButton(
                                        isLightMode: isLightMode,
                                        onPressed: () async {
                                          await exportToPdf();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : Center(
                            child: Text(
                              'Seleccione una fecha y haga click en buscar',
                              style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white,
                              ),
                            ),
                          )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCell() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: 24.0,
    );
  }

  Widget _buildHeaderRow(bool isLightMode) {
    final styleTitle = TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: isLightMode ? Colors.black : Colors.white,
    );

    return Row(
      children: [
        _buildCell('Placa', textStyle: styleTitle),
        _buildCell('Fecha', textStyle: styleTitle),
        _buildCell('Km', textStyle: styleTitle),
        _buildCell('Vueltas', textStyle: styleTitle),
      ],
    );
  }

  List<Widget> _buildDataRows(String placaVehiculo, bool isLightMode) {
    return reportData.map((item) {
      int vueltas = (item['reporte_kilometraje'] / item['km_vuelta']).floor();

      DateTime dateTime =
          DateTime.parse(item['reporte_fecha_desde'].toString());
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      final styleCampos = TextStyle(
        fontSize: 14.0,
        color: isLightMode ? Colors.black : Colors.white,
      );

      return Row(
        children: [
          _buildCell(
            placaVehiculo,
            textStyle: styleCampos,
            hideBottom: true,
          ),
          _buildCell(
              '${formattedDate}\nhasta\n${_selectedPeriod!.end.toString().substring(0, 10)}',
              textStyle: styleCampos,
              hideBottom: true),
          _buildCell(item['reporte_kilometraje'].toStringAsFixed(2),
              textStyle: styleCampos, hideBottom: true),
          _buildCell(vueltas.toString(),
              textStyle: styleCampos, hideBottom: true),
        ],
      );
    }).toList();
  }

  Widget _buildCell(
    String text, {
    bool hideBottom = false,
    TextStyle? textStyle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
                color: Colors.grey.shade300, width: 0.5), // Borde derecho
            bottom: hideBottom
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: textStyle ??
                TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
          ),
        ),
      ),
    );
  }

  // block witt color buttons insede
  Widget _stylesBlock() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ColorSelectorBtn(
                title: "Inicio",
                color: selectedPeriodStartColor,
                showDialogFunction: _showSelectedStartColorDialog),
            const SizedBox(width: 12.0),
            ColorSelectorBtn(
                title: "Medio",
                color: selectedPeriodMiddleColor,
                showDialogFunction: _showSelectedMiddleColorDialog),
            const SizedBox(width: 12.0),
            ColorSelectorBtn(
                title: "Final",
                color: selectedPeriodLastColor,
                showDialogFunction: _showSelectedEndColorDialog),
          ],
        ),
      );

  // Block with  information about selected date
  // and boundaries of the selected period.
  Widget _selectedBlock() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _selectedPeriod != null
              ? Column(children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text("Selected period boundaries:"),
                  ),
                  Text(_selectedPeriod!.start.toString()),
                  Text(_selectedPeriod!.end.toString()),
                ])
              : Container()
        ],
      );

  // select background color for the first date of the selected period
  void _showSelectedStartColorDialog() async {
    Color? newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodStartColor,
            ));

    if (newSelectedColor != null) {
      setState(() {
        selectedPeriodStartColor = newSelectedColor;
      });
    }
  }

  // select background color for the last date of the selected period
  void _showSelectedEndColorDialog() async {
    Color? newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodLastColor,
            ));

    if (newSelectedColor != null) {
      setState(() {
        selectedPeriodLastColor = newSelectedColor;
      });
    }
  }

  // select background color for the middle dates of the selected period
  void _showSelectedMiddleColorDialog() async {
    Color? newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedPeriodMiddleColor,
            ));

    if (newSelectedColor != null) {
      setState(() {
        selectedPeriodMiddleColor = newSelectedColor;
      });
    }
  }

  void _onSelectedDateChanged(DatePeriod newPeriod) {
    setState(() {
      _selectedDate = newPeriod.start;
      _selectedPeriod = newPeriod;
      _isTableVisible = false;
    });
  }

  void _onSelectionError(Object e) {
    if (e is UnselectablePeriodException) print("catch error: $e");
  }

// ignore: prefer_expression_function_bodies
  bool _isSelectableCustom(DateTime day) {
//    return day.weekday < 6;
    return day.day != DateTime.now().add(Duration(days: 7)).day;
  }

  EventDecoration? _eventDecorationBuilder(DateTime date) {
    List<DateTime> eventsDates =
        widget.events.map<DateTime>((e) => e.date).toList();

    bool isEventDate = eventsDates.any((d) =>
        date.year == d.year && date.month == d.month && d.day == date.day);

    if (!isEventDate) return null;

    BoxDecoration roundedBorder = BoxDecoration(
        color: Colors.red[100],
        border: Border.all(
          color: Colors.red,
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.0)));

    TextStyle? whiteText =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);

    return isEventDate
        ? EventDecoration(boxDecoration: roundedBorder, textStyle: whiteText)
        : null;
  }
}
