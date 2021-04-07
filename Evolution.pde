World w;
int t;

void setup() {
  size(600, 600);
  w = new World();
  w.addFood();
  t = 0;
  frameRate(60);
}

void draw() {
  fill(255);
  stroke(255);
  rect(0,0,width,height);
  
  w.draw();
  for (int i=0; i<w.pop.size(); i++) {
    w.pop.get(i).draw();
    w.pop.get(i).step(w);
  }
  
  if (t % gl.plantFrequency == 0) {
    w.addFood();
  }
  
  t++;
}
