// lib/core/data/adapters/hive_adapters.dart

import 'package:hive_ce/hive.dart';
import 'package:appbase_client/core/data/models/post_model.dart';

// This annotation tells the generator to create an adapter for the Post class.
@GenerateAdapters([AdapterSpec<Post>()])
part 'hive_adapters.g.dart';