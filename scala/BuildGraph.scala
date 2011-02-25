import scala.collection.mutable.Map
import ReadGraph.readGraph
import scala.io.Source
import scala.collection.mutable.ArrayBuffer

object BuildGraph {
  def buildGraph(things: List[Thing]) = {
    val nodes = Map[Int,Node]()
    val arcs = ArrayBuffer[Arc]()

    for(thing <- things) {
      if(thing.isInstanceOf[Node]) {
	val node = thing.asInstanceOf[Node]
	nodes += ( node.id -> node)
      } else if (thing.isInstanceOf[Arc]) {
	val arc = thing.asInstanceOf[Arc]
	arcs += arc
      }
    }

    for(arc <- arcs) {
      val source = nodes(arc.startNode.abs);
      val target = nodes(arc.endNode.abs);
      
      println(arc);
      println(source);
      println(target);
    }
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val things = readGraph(Source.fromFile(args(0)))
      buildGraph(things)
    }
  }
}
