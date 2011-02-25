import scala.io.Source
import scala.collection.mutable.ArrayBuffer
import scala.annotation.tailrec

abstract class Thing()

case class Nothing() extends Thing

case class Node(val id:Int,val end:String,val endTwin:String,
		val covShort1:Int,
		val oCovShort1:Int,
		val covShort2:Int,
		val oCovShort2:Int) extends Thing

case class Arc(val startNode:Int,val endNode:Int,val multiplicity:Int) 
     extends Thing

case class ReadPos(val readId:Int,val offsetFromStart:Int,val startCoord:Int)

case class NR(val nodeId:Int,val numberOfReads:Int,reads:Array[ReadPos]) 
     extends Thing

case class NodePos(val nodeId:Int,val offsetFromStart:Int,
		   val startCoord:Int,val endCoord:Int,val offsetFromEnd:Int)

case class Seq(val seqId:Int,nodes:Array[NodePos]) 
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
    val node = new Node(vals(0),end,twin,vals(1),vals(2),vals(3),vals(4))
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
      (Some(newLine),nr)
    } else 
      (None,new NR(vals(0),vals(1),Array[ReadPos]()))
  }

  def readSEQ(line:String,lines:Iterator[String]): (Option[String],Thing) = {
    val vals = line.split(Array('\t',' ')).drop(1).map(_.toInt)
    var newLine = ""
    var newState = 'None
    var ab = new ArrayBuffer[NodePos]()
    
    if (lines.hasNext) {
      do {
	newLine = lines.next
	newState = readState(newLine)
	if (newState == 'None) {
	  val vals=newLine.split('\t').map(_.toInt)
	  ab += new NodePos(vals(0),vals(1),vals(2),vals(3),vals(4))
	}
      } while(newState == 'None && lines.hasNext)
      val seq = new Seq(vals(0),ab.toArray)
      (Some(newLine),seq)
    } else 
      (None,new Seq(vals(0),Array[NodePos]()))
  }

  @tailrec
  def readItem(line:String,lines:Iterator[String],acc:List[Thing]): List[Thing] = {
    val (newLine,thing) = readState(line) match {
      case 'Node => readNode(line,lines)
      case 'Arc => readArc(line,lines)
      case 'NR => readNR(line,lines)
      case 'SEQ => readSEQ(line,lines)
      case _ => (None,new Nothing())
    }

    if (thing.isInstanceOf[Nothing])
      acc
    else
      newLine match {
	case Some(ll) => readItem(ll,lines,thing :: acc)
	case None => acc
      }
  }

  def readGraph(in:Source):List[Thing] = {
    val lines = in.getLines

    val header = lines.next

    println(header)

    if (lines.hasNext)
      readItem(lines.next(),lines,List[Thing]())
    else
      List[Thing]()
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val things = readGraph(Source.fromFile(args(0)))
      for(thing <- things) {
	println(thing)
      }
    }
  }
}
