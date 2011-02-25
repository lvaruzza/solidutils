import scala.io.Source

case class Sequence(val id:String,val text:String)

object FastaReader {
  
  def readFasta(in:Source):List[Sequence] {
    def readFasta0(header:String,lines:Iterator[String]) {
      
      do {
	
      }
    }
    val lines = in.getLines

    readFasta0(lines.next,lines)
  }

  def main(args:Array[String]) {
    if (args.length > 0) {
      val seqs = readFasta(Source.fromFile(args(0)))
    }
  }
}
