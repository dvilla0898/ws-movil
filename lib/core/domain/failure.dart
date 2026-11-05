import 'package:equatable/equatable.dart';

/// Error de negocio esperado (no una excepción inesperada).
///
/// Cada módulo define sus propios fallos heredando de esta clase. La capa de
/// presentación los traduce a un texto según el idioma elegido.
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// Motivo por el que un valor no es válido.
enum ValidationError { required, tooShort, tooLong }

/// Un campo no cumple las reglas del dominio (por ejemplo, un título vacío).
class ValidationFailure extends Failure {
  const ValidationFailure(this.field, this.error, {this.limit});

  /// Nombre del campo (`username`, `title`...).
  final String field;
  final ValidationError error;

  /// Longitud mínima o máxima incumplida, si aplica.
  final int? limit;

  @override
  List<Object?> get props => [field, error, limit];
}

/// El elemento buscado no existe.
class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// Algo falló en la infraestructura (base de datos, disco...).
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
