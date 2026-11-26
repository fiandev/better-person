import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:better_person/components/screens/location_settings_screen.dart';
import 'package:better_person/components/theme/habit_focus_theme.dart';
import 'package:better_person/controllers/prayer_controller.dart';
import 'package:better_person/controllers/setting_controller.dart';
import 'package:better_person/l10n/app_localizations.dart';
import 'package:better_person/utils/location_service.dart';

const List<int> _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
  0x42, 0x60, 0x82, //
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest();

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Encoding encoding = utf8;

  @override
  bool bufferOutput = true;

  @override
  int contentLength = -1;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Uri get uri => Uri();

  @override
  String get method => 'GET';

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  Future<HttpClientResponse> get done => close();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  Future<void> flush() async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  Future<Socket> detachSocket() => throw UnimplementedError();

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) => Future.value(this);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void remove(String name, Object value) {}

  @override
  void removeAll(String name) {}

  @override
  void clear() {}

  @override
  String? value(String name) => null;

  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _app(Widget home) => MaterialApp(
  theme: HabitFocusTheme.themeData,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  HttpOverrides? previousHttpOverrides;

  setUpAll(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _MockHttpOverrides();

    final tempDir = Directory.systemTemp.createTempSync('better_person_test_');
    addTearDown(() {
      HttpOverrides.global = previousHttpOverrides;
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingController().clear();
    await PrayerController().clear();
  });

  testWidgets(
    'loads initial coordinates and renders FlutterMap with TileLayer and MarkerLayer',
    (tester) async {
      await LocationService.saveLocation(-6.2088, 106.8456);

      await tester.pumpWidget(_app(const LocationSettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(TileLayer), findsOneWidget);
      expect(find.byType(MarkerLayer), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'displays selected coordinates and CalculationMethod dropdown',
    (tester) async {
      await LocationService.saveLocation(-6.2088, 106.8456);

      await tester.pumpWidget(_app(const LocationSettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('-6.2088'), findsWidgets);
      expect(find.textContaining('106.8456'), findsWidgets);
      expect(
        find.byType(DropdownButtonFormField<adhan.CalculationMethod>),
        findsOneWidget,
      );
      expect(find.text('Muslim World League'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'tapping Save prayer settings persists coordinates and calculation method',
    (tester) async {
      await LocationService.saveLocation(-6.2088, 106.8456);

      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LocationSettingsScreen(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));

      final dropdown = find.byType(
        DropdownButtonFormField<adhan.CalculationMethod>,
      );
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.text('Egyptian').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final saveButton = find.text('Save prayer settings');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        if (find.byType(LocationSettingsScreen).evaluate().isEmpty) break;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 300));

      final savedLocation = await LocationService.getLocation();
      expect(savedLocation.latitude, -6.2088);
      expect(savedLocation.longitude, 106.8456);
      expect(
        SettingController().getCurrentSetting().prayerCalculationMethod,
        adhan.CalculationMethod.egyptian.name,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'entering manual coordinates updates selection and persists on save',
    (tester) async {
      await LocationService.saveLocation(-6.2088, 106.8456);

      await tester.pumpWidget(_app(const LocationSettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final manualTile = find.text('Enter coordinates manually');
      await tester.ensureVisible(manualTile);
      await tester.tap(manualTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final latField = find.widgetWithText(TextFormField, 'Latitude');
      final lngField = find.widgetWithText(TextFormField, 'Longitude');
      await tester.ensureVisible(latField);
      await tester.enterText(latField, '21.4225');
      await tester.enterText(lngField, '39.8262');
      await tester.pump();

      expect(find.text('Selected: 21.42250, 39.82620'), findsOneWidget);

      final saveButton = find.text('Save prayer settings');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final savedLocation = await LocationService.getLocation();
      expect(savedLocation.latitude, 21.4225);
      expect(savedLocation.longitude, 39.8262);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'invalid coordinate expands manual section and shows validation error on save',
    (tester) async {
      await LocationService.saveLocation(-6.2088, 106.8456);

      await tester.pumpWidget(_app(const LocationSettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final manualTile = find.text('Enter coordinates manually');
      await tester.ensureVisible(manualTile);
      await tester.tap(manualTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final latField = find.widgetWithText(TextFormField, 'Latitude');
      await tester.ensureVisible(latField);
      await tester.enterText(latField, 'NaN');
      await tester.pump();

      // Collapse manual section before saving to verify auto-expand on error.
      await tester.ensureVisible(manualTile);
      await tester.tap(manualTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final saveButton = find.text('Save prayer settings');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Enter a value from -90.0 to 90.0.'), findsOneWidget);

      final savedLocation = await LocationService.getLocation();
      expect(savedLocation.latitude, -6.2088);
      expect(savedLocation.longitude, 106.8456);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
