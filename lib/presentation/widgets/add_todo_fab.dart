import 'package:flutter/material.dart';

/// Widget para el botón flotante de agregar tarea
class AddTodoFab extends StatelessWidget {
  const AddTodoFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddTodoDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTodoDialog());
  }
}

/// Dialog para agregar una nueva tarea
class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  int _selectedPriority = 1;

  final List<String> _categories = [
    'Personal',
    'Trabajo',
    'Compras',
    'Salud',
    'Educación',
    'Otro',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Tarea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (value.length > 100) {
                    return 'El título no puede tener más de 100 caracteres';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Fecha de vencimiento
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha'
                      : 'Fecha: ${_formatDate(_selectedDate!)}',
                ),
                trailing: _selectedDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      )
                    : null,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Prioridad
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prioridad'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Baja'),
                          value: 1,
                          groupValue: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Media'),
                          value: 2,
                          groupValue: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<int>(
                          title: const Text('Alta'),
                          value: 3,
                          groupValue: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _saveTodo, child: const Text('Guardar')),
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      // Aquí implementarías la lógica para guardar la tarea
      // Por ahora, solo cerramos el dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
