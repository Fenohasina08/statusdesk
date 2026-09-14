// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceAdapter extends TypeAdapter<Service> {
  @override
  final int typeId = 2;

  @override
  Service read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Service(
      name: fields[0] as String,
      status: fields[1] as ServiceStatus,
      responseTime: fields[2] as int,
      lastChecked: fields[3] as DateTime,
      url: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Service obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.responseTime)
      ..writeByte(3)
      ..write(obj.lastChecked)
      ..writeByte(4)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
