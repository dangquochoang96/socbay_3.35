List<ReturnImages> listReturnImagesFromJson(List<dynamic> json) {
  return json.map((x) => ReturnImages.fromJson(x.toString())).toList();
}

class ReturnImages {
  String? image;
  ReturnImages({this.image});
  factory ReturnImages.fromJson(String json) => ReturnImages(
        image: json,
      );
  String toJson() => image ?? '';
}

