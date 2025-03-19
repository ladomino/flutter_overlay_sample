import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Highlight Overlay Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const OverlayExample(title: 'Highlight Overlay Example'),
    );
  }
}

class OverlayExample extends StatefulWidget {
  const OverlayExample({super.key, required this.title});

  final String title;

  @override
  State<OverlayExample> createState() => _OverlayExampleState();
}

class _OverlayExampleState extends State<OverlayExample> {
  final OverlayManager _overlayManager = OverlayManager();

  int _currentPageIndex = 0;

  @override
  void dispose() {
    _overlayManager.removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      bottomNavigationBar: _buildNavigationBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildInstructionText(),
              _buildOverlayButtons(),
              _buildRemoveOverlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentPageIndex,
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.commute), label: 'Commute'),
        NavigationDestination(
          selectedIcon: Icon(Icons.bookmark),
          icon: Icon(Icons.bookmark_border),
          label: 'Saved',
        ),
      ],
    );
  }

  Widget _buildInstructionText() {
    return Text(
      'Use Overlay to highlight a NavigationBar destination',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildOverlayButtons() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        _buildOverlayButton('Explore', 0, AlignmentDirectional.bottomStart, Colors.red),
        _buildOverlayButton('Commute', 1, AlignmentDirectional.bottomCenter, Colors.green),
        _buildOverlayButton('Saved', 2, AlignmentDirectional.bottomEnd, Colors.orange),
      ],
    );
  }

  Widget _buildOverlayButton(String label, int index, AlignmentDirectional alignment, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentPageIndex = index;
        });
        _overlayManager.createOverlay(
          context: context,
          alignment: alignment,
          borderColor: color,
          currentPageIndex: _currentPageIndex,
        );
      },
      child: Text(label),
    );
  }

  Widget _buildRemoveOverlayButton() {
    return ElevatedButton(
      onPressed: _overlayManager.removeOverlay,
      child: const Text('Remove Overlay'),
    );
  }
}

class OverlayManager {
  OverlayEntry? _overlayEntry;

  void createOverlay({
    required BuildContext context,
    required AlignmentDirectional alignment,
    required Color borderColor,
    required int currentPageIndex,
  }) {
    removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return HighlightOverlay(
          alignment: alignment,
          borderColor: borderColor,
          currentPageIndex: currentPageIndex,
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class HighlightOverlay extends StatelessWidget {
  const HighlightOverlay({
    super.key,
    required this.alignment,
    required this.borderColor,
    required this.currentPageIndex,
  });

  final AlignmentDirectional alignment;
  final Color borderColor;
  final int currentPageIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        heightFactor: 1.0,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Tap here for'),
              _buildPageLabel(),
              _buildHighlightBox(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageLabel() {
    final (String label, Color? color) = switch (currentPageIndex) {
      0 => ('Explore page', Colors.red),
      1 => ('Commute page', Colors.green),
      2 => ('Saved page', Colors.orange),
      _ => ('No page selected.', null),
    };

    if (color == null) {
      return Text(label);
    }
    return Column(
      children: <Widget>[
        Text(label, style: TextStyle(color: color)),
        Icon(Icons.arrow_downward, color: color),
      ],
    );
  }

  Widget _buildHighlightBox(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      height: 80.0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 4.0),
          ),
        ),
      ),
    );
  }
}
