import scala.io.Source
import scala.collection.mutable.ArrayBuffer

abstract class Thing()

case class Nothing() extends Thing

case class Node(val id:Int,val end:String,val endTwin:String,
		val vals:Array[Int]) extends Thing

case class Arc(val startNode:Int,val endNode:Int,val multiplicity:Int) 
     extends Thing

case class ReadPos(val readId:Int,nodeOffSet:Int,startCoord:Int)

case class NR(val nodeId:Int,val numberOfReads:Int,reads:Array[ReadPos]) 
     extends Thing

object ReadGraph {
  val stateRegexp = "^([^ \t\n]+)".r

  def readState(line:String):Symbol = {
    val st = (stateRegexp.findFirstIn(line) match {
      case Some(x) => x match {
	case "NODE" => 'Node
	case "ARC" => 'Arc
	case "NR" => 'NR
	case "SEQ" => 'SEQ
	case _ => 'None
      }
      case None => 'None
    })
    st
  }

  def readNode(line:String,lines:Iterator[String]): (Option[String],Thing)  = {
    val vals = line.split(Array('\t',' ')).drop(1).map(x => x.toInt)
    val end = lines.next()
    val twin = lines.next()
    val node = new Node(vals(0),end,twin,vals.drop(1))
    //println(node)
    if (lines.hasNext)
      (Some(lines.next()),node)
    else
      (None,node)
  }

  def readArc(line:String,lines:Iterator[String]): (Option[String],Thing) = {
    val vals = line.split(Array('\t',' ')).drop(1).map(_.toInt)
    val arc = new Arc(vals(0),vals(1),vals(2))
    //println(arc)
    if (lines.hasNext)
      (Some(lines.next()),arc)
    else
      (None,arc)
  }

  def readNR(line:String,lines:Iterator[String]): (Option[String],Thing) = {
    val vals = line.split(Array('\t',' ')).drop(1).map(_.toInt)
    var newLine = ""
    var newState = 'None
    var ab = new ArrayBuffer[ReadPos]()
    
    if (lines.hasNext) {
      do {
	newLine = lines.next
	newState = readState(newLine)
	if (newState == 'None) {
	  val vals=newLine.split('\t').map(_.toInt)
	  ab += new ReadPos(vals(0),vals(1),vals(2))
	}
      } while(newState == 'None && lines.hasNext)
      val nr = new NR(vals(0),vals(1),ab.toArray)
      println(nr)
      (Some(newLine),nr)
    } else 
      (None,new NR(vals(0),vals(1),Array[ReadPos]()))
  }

  def readItem(line:String,lines:Iterator[String]): Unit = {
    val (newLine,thing) = readState(line) match {
      case 'Node => readNode(line,lines)
      case 'Arc => readArc(line,lines)
      case 'NR => readNR(line,lines)
      case _ => (None,new Nothing())
    }
 
    newLine match {
      case Some(ll) => readItem(ll,lines)
      case None => return
    }
  }

  def readGraph(in:Source) {
    val lines = in.getLines

    val header = lines.next

    println(header)

    if (lines.hasNext) {
      readItem(lines.next(),lines)
    }
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      readGraph(Source.fromFile(args(0)));
    }
  }
}
