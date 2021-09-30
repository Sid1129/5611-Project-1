public class Node implements Comparable<Node>{
  public int ID;            //id of Vec2 in nodePos
  public float h;   //hueristic (straight line distance to goal)
  public float g;   //total path cost from the start to current node
  public float f;   // g+h
  public Node parent = null;     //parent of node for pathfinding purposes
  
  public Node(int id, float h, float g, float f){
    ID = id;
    this.h = h;
    this.g = g;
    this.f = f;
  }
  
  @Override
  public int compareTo(Node rhs){
    //println("hello");
    if((this.h+this.g) < (rhs.h + rhs.g)){
      return -1;
    } else if((this.h+this.g) > (rhs.h + rhs.g)){
      return 1;
    } else {
      return 0;
    }
  }
  
  @Override
  public String toString(){
    float ff = h + g;
    return String.format("ID:" + ID + " f:" + ff);
  }
}
