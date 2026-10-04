import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_keys.dart';

/// Wrapper de baixo nível sobre [SharedPreferences].
///
/// Centraliza leitura/escrita das coleções serializadas em JSON
/// (hábitos, tarefas, sessões de pomodoro) e isola o resto do app
/// da API do `shared_preferences`.
class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStore(prefs);
  }

  /// Relê do disco. Necessário quando outro isolate (a ação "Concluir" de
  /// uma notificação) gravou dados enquanto o app estava aberto.
  Future<void> reload() => _prefs.reload();

  String? readRaw(String key) => _prefs.getString(key);

  Future<void> writeRaw(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  String? get habits => readRaw(PrefsKeys.habits);
  String? get tasks => readRaw(PrefsKeys.tasks);
  String? get pomodoroSessions => readRaw(PrefsKeys.pomodoroSessions);
  String? get settings => readRaw(PrefsKeys.settings);

  Future<void> setHabits(String value) => writeRaw(PrefsKeys.habits, value);
  Future<void> setTasks(String value) => writeRaw(PrefsKeys.tasks, value);
  Future<void> setPomodoroSessions(String value) =>
      writeRaw(PrefsKeys.pomodoroSessions, value);
  Future<void> setSettings(String value) =>
      writeRaw(PrefsKeys.settings, value);
}
