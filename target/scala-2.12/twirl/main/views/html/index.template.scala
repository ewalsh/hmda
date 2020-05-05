
package views.html

import _root_.play.twirl.api.TwirlFeatureImports._
import _root_.play.twirl.api.TwirlHelperImports._
import _root_.play.twirl.api.Html
import _root_.play.twirl.api.JavaScript
import _root_.play.twirl.api.Txt
import _root_.play.twirl.api.Xml
import models._
import controllers._
import play.api.i18n._
import views.html._
import play.api.templates.PlayMagic._
import play.api.mvc._
import play.api.data._

object index extends _root_.play.twirl.api.BaseScalaTemplate[play.twirl.api.HtmlFormat.Appendable,_root_.play.twirl.api.Format[play.twirl.api.HtmlFormat.Appendable]](play.twirl.api.HtmlFormat) with _root_.play.twirl.api.Template1[String,play.twirl.api.HtmlFormat.Appendable] {

  /**/
  def apply/*1.2*/(timeStr: String):play.twirl.api.HtmlFormat.Appendable = {
    _display_ {
      {


Seq[Any](format.raw/*1.19*/("""
"""),format.raw/*2.1*/("""<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Home</title>
        <link rel="shortcut icon" type="image/svg"
            href=""""),_display_(/*7.20*/routes/*7.26*/.Assets.versioned("images/OWblocks.svg")),format.raw/*7.66*/("""">
    </head>
    <body>
        <h1>Getting Started</h1>
        <div>Current Time: """),_display_(/*11.29*/timeStr),format.raw/*11.36*/("""</div>
    </body>
</html>
"""))
      }
    }
  }

  def render(timeStr:String): play.twirl.api.HtmlFormat.Appendable = apply(timeStr)

  def f:((String) => play.twirl.api.HtmlFormat.Appendable) = (timeStr) => apply(timeStr)

  def ref: this.type = this

}


              /*
                  -- GENERATED --
                  DATE: 2020-05-05T20:55:24.368
                  SOURCE: C:/Users/DELL/Projects/hmda/app/views/index.scala.html
                  HASH: 20ba3afad2c07cd261551f966c42e81fd66c22e9
                  MATRIX: 729->1|841->18|869->20|1042->167|1056->173|1116->213|1234->304|1262->311
                  LINES: 21->1|26->1|27->2|32->7|32->7|32->7|36->11|36->11
                  -- GENERATED --
              */
          