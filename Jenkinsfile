@Library('dst-shared@master') _

dockerBuildPipeline {
        repository = "cray"
        imagePrefix = "hms"
        app = "shcd-parser"
        name = "hms-shcd-parser"
        description = "Cray SHCD Parser"
        dockerfile = "Dockerfile"
        slackNotification = ["", "", false, false, true, true]
        product = "csm"
}