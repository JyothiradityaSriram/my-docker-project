// Jenkinsfile (Declarative) — converted from your YAML pipeline
pipeline {
  agent any

  environment {
    // === Basic settings (replace placeholders) ===
    BUILD_TYPE            = "${env.BUILD_TYPE ?: 'npm'}"            // 'npm' or 'rust'
    APP_NAME              = "${env.APP_NAME ?: 'project-frontend'}"
    IMAGE_TAG             = "${env.IMAGE_TAG ?: "1.0.${env.BUILD_NUMBER ?: 'SNAP'}"}"
    REGISTRY              = "${env.REGISTRY ?: 'nexus3.systems.xx.xxxx:18080/xxxxx-128489-hffbhbhrvh-ehf'}"
    IMAGE                 = "${REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
    // Sonar
    SONAR_PROJECT_KEY     = "${env.SONAR_PROJECT_KEY ?: 'project-frontend'}"
    SONAR_CREDENTIAL_ID   = "${env.SONAR_CREDENTIAL_ID ?: 'SONAR-CUBE-SECRET'}"
    // Nexus IQ
    IQ_CLI_PATH           = "${env.IQ_CLI_PATH ?: '/opt/iq-cli/nexus-iq-cli.jar'}"
    IQ_APP_NAME           = "${env.IQ_APP_NAME ?: '12553775_tyr'}"
    IQ_SERVER_URL         = "${env.IQ_SERVER_URL ?: 'https://iq.server.local'}"
    IQ_CREDENTIAL_ID      = "${env.IQ_CREDENTIAL_ID ?: 'SONARTYPEIQ-CREDS'}"
    // Cyberflow
    CYBERFLOW_CREDENTIAL_ID = "${env.CYBERFLOW_CREDENTIAL_ID ?: 'CYBERFLOW-CREDS'}"
    CYBERFLOW_CMD         = "${env.CYBERFLOW_CMD ?: 'cyberflow scan -p .'}"
    // Kaniko
    KANIKO_IMAGE          = "gcr.io/kaniko-project/executor:latest"
    // GKE
    GKE_CLUSTER           = "${env.GKE_CLUSTER ?: 'my-gke-cluster'}"
    GKE_LOCATION          = "${env.GKE_LOCATION ?: 'us-central1'}"
    GCP_PROJECT           = "${env.GCP_PROJECT ?: 'my-gcp-project'}"
    GCP_SA_CRED_ID        = "${env.GCP_SA_CRED_ID ?: 'GCP-SERVICE-ACCOUNT-KEY'}" // file credential ID (JSON)
    // Docker registry credentials placeholder (username/password or token)
    NEXUS_DOCKER_CRED_ID  = "${env.NEXUS_DOCKER_CRED_ID ?: 'NEXUS-DOCKER-CREDS'}"
    // additional flags from YAML
    SONAR_ENABLED         = "${env.SONAR_ENABLED ?: 'true'}"
    IQ_ENABLED            = "${env.IQ_ENABLED ?: 'true'}"
    CYBERFLOW_ENABLED     = "${env.CYBERFLOW_ENABLED ?: 'true'}"
    SAST_ENABLED          = "${env.SAST_ENABLED ?: 'true'}"
    DAST_ENABLED          = "${env.DAST_ENABLED ?: 'false'}"
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '30'))
    timestamps()
    ansiColor('xterm')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        script {
          echo "Build type: ${env.BUILD_TYPE}"
          echo "Image: ${env.IMAGE}"
        }
      }
    }

    stage('Prepare Environment') {
      steps {
        script {
          // Example: set npm registry for npm builds if needed
          if (env.BUILD_TYPE == 'npm') {
            echo "NPM build selected"
          } else if (env.BUILD_TYPE == 'rust') {
            echo "Rust build selected"
          } else {
            error("Unsupported BUILD_TYPE: ${env.BUILD_TYPE}")
          }
        }
      }
    }

    stage('SonarQube Analysis') {
      when { expression { return env.SONAR_ENABLED == 'true' } }
      steps {
        withCredentials([string(credentialsId: SONAR_CREDENTIAL_ID, variable: 'SONAR_TOKEN')]) {
          script {
            // This assumes sonar-scanner is installed on the agent or available in PATH
            // For Rust projects, you may need sonar-scanner + sonar properties; adapt as needed
            sh """
              echo "Running SonarQube analysis for project ${SONAR_PROJECT_KEY}"
              sonar-scanner \
                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                -Dsonar.sources=. \
                -Dsonar.login=${SONAR_TOKEN}
            """
          }
        }
      }
    }

    stage('Nexus IQ Scan') {
      when { expression { return env.IQ_ENABLED == 'true' } }
      steps {
        withCredentials([usernamePassword(credentialsId: IQ_CREDENTIAL_ID, usernameVariable: 'IQ_USER', passwordVariable: 'IQ_PASS')]) {
          script {
            // IQ CLI scan example: adapt path / args to your organization's usage
            sh """
              echo "Running Nexus IQ scan for application ${IQ_APP_NAME}"
              java -jar ${IQ_CLI_PATH} \
                -s ${IQ_SERVER_URL} \
                -a ${IQ_USER}:${IQ_PASS} \
                -i ${IQ_APP_NAME} \
                -t Application -a ${IQ_APP_NAME} \
                -r /tmp/iq-report
            """
          }
        }
      }
    }

    stage('CyberFlow Scans') {
      when { expression { return env.CYBERFLOW_ENABLED == 'true' } }
      steps {
        withCredentials([string(credentialsId: CYBERFLOW_CREDENTIAL_ID, variable: 'CYBERFLOW_TOKEN')]) {
          script {
            if (env.SAST_ENABLED == 'true') {
              sh """
                echo "Running CyberFlow SAST scan"
                ${CYBERFLOW_CMD} --type sast --auth ${CYBERFLOW_TOKEN} || true
              """
            }
            if (env.DAST_ENABLED == 'true') {
              sh """
                echo "Running CyberFlow DAST scan"
                ${CYBERFLOW_CMD} --type dast --auth ${CYBERFLOW_TOKEN} || true
              """
            }
          }
        }
      }
    }

    stage('Build Application') {
      steps {
        script {
          if (env.BUILD_TYPE == 'npm') {
            sh '''
              echo "npm cache clean"
              npm cache clean --force || true
              echo "set npm registry"
              npm set registry ${NPM_REGISTRY_URL:-"https://npm.xxx.sx.xxx:8081/nexus/repository/npm-group/"}
              npm install
              npm run test || true
            '''
          } else if (env.BUILD_TYPE == 'rust') {
            sh '''
              echo "Building Rust project with cargo"
              cargo clean || true
              cargo build --release
            '''
          } else {
            error "Unknown BUILD_TYPE: ${env.BUILD_TYPE}"
          }
        }
      }
    }

    stage('Prepare Image Build (Kaniko)') {
      steps {
        script {
          // Create a build context tar if required, or rely on Kaniko --context=dir://
          sh 'ls -la'
        }
      }
    }

    stage('Kaniko Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: NEXUS_DOCKER_CRED_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          script {
            // Create a small config for Docker registry auth for Kaniko, or use --insecure if internal
            def registryHost = REGISTRY.split('/')[0]
            writeFile file: 'kaniko-dockerconfig.json', text: """{
  "auths": {
    "${registryHost}": {
      "auth": "${ "${NEXUS_USER}:${NEXUS_PASS}".bytes.encodeBase64() }"
    }
  }
}"""
            // Run Kaniko to build and push image. This runs Kaniko in Docker; requires Docker available on agent.
            sh """
              docker run --rm -v `pwd`:/workspace -v `pwd`/kaniko-dockerconfig.json:/kaniko/.docker/config.json ${KANIKO_IMAGE} \
                --context=/workspace \
                --dockerfile=/workspace/Dockerfile \
                --destination=${IMAGE} \
                --skip-tls-verify=true \
                --verbosity=info
            """
          }
        }
      }
    }

    stage('Post-Build Scans & Policies') {
      steps {
        script {
          // You can place extra policy checks, coverage reports publishing etc here.
          echo "Post-build checks (coverage, artifact metadata) go here."
        }
      }
    }

    stage('Deploy to GKE') {
      when { expression { return env.GKE_CLUSTER && env.GCP_SA_CRED_ID } }
      steps {
        withCredentials([file(credentialsId: GCP_SA_CRED_ID, variable: 'GCP_SA_KEY')]) {
          script {
            sh """
              echo "Authenticating to GCP and getting GKE credentials"
              gcloud auth activate-service-account --key-file=${GCP_SA_KEY}
              gcloud config set project ${GCP_PROJECT}
              gcloud container clusters get-credentials ${GKE_CLUSTER} --region ${GKE_LOCATION} --project ${GCP_PROJECT}
              echo "Updating deployment ${env.DEPLOYMENT_NAME ?: APP_NAME} image to ${IMAGE}"
              kubectl set image deployment/${env.DEPLOYMENT_NAME ?: APP_NAME} ${env.CONTAINER_NAME ?: APP_NAME}=${IMAGE} --namespace ${env.K8S_NAMESPACE ?: 'default'}
            """
          }
        }
      }
    }
  }

  post {
    always {
      script {
        echo "Archive artifacts / publish reports here"
        // e.g. junit, publishHTML, stash/unstash, etc
      }
    }
    success {
      echo "Build succeeded: ${env.BUILD_URL}"
    }
    failure {
      echo "Build failed: ${env.BUILD_URL}"
    }
  }
}

