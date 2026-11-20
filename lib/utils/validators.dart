
class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');


  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe seu nome.';
    if (text.length < 2) return 'Use pelo menos 2 caracteres.';
    if (text.length > 60) return 'Use no máximo 60 caracteres.';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe seu e-mail.';
    if (!_emailPattern.hasMatch(text)) return 'Informe um e-mail válido.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Informe uma senha.';
    if (text.length < 8) return 'Use pelo menos 8 caracteres.';
    return null;
  }

  static String? taskTitle(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe um título.';
    if (text.length < 5) return 'Use pelo menos 5 caracteres.';
    if (text.length > 80) return 'Use no máximo 80 caracteres.';
    return null;
  }

  static String? taskDescription(String? value) {
    if ((value ?? '').trim().length > 500) {
      return 'Use no máximo 500 caracteres.';
    }
    return null;
  }

  static String? taskResponsible(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe um responsável pela tarefa.';
    if (text.length < 2) return 'Use pelo menos 2 caracteres.';
    if (text.length > 80) return 'Use no máximo 80 caracteres.';
    return null;
  }

}
