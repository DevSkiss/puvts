import 'package:json_annotation/json_annotation.dart';

part 'passenger_model.g.dart';

@JsonSerializable()
class PassengerModel {
  PassengerModel(
    this.firstname,
    this.lastname,
    this.username,
    this.password,
    this.id,
    this.active,
    this.createdAt,
  );

  factory PassengerModel.fromJson(Map<String, dynamic> json) =>
      _$PassengerModelFromJson(json);
  Map<String, dynamic> toJson() => _$PassengerModelToJson(this);

  @JsonKey(name: 'firstname')
  final String? firstname;

  @JsonKey(name: 'lastname')
  final String? lastname;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'password')
  final String? password;

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'active')
  final bool active;

  @JsonKey(name: 'createdAt')
  final String createdAt;
}
