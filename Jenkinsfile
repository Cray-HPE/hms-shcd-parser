@Library('dst-shared@master') _

dockerBuildPipeline {
        githubPushRepo = "Cray-HPE/hms-shcd-parser"
        repository = "cray"
        imagePrefix = "hms"
        app = "shcd-parser"
        name = "hms-shcd-parser"
        description = "Cray SHCD Parser"
        dockerfile = "Dockerfile"
        slackNotification = ["", "", false, false, true, true]
        product = "csm"
}