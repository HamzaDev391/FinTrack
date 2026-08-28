import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

final databaseInitializerProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);

  await database.seedDefaultCategories();
});
