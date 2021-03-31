class World {
  ArrayList<Plant> plants;
  ArrayList<Creature> pop;
  
  World() {
    plants = new ArrayList<Plant>();
    pop = new ArrayList<Creature>();
    
    for (int i=0; i<500; i++) {
      plants.add(new Plant());
    }
    for (int i=0; i<500; i++) {
      pop.add(new Creature());
    }
  }
  
  void addFood() {
    plants.add(new Plant());
  }
  
  void addFood(float x, float y) {
    plants.add(new Plant(x, y));
  }
  
  void removePlant(Plant f) {
    plants.remove(f);
  }
  
  void removeCreature(Creature c) {
    pop.remove(c);
  }
  
  void draw() {
    for (Plant f : plants) {
      stroke(0,255,0);
      fill(0,255,0);
      rect(f.x-2, f.y-2, 4, 4);
    }
  }
}
