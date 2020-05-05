// @GENERATOR:play-routes-compiler
// @SOURCE:C:/Users/DELL/Projects/hmda/conf/routes
// @DATE:Tue May 05 19:25:56 BST 2020


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
