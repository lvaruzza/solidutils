import scala.io.Source

case class Sequence(val id:String,val text:String)

object ReadFasta {
  
  def readFasta(in:Source):List[Sequence] = {
    def readFasta0(header:String,
		   lines:Iterator[String],
		   acc:List[Sequence]): List[Sequence] = {

      val (seq,rest) = lines.partition(_.startsWith(">"))
      println("# " + header + " " + seq.toArray.mkString(""))
      if (rest.hasNext) { 
	readFasta0(rest.next,rest,
		   new Sequence(header,seq.toArray.mkString("")) :: acc)
      } else {
	acc
      }

    }

    val lines = in.getLines();
    var line = ""
    
    do {
      line = lines.next
    } while (!line.startsWith(">"))
    readFasta0(line,lines,Nil)
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val seqs = readFasta(Source.fromFile(args(0)))
      println(seqs)
    } else {
      println("Missing arg")
    }
  }
}
