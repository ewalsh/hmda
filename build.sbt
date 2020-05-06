organization := "ai.economicdatasciences"

sbtVersion := "0.13.17"

scalaVersion := "2.12.8"

lazy val root = (project in file(".")).enablePlugins(PlayScala)
pipelineStages := Seq(digest)

libraryDependencies ++= Seq(
    jdbc,
    ehcache,
    ws,
    guice,
    "org.scalatest" %% "scalatest" % "3.3.0-SNAP2" % "test"
)

resolvers += "sonatype-snapshots" at
   "https://oss.sonatype.org/content/repositories/snapshots"
