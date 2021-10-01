import java.util.PriorityQueue;
import java.util.Collections;

//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of nodes in the PRM
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The function connectNeighbors() will always be called before planPath()
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of the positions in the nodePos array will ever be inside an obstacle
//   - The start and the goal position will never be inside an obstacle

// There are many useful functions in CollisionLibrary.pde and Vec2.pde
// which you can draw on in your implementation. Please add any additional 
// functionality you need to this file (PRM.pde) for compatabilty reasons.

// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it uses BFS which will not provide the shortest path.
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment. This file is
// intended to illustrate the basic set-up for the assignmtent, don't assume 
// this example funcationality is correct and end up copying it's mistakes!).



//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
ArrayList<Node> nodeList = new ArrayList<>();  //Node arraylist
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node




//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes, float eps){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween, eps);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}



//This is probably a bad idea and you shouldn't use it...
int closestNode(Vec2 point, Vec2[] nodePos, int numNodes, Vec2 centers[], float[] radii, int numObstacles, float max_t, float eps){
  int closestID = -1;
  float minDist = 999999;
  for (int i = 0; i < numNodes; i++){
    float dist = nodePos[i].distanceTo(point);
    hitInfo temp = rayCircleListIntersect(centers, radii, numObstacles, point,nodePos[i], max_t, eps);
    if ((dist < minDist) && (!temp.hit)){
      closestID = i;
      minDist = dist;
    }
  }
  return closestID;
}

void connectStartAndGoal(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes, Vec2 start, Vec2 goal){
  Vec2[] startAndEnd = new Vec2[2];
  startAndEnd[0] = start;
  startAndEnd[1] = goal;
  
  // connect the start and goal to the nodes
  for (int i = 0; i < 2; i++){
    neighbors[numNodes+i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(startAndEnd[i]).normalized();
      float distBetween = startAndEnd[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, startAndEnd[i], dir, distBetween, eps);
      if (!circleListCheck.hit){
        neighbors[numNodes+i].add(j);
      }
    }
  }
  
  // connect the nodes to the start and goal
  for (int i = 0; i < numNodes; i++){
    for (int j = 0; j < 2; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = startAndEnd[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(startAndEnd[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, startAndEnd[j], dir, distBetween, eps);
      if (!circleListCheck.hit){
        neighbors[i].add(numNodes+j);
      }
    }
  }
}

ArrayList<Integer> findPath(Node n) {
  ArrayList<Integer> path = new ArrayList();
  while (n != null) {
    path.add(n.ID);
    n = n.parent;
  }
  Collections.reverse(path);
  return path;
}

ArrayList<Integer> planPath(int startPos, int goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  for(int i = 0; i < numNodes; i++){  //make numNodes +2 if we include start and goal nodes
    nodeList.add(i, new Node(i, nodePos[i].distanceTo(nodePos[goalPos]), 0.0, 0.0));
  }
   
  nodeList.add(numNodes, new Node(startPos, nodePos[startPos].distanceTo(nodePos[goalPos]), 0.0, 0.0));   //start node
  nodeList.add(numNodes+1, new Node(goalPos, 0.0, 0.0, 0.0));                       // goal node
  
  Node temp = runAStar(numNodes);
  path = findPath(temp);
  
  return path;
}

//BFS (Breadth First Search)
ArrayList<Integer> runBFS(Vec2[] nodePos, int numNodes, int startID, int goalID){
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  ArrayList<Integer> path = new ArrayList();
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  
  visited[startID] = true;
  fringe.add(startID);
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0){
    int currentNode = fringe.get(0);
    fringe.remove(0);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      if (!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
      }
    } 
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}


Node runAStar(int numNodes){
    PriorityQueue<Node> open = new PriorityQueue<>();
    PriorityQueue<Node> closed = new PriorityQueue<>();
    
    // add first node
    open.add(nodeList.get(numNodes));

    // start algo
    while(!open.isEmpty()){
        //println(openList);
        //println(openList.size());
        Node curr = open.peek();
        if(curr.ID == (nodeList.get(numNodes+1)).ID){
           println("Found!! ");
           return curr;
         }
  
        // go thru each neighbor
        for(int i = 0; i < neighbors[curr.ID].size() ; i++){
            Node succ = nodeList.get(neighbors[curr.ID].get(i));
            float total = curr.g + succ.g;
            
            // perform checks
            if(!open.contains(succ) && !closed.contains(succ)){
                succ.g = total;
                succ.f = succ.g + succ.h;
                succ.parent = curr;
                open.add(succ);
            } else {
                if(total < succ.g){
                    succ.g = total;
                    succ.f = succ.g + succ.h;
                    succ.parent = curr;

                    if(closed.contains(succ)){
                        closed.remove(succ);
                        open.add(succ);
                    }
                }
            }
        }

        open.remove(curr);
        closed.add(curr);
    }
    println("Nothing found");
    return null;
}
