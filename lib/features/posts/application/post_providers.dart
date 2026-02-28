import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/post_service.dart';

final postServiceProvider = Provider<PostService>((ref) => PostService());
