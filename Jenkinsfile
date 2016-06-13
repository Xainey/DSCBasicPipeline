node('windows') {
    // May not need this stage if using Jenkins SCM to checkout Jenkinsfile
    stage 'Stage 1: Build'
    git url: 'https://github.com/Xainey/DSCBasicPipeline.git'

    stage 'Stage 2: Analyze'
    posh './build.ps1 -Task JenkinsAnalyze'

    stage 'Stage 3: Test'
    posh './build.ps1 -Task JenkinsTest'

    // Remove this step, if QA deploy should be automatic
    stage 'Stage 4: Approve QA'
    input 'Deploy to QA?'

    stage 'Stage 5: QA Deploy'
    posh './build.ps1 -Task JenkinsDeploy -Server <QA_SERVER>'

    // Add steps here to trigger approval to deploy to production or trigger another build
}
def posh(cmd) {
  bat 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& ' + cmd + '"'
}