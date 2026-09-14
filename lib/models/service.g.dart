// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceStatusAdapter extends TypeAdapter<ServiceStatus> {
  @override
  final int typeId = 0;

  @override
  ServiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ServiceStatus.operational;
      case 1:
        return ServiceStatus.degraded;
      case 2:
        return ServiceStatus.down;
      case 3:
        return ServiceStatus.unknown;
      default:
        return ServiceStatus.operational;
    }
  }

  @override
  void write(BinaryWriter writer, ServiceStatus obj) {
    switch (obj) {
      case ServiceStatus.operational:
        writer.writeByte(0);
        break;
      case ServiceStatus.degraded:
        writer.writeByte(1);
        break;
      case ServiceStatus.down:
        writer.writeByte(2);
        break;
      case ServiceStatus.unknown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
