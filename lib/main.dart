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

// Card Widget
class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({Key? key, required this.plan}) : super(key: key);

  Color _getStatusColor() => plan.status == PlanStatus.pending
      ? Colors.orange
      : Colors.green;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _getStatusColor(), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          title: Text(
            plan.name,
            style: TextStyle(
              decoration: plan.status == PlanStatus.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.description),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(plan.date),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          leading: Icon(
            plan.type == PlanType.adoption ? Icons.child_care : Icons.flight,
            color: _getStatusColor(),
          ),
          trailing: Icon(
            plan.status == PlanStatus.completed
                ? Icons.check_circle
                : Icons.circle_outlined,
            color: _getStatusColor(),
          ),
        ),
      ),
    );
  }
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

  void _addPlan(String name, String description, PlanType type) {
    setState(() {
      _plans.add(Plan(
        id: _uuid.v4(),
        name: name,
        description: description,
        date: _selectedDate,
        type: type,
      ));
    });
  }

  void _showAddPlanDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    var selectedType = PlanType.adoption;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButton<PlanType>(
                value: selectedType,
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
                },
                items: PlanType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addPlan(
                    nameController.text,
                    descController.text,
                    selectedType,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansForSelectedDate = _plans
        .where((plan) =>
            plan.date.year == _selectedDate.year &&
            plan.date.month == _selectedDate.month &&
            plan.date.day == _selectedDate.day)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Manager')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => _selectedDate = selectedDay);
            },
            eventLoader: (day) => _plans
                .where((plan) =>
                    plan.date.year == day.year &&
                    plan.date.month == day.month &&
                    plan.date.day == day.day)
                .toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plansForSelectedDate.length,
              itemBuilder: (context, index) {
                final plan = plansForSelectedDate[index];
                return PlanCard(plan: plan);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        child: const Icon(Icons.add),
      ),
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
