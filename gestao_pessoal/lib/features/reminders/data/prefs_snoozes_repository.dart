import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/prefs_keys.dart';
import '../../../core/database/prefs_store.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/json_coders.dart';
import '../domain/reminder.dart';

/// [ReminderSnoozesRepository] sobre `SharedPreferences`.
class PrefsSnoozesRepository implements ReminderSnoozesRepository {
  PrefsSnoozesRepository(this._store);

  final PrefsStore _store;

  @override
  List<ReminderSnooze> loadAll() => JsonCoders.decodeList<ReminderSnooze>(
        _store.readRaw(PrefsKeys.reminderSnoozes),
        ReminderSnooze.fromJson,
      );

  @override
  Future<void> saveAll(List<ReminderSnooze> snoozes) => _store.writeRaw(
        PrefsKeys.reminderSnoozes,
        JsonCoders.encodeList<ReminderSnooze>(snoozes, (s) => s.toJson()),
      );
}

final snoozesRepositoryProvider = Provider<ReminderSnoozesRepository>(
  (ref) => PrefsSnoozesRepository(ref.watch(prefsStoreProvider)),
);
