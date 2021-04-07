static class gl {
  
  /* Behavior */
  final static boolean runFromPredators = false;
  
  /* Food */
  final static int plantEnergy = 25;
  final static int minMeatEnergy = 50;  // Minimum amount of energy gained from eating meat
  
  /* Sight. These scale with size */
  final static float sightBase = 0;
  final static float sightLog = 0;
  final static float sightLinear = 10;
  
  /* Cost of movement. These scale with size */
  final static float moveEnergyBase = 0;
  final static float moveEnergyLog = 0;
  final static float moveEnergyLinear = 0;
  final static float moveEnergyQuadratic = 1;
  
  /* Friction */
  final static boolean variableFriction = true;  // Whether friction changes with size
  final static float staticFrictionCoeff = 0.8;  // < 1
  final static float variableFrictionCoeff = 2;  // > 1
  
  /* Misc */
  final static boolean cliffs = false;  // Whether creatures will die at the edge of the map
  final static int plantFrequency = 1;   // Number of frames between new plants appearing
}
