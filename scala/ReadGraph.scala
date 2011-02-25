import scala.io.Source

case class Node(val id:Int,val end:String,val endTwin:String,
		val vals:Array[Int]);

case class Arc(val startNode:Int,val endNode:Int,val multiplicity:Int);

object ReadGraph {
  val stateRegexp = "^([^ \t\n]+)".r

  def readState(line:String):Symbol = {
    val st = (stateRegexp.findFirstIn(line) match {
      case Some(x) => x match {
	case "NODE" => 'Node
	case "ARC" => 'Arc
	case _ => 'None
      }
      case None => 'None
    })
    st
  }

  def readNode(line:String,lines:Iterator[String]) = {
    val vals = line.split(Array('\t',' ')).drop(1).map(x => x.toInt)
    val end = lines.next()
    val twin = lines.next()
    val node = new Node(vals(0),end,twin,vals.drop(1))
    println(node)
    node
  }

  def readArc(line:String) = {
    val vals = line.split(Array('\t',' ')).drop(1).map(x => x.toInt)
    val arc = new Arc(vals(0),vals(1),vals(2))
    println(arc)
    arc
  }

  def readGraph(in:Source) {
    val lines = in.getLines

    val header = lines.next

    println(header)

    var state = 'none

    while(lines.hasNext) {
      val line = lines.next
      readState(line) match {
	case 'Node => readNode(line,lines)
	case 'Arc => readArc(line)
	case _ => ()
      }
    }
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      readGraph(Source.fromFile(args(0)));
    }
  }
}
