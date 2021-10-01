int numAgents = 3;
int maxNumAgents = 4;

int numObstacles = 100;
int numNodes  = 50;
static int maxNumObstacles = 1000;
static int maxNumNodes = 1000;
Vec2 circlePos[] = new Vec2[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii
float eps = 10.0;


//The agent states
Vec2[] agentPos = new Vec2[maxNumAgents];
Vec2[] agentVel = new Vec2[maxNumAgents];

void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,10);
    while (insideAnyCircle){
      randPos = new Vec2(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,10);
    }
    nodePos[i] = randPos;
  }
}

void placeRandomObstacles(int numObstacles){
  //Initial obstacle position
  for (int i = 0; i < numObstacles; i++){
    circlePos[i] = new Vec2(random(50,950),random(50,700));
    //circleRad[i] = (10+40*pow(random(1),3));
    circleRad[i] = (30);
  }
  circleRad[0] = 30; //Make the first obstacle big
}

void testPRM(){  
  placeRandomObstacles(numObstacles);

  generateRandomNodes(numNodes, circlePos, circleRad);
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes, eps);
  
  for(int i = 0; i < numAgents; i++){
    int start = (int)random(0,49);
    int end = (int)random(0,49);
    while(end == start){
      end = (int)random(0,49);
    }
    agentPos[i] = nodePos[start];
    goalPos[i] = end;
    paths[i] = planPath(start, end, circlePos, circleRad, numObstacles, nodePos, numNodes);
  }
  
  //curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
}

//The agent goals
int[] goalPos = new int[maxNumAgents];
ArrayList<Integer>[] paths = new ArrayList[100];  //assuming maximum 100 agents
Vec2[] nodePos = new Vec2[1000];
int[] count = new int[100];

PImage goalpost;
PImage ball;
PImage linebacker;
PImage bg;

void setup(){
  size(1024,900);
  //size(850,650,P3D); //Smoother
  
  goalpost = loadImage("goalpost.png");
  ball = loadImage("football.png");
  linebacker = loadImage("linebacker.png");
  bg = loadImage("grassfield.jpg");
  bg.resize(1024, 900);
  
  testPRM();
   
   for(int i = 0; i < 100; i++){
     count[i] = 0;
   }
  //Set initial velocities to cary agents towards their goals
  
}


// Compute attractive forces to draw agents to their goals,
// and avoidance forces to anticipatory avoid collisions
//void computeAgentForces(float dt){
//  for(int id = 0; id < numAgents; id++){
//    if(count[id] == paths[id].size()){
//      return;
//    }
//    if(paths[id].get(count[id]) == -1){
//      return;
//    }
//    println(nodePos[paths[id].get(count[id])]);
//    println(paths[id]);
//    agentVel[id] = nodePos[paths[id].get(count[id])].minus(agentPos[id]);
//    agentPos[id].add(agentVel[id].times(1.3 * dt));
//    //agentPos[id] = interpolate(agentPos[id], nodePos[paths[id].get(count[id])], .04);
//    if(agentPos[id].distanceTo(nodePos[paths[id].get(count[id])]) <=1.5){
//      agentPos[id] = nodePos[paths[id].get(count[id])];
//      //println(agentPos[id].x + " " + agentPos[id].y);
//      count[id]++;
//    }
//  }
//  return;
//}

void computeAgentForces(float dt){
  for(int id = 0; id < numAgents; id++){
    if(count[id] == paths[id].size()){

    } else if(paths[id].get(count[id]) == -1){

    } else {
      agentVel[id] = nodePos[paths[id].get(count[id])].minus(agentPos[id]);
      agentPos[id].add(agentVel[id].times(1.3 * dt));
      //agentPos[id] = interpolate(agentPos[id], nodePos[paths[id].get(count[id])], .04);
      if(agentPos[id].distanceTo(nodePos[paths[id].get(count[id])]) <=1.5){
        agentPos[id] = nodePos[paths[id].get(count[id])];
        //println(agentPos[id].x + " " + agentPos[id].y);
        count[id]++;
      }
    }
  }
  return;
}
  

boolean paused = true;
void draw(){
  //background(255,255,255); //White background
  background(bg);
  imageMode(CENTER);
 
  //Update agent if not paused
  if (!paused){
    computeAgentForces(1.0/frameRate);
  }
    //Draw the circle obstacles (linebackers)
  for (int i = 0; i < numObstacles; i++){
    Vec2 c = circlePos[i];
    float r = circleRad[i];
    //circle(c.x,c.y,r*2);
    image(linebacker, c.x, c.y, r + 10, r + 10);
  }
  
    // draw goalposts
  for (int i = 0; i < goalPos.length; i++) {
    image(goalpost, nodePos[goalPos[i]].x, nodePos[goalPos[i]].y, 60, 60); 
  }
  
  
    //Draw graph
  //stroke(100,100,100);
  //strokeWeight(1);
  //for (int i = 0; i < numNodes; i++){
  //  for (int j : neighbors[i]){
  //    if (j == numNodes || j == numNodes + 1) { continue; }
  //    line(nodePos[i].x,nodePos[i].y,nodePos[j].x,nodePos[j].y);
  //  }
  //}
  
    //Draw PRM Nodes
  fill(0);
  for (int i = 0; i < numNodes; i++){
    if (i == numNodes - 1 || i == numNodes - 2) {
      circle(nodePos[i].x,nodePos[i].y, 15);
    } else {
      circle(nodePos[i].x,nodePos[i].y,5);
    }
  }
  
  //computeAgentForces(1/frameRate);
   
  //Draw the green agents
  fill(20,200,150);
  for (int i = 0; i < numAgents; i++){
    //circle(agentPos[i].x, agentPos[i].y, 20);
    image(ball, agentPos[i].x, agentPos[i].y, 50, 50);
  }
}


//Pause/unpause the simulation
void keyPressed(){
  if (key == ' ') paused = !paused;
}
