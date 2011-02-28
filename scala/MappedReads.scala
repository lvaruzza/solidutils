import scala.io.Source

import bio.ReadGraph.readGraph
import bio.ReadFasta.readFasta
import bio.BioSeq

package bio {
  object MappedReads {
    
    def mappedReads(things: Iterator[Thing],seqs0:Iterator[BioSeq]) = {
      val seqs = seqs0.toArray
      println(seqs.length)

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
	val (header,things) = readGraph(Source.fromFile(args(0)))
	val seqs = readFasta(Source.fromFile(args(1)))
	mappedReads(things,seqs)
      }
    }
  }
}
