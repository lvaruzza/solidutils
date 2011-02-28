import scala.io.Source

case class Sequence(val id:String,val text:String)

object ReadFasta {
  
  def readFasta(in:Source):Iterator[Sequence] = {
    def readFasta0(header:String,
		   lines:Iterator[String],
		   acc:List[Sequence]): List[Sequence] = {

      var line = ""
      val sb = new StringBuilder()

      do {
	line = lines.next
	if (!line.startsWith(">")) sb.append(line)
      } while (lines.hasNext && !line.startsWith(">"))
      if (lines.hasNext) { 
	readFasta0(line,lines,
		   new Sequence(header.stripPrefix(">"),sb.toString) :: acc)
      } else {
	(new Sequence(header.stripPrefix(">"),sb.toString)) :: acc
      }

    }

    val lines = in.getLines();
    var line = ""
    
    do {
      line = lines.next
    } while (!line.startsWith(">"))
    readFasta0(line,lines,Nil).reverse.iterator
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val seqs = readFasta(Source.fromFile(args(0)))
      for(seq <- seqs) println(seq)
    } else {
      println("Missing arg")
    }
  }
}
