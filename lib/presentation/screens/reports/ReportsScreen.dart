import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/rendering.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  WebViewController? _controller;
  late Future<void> _initWebView;
  bool showWebView = true;
  String _selectedReportType = 'vehiculo';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initWebView = _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPasswordTemp = prefs.getString('passwordTemp');
    String? savedEmpresa = prefs.getString('empresa');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://mibus.pe/embeber-modulo/reportes/vueltas-unidad?name=${savedUsername}&password=${savedPasswordTemp}&empresa=${savedEmpresa}',
        ),
      );
  }

  void _handleRadioValueChange(String? value) {
    setState(() {
      _selectedReportType = value!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onSearchPressed() {
      // Lógica de búsqueda aquí
      print('Botón de búsqueda presionado');
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0Xff4737FF),
        foregroundColor: Colors.white,
        title: const Text('Reportes'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showWebView = !showWebView;
              });
            },
            icon: Icon(Icons.change_circle_outlined),
          ),
        ],
      ),
      body: showWebView
          ? FutureBuilder<void>(
              future: _initWebView,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar la página'));
                } else {
                  return WebViewWidget(controller: _controller!);
                }
              },
            )
          : SingleChildScrollView(
              // physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          activeColor: Colors.orange,
                          value: 'vehiculo',
                          groupValue: _selectedReportType,
                          onChanged: _handleRadioValueChange,
                        ),
                        const Text('Por Vehículo'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          activeColor: Colors.orange,
                          value: 'flota',
                          groupValue: _selectedReportType,
                          onChanged: _handleRadioValueChange,
                        ),
                        const Text('Por Flota'),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    const Text(
                      'Fecha',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'No date selected!'
                              : 'Selected date: ${_selectedDate!.toLocal()}'
                                  .split(' ')[0],
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Seleccione una fecha',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () => _showModalBottomSheet(context),
                      child: Card(
                        elevation: 2.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedReportType == 'vehiculo'
                                    ? 'Vehiculo'
                                    : 'Flota',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.orange,
                        ),
                        onPressed: _onSearchPressed,
                        icon: Icon(Icons.search),
                        label: Text(
                          'Buscar',
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccione una opción',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: const Text('Por Vehículo'),
                leading: Radio<String>(
                  activeColor: Colors.orange,
                  value: 'vehiculo',
                  groupValue: _selectedReportType,
                  onChanged: (String? value) {
                    _handleRadioValueChange(value);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Por Flota'),
                leading: Radio<String>(
                  activeColor: Colors.orange,
                  value: 'flota',
                  groupValue: _selectedReportType,
                  onChanged: (String? value) {
                    _handleRadioValueChange(value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
