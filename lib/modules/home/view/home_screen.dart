import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _items = [
    {"icon": Icons.person, "name": "Contact"},
    {"icon": Icons.message, "name": "Message"},
    {"icon": Icons.call, "name": "Calls"},
    {"icon": Icons.camera, "name": "Camera"},
    {"icon": Icons.photo, "name": "Gallary"}
  ];

  dynamic dragIndex;
  dynamic currentIndex;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: _items,
            builder: (e, isHovered, index, onReorder) {
              return MouseRegion(
                onEnter: (_) => isHovered.value = true,
                onExit: (_) => isHovered.value = false,
                child: ValueListenableBuilder<bool>(
                  valueListenable: isHovered,
                  builder: (context, hover, child) {
                    return LongPressDraggable(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          constraints: const BoxConstraints(minWidth: 60),
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.primaries[
                                e.hashCode % Colors.primaries.length],
                          ),
                          child: Center(
                              child: Icon(e["icon"] as IconData,
                                  color: Colors.white, size: 32)),
                        ),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      onDragStarted: () {
                        setState(() {
                          dragIndex = index;
                          print("dragIndex => $dragIndex");
                        });
                      },
                      onDragCompleted: () {
                        setState(() {
                          currentIndex = dragIndex;
                          print("currentIndex=>$currentIndex");
                        });
                      },
                      child: Tooltip(
                        preferBelow: false,
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.only(
                            bottom: 8.0, top: 8.0, right: 8.0, left: 8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey.shade300,
                            shape: BoxShape.rectangle),
                        message: e['name'] as String,
                        textStyle: TextStyle(fontSize: 14.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          constraints: BoxConstraints(
                            minWidth: hover ? 60 : 48,
                          ),
                          height: hover ? 60 : 48,
                          margin: const EdgeInsets.all(8),
                          transform: Matrix4.translationValues(
                              0, hover ? -10.0 : 0.0, 0.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.primaries[
                                e.hashCode % Colors.primaries.length],
                          ),
                          child: Center(
                              child: Icon(e["icon"] as IconData,
                                  color: Colors.white, size: hover ? 32 : 24)),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                print("simple");
                print(newIndex);
                print(newIndex > oldIndex ? newIndex -= 1 : newIndex += 1);
                print(newIndex);
                // final item = _items.removeAt(oldIndex);
                // _items.insert(newIndex, item);
              });
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
    required this.onReorder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item with hover state and index.
  final Widget Function(T, ValueNotifier<bool>, int, void Function(int, int))
      builder;

  /// Callback for reordering items.
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return widget.builder(item, ValueNotifier(false), index,
              (oldIndex, newIndex) {
            widget.onReorder(newIndex, oldIndex);
          });
        }).toList(),
      ),
    );
  }
}
