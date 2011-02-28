import scala.io.Source
import scala.annotation.tailrec

package bio {
  case class BioSeq(val id:String,val text:String)

  object ReadFasta {
    
    def readFasta(in:Source):Iterator[BioSeq] = {

      @tailrec
      def readFasta0(header:String,
		     lines:Iterator[String],
		     acc:List[BioSeq]): List[BioSeq] = {

	var line = ""
	val sb = new StringBuilder()

	do {
	  line = lines.next
	  //Console.err.println("# " + line)
	  
	  if (!line.startsWith(">")) sb.append(line)
	} while (lines.hasNext && !line.startsWith(">"))

	if (lines.hasNext) { 
	  readFasta0(line,lines,
		     new BioSeq(header.stripPrefix(">"),sb.toString) :: acc)
	} else {
	  (new BioSeq(header.stripPrefix(">"),sb.toString)) :: acc
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
}
