pipeline {
  agent { label 'generic' }

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  stages {
    stage('betterleaks') {
      agent { label 'betterleaks' }
      steps {
        withChecks('betterleaks') {
          sh 'betterleaks git . --redact --no-banner --verbose'
        }
      }
    }

    stage('shell-lint') {
      steps {
        withChecks('shell-lint') {
          sh 'WYWY_REQUIRE_SHELLCHECK=1 scripts/tests/lint.sh'
        }
      }
    }

    stage('shell-unit') {
      steps {
        withChecks('shell-unit') {
          sh 'scripts/tests/unit.sh'
        }
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
