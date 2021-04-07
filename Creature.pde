class Creature extends Entity {
  // Member variables
  int energy;
  float vx;
  float vy;
  int moveTimer;
  
  // Genes
  final int moveRate;
  final float moveStrength;
  final int breedEnergy;
  final int childEnergy;
  final int size;
  
  // Initializer for start of simulation
  Creature() {
    moveRate = (int) random(100);
    //moveTimer = moveRate;
    moveTimer = moveRate;
    moveStrength = random(50);
    size = (int) random(1, 5);
    breedEnergy = (int) random(size*size, size*size*100);
    childEnergy = (int) random(size*size, breedEnergy);
    
    energy = 50;
    x = random(width);
    y = random(height);
    vx = 0;
    vy = 0;
  }
  
  
  // Initialize with parents
  Creature(Creature p1, Creature p2) {
    moveRate = (int) random(p1.moveRate, p2.moveRate) + int(randomGaussian() * 20);
    moveTimer = 1;
    moveStrength = max(0.1, 
      random(p1.moveStrength, p2.moveStrength) + randomGaussian() / 5
    );
    size = max(1, 
      int(
        random(p1.size, p2.size) + random(-2, 2)
      )
    );
    breedEnergy = (int) max(size, 
      random(p1.breedEnergy, p2.breedEnergy) + int(randomGaussian() * 20)
    );
    childEnergy = (int) constrain(
      random(p1.childEnergy, p2.childEnergy) + int(randomGaussian() * 10),
      size,
      breedEnergy
    );
    
    x = p1.x;
    y = p1.y;
    energy = p1.childEnergy + p2.childEnergy;
    vx = 0;
    vy = 0;
  }
  
  
  // Pay energy to push towards the given entity
  void goTowards(Entity closest, boolean invert) {
    if (closest == null) {
      return;
    }
    if (moveTimer <= 0) {
      float dir = atan((closest.y - y)/(closest.x - x));
      if (closest.x < x)
        dir += PI;
      if (invert) {
        vx -= cos(dir) * moveStrength;
        vy -= sin(dir) * moveStrength;
      } else {
        vx += cos(dir) * moveStrength;
        vy += sin(dir) * moveStrength;
      }
      moveTimer += moveRate;
      energy -= myMoveEnergy();
    }
  }
  
  void goTowards(Entity closest) {
    goTowards(closest, false);
  }
  
  float mySight() {
    return gl.sightBase + 
           size * gl.sightLinear +
           log(size) * gl.sightLog;
  }
  
  float myMoveEnergy() {
    return moveStrength *
    (
        gl.moveEnergyBase + 
        log(size)*gl.moveEnergyLog +
        size*gl.moveEnergyLinear +
        size*size*gl.moveEnergyQuadratic
    );
  }
  
  Plant findPlant(World world) {
    float minDist = mySight();
    Plant closest = null;
    for (Plant plant : world.plants) {
      if (dist(plant.x, plant.y, x, y) < minDist) {
        minDist = dist(plant.x, plant.y, x, y);
        closest = plant;
      }
    }
    return closest;
  }
  
  Creature findMeat(World world) {
    float minDist = mySight();
    Creature closest = null;
    for (Creature c : world.pop) {
      if (dist(c.x, c.y, x, y) < minDist
          && c != this
          && c.size < size / 2) 
      {
        minDist = dist(c.x, c.y, x, y);
        closest = c;
      }
    }
    return closest;
  }
  
  Creature findMate(World world) {
    if (energy < breedEnergy) {
      return null;
    }
    float minDist = mySight();
    Creature closest = null;
    for (Creature c : world.pop) {
      if (dist(c.x, c.y, x, y) < minDist
          && c != this
          && c.size >= size / 2
          && c.size <= size * 2
          && c.energy >= c.breedEnergy) 
      {
        minDist = dist(c.x, c.y, x, y);
        closest = c;
      }
    }
    return closest;
  }
  
  Creature findPredator(World world) {
    float minDist = mySight();
    Creature closest = null;
    for (Creature c : world.pop) {
      if (dist(c.x, c.y, x, y) < minDist
          && c != this
          && c.size > size * 2) 
      {
        minDist = dist(c.x, c.y, x, y);
        closest = c;
      }
    }
    return closest;
  }
  
  World step(World world) {
    moveTimer -= 1;
    
    // Find the nearest food and mate, for later
    Plant closestPlant = findPlant(world);
    Creature closestMeat = findMeat(world);
    Creature closestMate = findMate(world);
    Creature closestPredator = findPredator(world);
    
    // Decide if I'm ready to mate or want to eat
    if (energy >= breedEnergy && closestMate != null)
      goTowards(closestMate);
    else if (closestPlant != null || closestMeat != null) {
      if (closestPlant == null && closestMeat != null)
        goTowards(closestMeat);
      else if (closestPlant != null && closestMeat == null)
        goTowards(closestPlant);
      else if (dist(closestPlant.x, closestPlant.y, x, y) < dist(closestMeat.x, closestMeat.y, x, y))
        goTowards(closestPlant);
      else
        goTowards(closestMeat);
    }
    if (closestPredator != null && gl.runFromPredators) {
      goTowards(closestPredator, true);
    }
    
    // Update velocities and positions
    x += vx;
    y += vy;
    
    if ((x == 0 || y == 0 || x == width || y == height) && gl.cliffs)
      world.removeCreature(this);
    
      
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
    if (x == 0)
      vx = max(0, vx);
    else if (x == width)
      vx = min(0, vx);
    if (y == 0)
      vy = max(0, vy);
    else if (y == height)
      vy = min(0, vy);
    
    if (gl.variableFriction) {
      vx *= (1 - 1/(gl.variableFrictionCoeff*size));
      vy *= (1 - 1/(gl.variableFrictionCoeff*size)); //<>//
    } else {
      vx *= gl.staticFrictionCoeff;
      vy *= gl.staticFrictionCoeff;
    }
    
    // See if I'm on plant - if so, eat it
    if (closestPlant != null && dist(closestPlant.x, closestPlant.y, x, y) < 2+(size/2)) {
      energy += gl.plantEnergy;
      world.removePlant(closestPlant);
    }
    
    // See if I'm on meat - if so, eat it
    if (closestMeat != null && dist(closestMeat.x, closestMeat.y, x, y) < (size + closestMeat.size)/2) {
      energy += max(closestMeat.energy, gl.minMeatEnergy);
      world.removeCreature(closestMeat);
    }
    
    // See if I'm on a potential mate - if so, breed
    if (closestMate != null && dist(closestMate.x, closestMate.y, x, y) < (size + closestMate.size + 2)/2) {
      Creature child = new Creature(this, closestMate);
      energy -= childEnergy;
      closestMate.energy -= closestMate.childEnergy;
      world.pop.add(child);
    }
    
    // See if I'm dead
    if (energy <= 0) {
      //world.addFood(x, y);
      world.removeCreature(this);
    }
    
    return world;
  }
  
  void draw() {
    if (energy >= breedEnergy) {
      stroke(255,0,0);
      fill(255,0,0);
    } else {
      stroke(0,0,255);
      fill(0,0,255);
    }
    
    ellipse(x, y, size, size);
  }
}
