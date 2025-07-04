class EntriesModel {
  List<EntryData>? data;

  EntriesModel({this.data});

  EntriesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <EntryData>[];
      json['data'].forEach((v) {
        data!.add(EntryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EntryData {
  int? id;
  String? vehicleNumber;
  String? inTime;
  String? outTime;
  String? createdAt;
  String? updatedAt;

  EntryData(
      {this.id,
        this.vehicleNumber,
        this.inTime,
        this.outTime,
        this.createdAt,
        this.updatedAt});

  EntryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vehicleNumber = json['vehicle_number'];
    inTime = json['in_time'];
    outTime = json['out_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vehicle_number'] = vehicleNumber;
    data['in_time'] = inTime;
    data['out_time'] = outTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
