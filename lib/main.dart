import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/helpers/db-helper.dart';
import 'package:myapp/homepage.dart';
import 'package:myapp/login.dart';
import 'package:myapp/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'platform_helper.dart'
    if (dart.library.js_interop) 'platform_helper_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Explicitly initialize databaseFactory for web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (isDesktop) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize DB helper instance
  await DBHelper().initDB();

  runApp(MyApp());
}
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:myapp/helpers/db-helper.dart';
// import 'package:myapp/homepage.dart';
// import 'package:myapp/login.dart';
// import 'package:myapp/models/user.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// // 1. Correct Web import
// import 'package:sqflite_common_ffi_web/sqflite_common_ffi_web.dart';

// // 2. Safe conditional platform import
// import 'platform_helper.dart'
//     if (dart.library.js_interop) 'platform_helper_web.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 3. Configure database factory based on target
//   if (kIsWeb) {
//     databaseFactory = databaseFactoryFfiWeb;
//   } else if (isDesktop) {
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfi;
//   }

//   // 4. Initialize database after factory configuration
//   await DBHelper().initDB();

//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  final bool userLoggedIn = false;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTrain App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: userLoggedIn
          ? MyHomePage(
              user: User(
                id: 1,
                fullname: 'Ebuka',
                email: "ebuka@gmail.com",
                password: "",
              ),
            )
          : const LoginScreen(),
    );
  }
}
