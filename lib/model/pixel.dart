import 'dart:ui';

class Pixel{
  int x;
  int y;
  Color color;
  Pixel(this.x, this.y,this.color);

  Map<String,int> toJson(){
    return {
      "x":x,
      "y":y,
      "color":color.value
    };
  }

  factory Pixel.fromJson(Map<String,dynamic> json){
    return Pixel(json["x"], json["y"], Color(json["color"]));
  }
}