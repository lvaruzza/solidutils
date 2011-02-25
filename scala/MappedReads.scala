import ReadGraph.readGraph
import scala.io.Source

object MappedReads {
  
  def mappedReads(things: List[Thing]) {
    for(thing <- things) {
      if(thing.isInstanceOf[NR]) {
	val nr = thing.asInstanceOf[NR]
	println("Node " + nr.nodeId)
	for (read <- nr.reads) {
	  println("\t" + read.readId + " " + read.offsetFromStart + " "+ read.startCoord)
	}
      } else if(thing.isInstanceOf[SEQ]) {
	val seq = thing.asInstanceOf[SEQ]
      }
    }
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val things = readGraph(Source.fromFile(args(0)))
      mappedReads(things)
    }
  }
}

