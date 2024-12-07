import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  WebViewController? _controller;
  late Future<void> _initWebView;

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
          'https://mibus.pe/embeber-modulo/historial?name=${savedUsername}&password=${savedPasswordTemp}&empresa=${savedEmpresa}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0Xff4737FF),
        foregroundColor: Colors.white,
        title: const Text('Historial'),
      ),
      body: FutureBuilder<void>(
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
      ),
      // body: WebViewWidget(controller: _controller!),
    );
  }
}
