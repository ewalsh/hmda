// @GENERATOR:play-routes-compiler
// @SOURCE:C:/Users/DELL/Projects/hmda/conf/routes
// @DATE:Thu May 07 21:24:21 BST 2020


package router {
  object RoutesPrefix {
    private var _prefix: String = "/"
    def setPrefix(p: String): Unit = {
      _prefix = p
    }
    def prefix: String = _prefix
    val byNamePrefix: Function0[String] = { () => prefix }
  }
}
