import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Import the backend sandbox package
import 'package:flutter_artist_backend_sandbox/flutter_artist_backend_sandbox.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const BackendSandboxExampleApp());
}

class BackendSandboxExampleApp extends StatelessWidget {
  const BackendSandboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backend Sandbox Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const SandboxDemoScreen(),
    );
  }
}

class SandboxDemoScreen extends StatefulWidget {
  const SandboxDemoScreen({super.key});

  @override
  State<SandboxDemoScreen> createState() => _SandboxDemoScreenState();
}

class _SandboxDemoScreenState extends State<SandboxDemoScreen> {
  late final Dio _dio;
  bool _isLoading = false;
  String _logOutput = 'Press any button below to trigger API calls...';
  List<Map<String, dynamic>> _displayAlbums = [];

  final String _staticResourceBaseURL =
      "https://o7planning.github.io/static/demo/flutter/flutter_artist_demo";

  @override
  void initState() {
    super.initState();
    _initNetworkClient();
  }

  void _initNetworkClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://sandbox-api.local',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    final mockBackendInterceptor = getFlutterArtistBackendSandboxInterceptor();

    _dio.interceptors.addAll([mockBackendInterceptor]);
  }

  String? _getStaticResourceURL(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith("http://") ||
        path.startsWith("https://") ||
        path.startsWith("data:image")) {
      return path;
    }
    return "$_staticResourceBaseURL$path";
  }

  /// Helper to launch the documentation URL when the user clicks the warning panel
  Future<void> _launchDocsUrl() async {
    final Uri url = Uri.parse(
      'https://pub.dev/packages/flutter_artist_backend_sandbox',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      setState(() => _logOutput = 'Could not launch documentation URL.');
    }
  }

  Future<void> _fetchAlbums() async {
    setState(() {
      _isLoading = true;
      _logOutput = 'Fetching paginated albums from local sandbox database...';
    });

    try {
      final response = await _dio.get('/rest/page/album-info/all');

      setState(() {
        _logOutput =
            'SUCCESS: GET /rest/page/album-info/all \n\n:${response.data.toString()} ';
      });
    } catch (e) {
      setState(() => _logOutput = 'ERROR fetching albums: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCurrencyDetail(String code) async {
    setState(
      () => _logOutput =
          'Fetching exhaustive currency record details for $code...',
    );

    try {
      final response = await _dio.get('/rest/record/currency-data/$code');
      setState(() {
        _logOutput =
            'SUCCESS: GET /rest/record/currency-data/$code\n\n'
            'Full Payload Attributes:\n${response.data.toString()}';
      });
    } catch (e) {
      setState(() => _logOutput = 'ERROR fetching currency: $e');
    }
  }

  Future<void> _deleteEmployee(int id) async {
    setState(
      () => _logOutput =
          'Executing target deletion procedure for Employee ID: $id...',
    );

    try {
      final response = await _dio.delete('/rest/action/employee/delete/$id');
      setState(() {
        _logOutput =
            'SUCCESS: DELETE /rest/action/employee/delete/$id\n\n'
            'Response Status Code: ${response.statusCode}\n'
            'Data Payload Returned: ${response.data} (Void action confirmation)';
      });
    } catch (e) {
      setState(() => _logOutput = 'ERROR executing employee delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Sandbox Client Example'),
        backgroundColor: Colors.indigo.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ⚠️ WARNING PANEL FOR WEB PLATFORM
            if (kIsWeb) ...[
              Card(
                color: Colors.amber.shade50,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.amber.shade800,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Web Platform Configuration Required!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ensure that you have downloaded "sqlite3.wasm" from SQLite official portal and copied it into your project\'s "web/" directory, otherwise the database initialization will fail.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _launchDocsUrl,
                              child: Text(
                                'See detailed web prerequisites setup guide here →',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Text(
              'Simulated Action Controls',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _fetchAlbums,
                  icon: const Icon(Icons.auto_awesome_motion),
                  label: const Text('Get All Albums (Page Data)'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _fetchCurrencyDetail('USD'),
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('Get USD Detail (Single Record)'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteEmployee(1),
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Delete Employee #1 (Void Action)'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Console Execution Logs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _logOutput,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Rendered Sandbox Album Results',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayAlbums.isEmpty
                  ? Center(
                      child: Text(
                        'No persistent local database states loaded.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _displayAlbums.length,
                      itemBuilder: (context, index) {
                        final album = _displayAlbums[index];
                        final resolvedImageUrl = _getStaticResourceURL(
                          album['imagePath'],
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: resolvedImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      resolvedImageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  )
                                : const Icon(Icons.album),
                            title: Text(album['name'] ?? 'Unknown Album'),
                            subtitle: Text(
                              'Code: ${album['code']} | Sequence: ${album['seqNum']}',
                            ),
                            trailing: Icon(
                              album['published'] == true
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              color: album['published'] == true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
