class Plant extends Entity {
  Plant() {
    x = random(width);
    y = random(height);
  }
  
  Plant(float x_, float y_) {
    x = x_;
    y = y_;
  }
}
