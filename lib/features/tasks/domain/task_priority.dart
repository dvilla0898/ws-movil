/// Prioridad de una tarea. El orden importa: `high` es la más importante.
enum TaskPriority {
  low,
  medium,
  high;

  /// Convierte el texto guardado en SQLite (`'low'`, `'medium'`...) en el enum.
  static TaskPriority fromName(String name) => TaskPriority.values.byName(name);
}
