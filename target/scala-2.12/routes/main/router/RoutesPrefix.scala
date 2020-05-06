// @GENERATOR:play-routes-compiler
// @SOURCE:/home/edmund/Projects/hmda/conf/routes
// @DATE:Wed May 06 08:34:45 BST 2020


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
