import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xcel;
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:satelite_peru_gps/data/services/cars_service.dart';
import 'package:satelite_peru_gps/domains/models/autos_models/ReportsReponse.dart';
import 'package:satelite_peru_gps/presentation/components/buttons/rounded_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../color_picker_dialog.dart';
import '../color_selector_btn.dart';

/// Page with the [dp.MonthPicker].
class MonthPickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MonthPickerPageState();
}

class _MonthPickerPageState extends State<MonthPickerPage> {
  final DateTime _firstDate = DateTime.now().subtract(Duration(days: 350));
  final DateTime _lastDate = DateTime.now().add(Duration(days: 350));
  DateTime _selectedDate = DateTime.now();

  Color selectedDateStyleColor = Colors.blue;
  Color selectedSingleDateDecorationColor = Colors.red;

  CarsService carsService = CarsService();
  List<Map<String, dynamic>> reportData = [];
  bool _isLoading = false;

  bool _isTableVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedDateStyleColor = Theme.of(context).colorScheme.onSecondary;
    selectedSingleDateDecorationColor = Colors.lightGreen.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
    final String placaVehiculo = extra['placa'] as String;
    final int vehiculo_id = extra['vehiculo_id'] as int;

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;

    dp.DatePickerStyles styles = dp.DatePickerStyles(
      displayedPeriodTitle: TextStyle(
        color: isLightMode ? Colors.black : Colors.white,
      ),
      selectedDateStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: selectedDateStyleColor,
          ),
      selectedSingleDateDecoration: BoxDecoration(
        color: selectedSingleDateDecorationColor,
        shape: BoxShape.circle,
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
      String formattedDateStart = DateFormat('yyyy-MM').format(dateTime);

      setState(() {
        _isLoading = true;
      });

      ReportResponse? response = await carsService.getReportBus(
        idVehiculo: vehiculoId,
        fecha: formattedDateStart,
        type: 'month',
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
            '${item["reporte_fecha_desde"].toString().substring(0, 10)}}',
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

    // Future<void> exportToPdf() async {
    //   final pdf = pw.Document();

    //   pdf.addPage(
    //     pw.Page(
    //       build: (pw.Context context) {
    //         return pw.Table.fromTextArray(
    //           headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    //           headers: ["Placa", "Fecha", "Km recorrido", "Vueltas"],
    //           data: reportData
    //               .map(
    //                 (item) => [
    //                   item["placa"],
    //                   '${item["reporte_fecha_desde"].toString().substring(0, 10)}\nhasta\n${item["reporte_fecha_hasta"].toString().substring(0, 10)}',
    //                   item["reporte_kilometraje"].toStringAsFixed(2),
    //                   item["km_vuelta"],
    //                 ],
    //               )
    //               .toList(),
    //         );
    //       },
    //     ),
    //   );

    //   Directory directory = await getApplicationDocumentsDirectory();
    //   String filePath = '${directory.path}/report.pdf';
    //   File file = File(filePath);
    //   file.writeAsBytesSync(await pdf.save());
    //   OpenFile.open(filePath);
    //   print("PDF file saved at $filePath");
    // }
    Future<void> exportToPdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: ["Placa", "Fecha", "Km recorrido", "Vueltas"],
              cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
              data: reportData
                  .map(
                    (item) => [
                      item["placa"],
                      item["reporte_fecha_desde"].toString().substring(0, 10),
                      item["reporte_kilometraje"].toStringAsFixed(2),
                      item["km_vuelta"],
                    ],
                  )
                  .toList(),
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
          dp.MonthPicker.single(
            selectedDate: _selectedDate,
            onChanged: _onSelectedDateChanged,
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Text(
                //   "Cambiar estilos",
                //   style: Theme.of(context).textTheme.titleMedium,
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 12.0),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: <Widget>[
                //       ColorSelectorBtn(
                //         title: "Texto",
                //         color: selectedDateStyleColor,
                //         showDialogFunction: _showSelectedDateDialog,
                //         colorBtnSize: 21.0,
                //       ),
                //       const SizedBox(width: 12.0),
                //       ColorSelectorBtn(
                //         title: "Fondo",
                //         color: selectedSingleDateDecorationColor,
                //         showDialogFunction: _showSelectedBackgroundColorDialog,
                //         colorBtnSize: 21.0,
                //       ),
                //     ],
                //   ),
                // ),
                RoundedButton(
                  isDisabled: _isLoading || isEqualsDateSelected ? true : false,
                  text: 'Buscar',
                  color: const Color(0xff6456FF),
                  isLoading: _isLoading,
                  press: () {
                    hanldleVueltasKilometraje(context, vehiculo_id);
                  },
                ),
                // Text("Selected: $_selectedDate"),
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
                        ? reportData.isNotEmpty
                            ? Column(
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
                                        _buildHeaderRow(),
                                        ..._buildDataRows(placaVehiculo),
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
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              await exportToPdf();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors
                                                  .blueAccent, // Color de fondo del botón
                                              surfaceTintColor: Colors
                                                  .white, // Color del texto
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20), // Bordes redondeados
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical:
                                                      12), // Padding del botón
                                            ),
                                            icon: Icon(Icons.share,
                                                size: 20), // Icono del botón
                                            label: Text(
                                              'Compartir',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ElevatedButton(
                                        //   onPressed: exportToExcel,
                                        //   // child: Icon(AntDesign.file_excel_fill),
                                        //   child: const Icon(
                                        //     Bootstrap.file_earmark_excel_fill,
                                        //     color: Color(0xff1F6E46),
                                        //   ),
                                        // ),
                                        // ElevatedButton(
                                        //   onPressed: exportToPdf,
                                        //   child: const Icon(
                                        //     Bootstrap.file_pdf_fill,
                                        //     color: Color(0xffC40607),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : const Center(
                                child: Text('No se encontraron datos'),
                              )
                        : const Center(
                            child: Text(
                                'Seleccione una fecha y haga click en buscar'),
                          ),
                // Agrega el SkeletonLoader en el lugar adecuado
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

  Widget _buildHeaderRow() {
    const styleTitle = TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);

    return Row(
      children: [
        _buildCell('Placa', textStyle: styleTitle),
        _buildCell('Fecha', textStyle: styleTitle),
        _buildCell('Km', textStyle: styleTitle),
        _buildCell('Vueltas', textStyle: styleTitle),
      ],
    );
  }

  List<Widget> _buildDataRows(String placaVehiculo) {
    return reportData.map((item) {
      int vueltas = (item['reporte_kilometraje'] / item['km_vuelta']).floor();

      DateTime dateTime =
          DateTime.parse(item['reporte_fecha_desde'].toString());
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      const styleCampos = TextStyle(fontSize: 14.0);

      return Row(
        children: [
          _buildCell(placaVehiculo, textStyle: styleCampos, hideBottom: true),
          _buildCell(
            '${formattedDate}\nhasta\n${item['reporte_fecha_hasta'].toString().substring(0, 10)}',
            textStyle: TextStyle(fontSize: 12.0),
            hideBottom: true,
          ),
          _buildCell(
            item['reporte_kilometraje'].toStringAsFixed(2),
            textStyle: styleCampos,
            hideBottom: true,
          ),
          _buildCell(
            vueltas.toString(),
            textStyle: styleCampos,
            hideBottom: true,
          ),
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

  // select text color of the selected date
  void _showSelectedDateDialog() async {
    Color? newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedDateStyleColor,
            ));

    if (newSelectedColor != null) {
      setState(() {
        selectedDateStyleColor = newSelectedColor;
      });
    }
  }

  // select background color of the selected date
  void _showSelectedBackgroundColorDialog() async {
    Color? newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedSingleDateDecorationColor,
            ));

    if (newSelectedColor != null) {
      setState(() {
        selectedSingleDateDecorationColor = newSelectedColor;
      });
    }
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _isTableVisible = false;
    });
  }
}
