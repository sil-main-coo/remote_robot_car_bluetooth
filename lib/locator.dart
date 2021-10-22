import 'package:get_it/get_it.dart';
import 'package:remoterobotcar/services/bluetooth.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Bluetooth>(() => BluetoothService());
}
