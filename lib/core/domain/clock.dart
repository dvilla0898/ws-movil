/// Puerto para obtener la fecha y hora actual.
///
/// Los casos de uso lo reciben en lugar de llamar a `DateTime.now()`, así los
/// tests pueden fijar la hora y comprobar resultados exactos.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
