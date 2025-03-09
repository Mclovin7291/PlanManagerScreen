import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

// Data Models
enum PlanStatus { pending, completed }
enum PlanType { adoption, travel }

class Plan {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final PlanStatus status;
  final PlanType type;

  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.status = PlanStatus.pending,
    required this.type,
  });

  Plan copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    PlanStatus? status,
    PlanType? type,
  }) => Plan(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    date: date ?? this.date,
    status: status ?? this.status,
    type: type ?? this.type,
  );
}

// Screens
class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({Key? key}) : super(key: key);
  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  final List<Plan> _plans = [];
  DateTime _selectedDate = DateTime.now();
  final _uuid = const Uuid();
  Plan? _draggedPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Manager')),
      body: const Center(child: Text('Plan Manager Screen')),
    );
  }
}

// Main App
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Plan Manager',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: const PlanManagerScreen(),
  );
}
