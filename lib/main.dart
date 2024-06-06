import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:background_fetch/background_fetch.dart';

const String methodChannelIdentifier = 'method_channel_identifier';
Future<void> main() async {
  runApp(const MyApp());

  await BackgroundFetch.registerHeadlessTask(_backgroundTask);
}

@pragma('vm:entry-point')
Future<void> _backgroundTask(HeadlessTask task) async {
  final taskId = task.taskId;
  final isTimeout = task.timeout;

  if (isTimeout) {
    await BackgroundFetch.finish(taskId);

    return;
  }

  const channel = MethodChannel(methodChannelIdentifier);

  // When run in headless mode as app is closed this will throw MissingPluginException
  bool res = await channel.invokeMethod('test');

  print("RESULT RECEIVED: ${res.toString()}");

  await BackgroundFetch.finish(taskId);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();

    setupBackgroundFetch();
  }

  Future<void> setupBackgroundFetch() async {
    WidgetsFlutterBinding.ensureInitialized();

    const channel = MethodChannel(methodChannelIdentifier);

    // Works fine on main thread
    await channel.invokeMethod('test');

    await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 1,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            forceAlarmManager: true),
        (String taskId) async =>
            await _backgroundTask(HeadlessTask(taskId, false)),
        (String taskId) => BackgroundFetch.finish(taskId));

    await BackgroundFetch.start();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
