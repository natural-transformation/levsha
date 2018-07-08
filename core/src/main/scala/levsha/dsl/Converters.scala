package levsha.dsl

import scala.language.implicitConversions

trait Converters[MiscType] {

  import levsha.Document._

  /** Converts String to text document node */
  implicit def stringToNode(value: String): Node[MiscType] =
    Node { rc => rc.addTextNode(value) }

  /** Converts MiscType to text document node */
  implicit def miscToNode(value: MiscType): Node[MiscType] =
    Node { rc => rc.addMisc(value) }

  /** Converts iterable of attributes to document one attr */
  implicit def seqToAttr(xs: Iterable[Attr[MiscType]]): Attr[MiscType] =
    Attr(rc => xs.foreach(f => f(rc)))

  /** Converts iterable of templates to document fragment */
  implicit def seqToNode(xs: Iterable[Node[MiscType]]): Node[MiscType] =
    Node(rc => xs.foreach(f => f(rc))) // Apply render context to elements

  /** Converts sequence of T (which can be converted to Node) to document fragment */
  implicit def arbitrarySeqToNode[T](xs: Iterable[T])(implicit ev: T => Node[MiscType]): Node[MiscType] =
    Node(rc => xs.foreach(f => ev(f).apply(rc)))

  /** Implicitly unwraps optional attributes */
  implicit def optionToAttr(value: Option[Attr[MiscType]]): Attr[MiscType] =
    Attr(rc => if (value.nonEmpty) value.get(rc))

  /** Implicitly unwraps optional documents */
  implicit def optionToNode(value: Option[Node[MiscType]]): Node[MiscType] =
    Node(rc => if (value.nonEmpty) value.get(rc))

  /** Converts option of T (which can be converted to Node) to document node */
  implicit def arbitraryOptionToNode[T](value: Option[T])(implicit ev: T => Node[MiscType]): Node[MiscType] =
    Node(rc => if (value.nonEmpty) ev(value.get).apply(rc))

}