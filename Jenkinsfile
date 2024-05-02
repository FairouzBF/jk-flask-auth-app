/* import shared library */
@Library('shared-library')_

pipeline {
  agent any
  
  environment {
    ID_DOCKER = "${ID_DOCKER_PARAMS}"
    IMAGE_NAME = "jk-flask-auth-app"
    IMAGE_TAG = "latest"
  }

  stages {
    stage('Build image') {
      agent any
      steps {
        script { // Étape de construction de l'image Docker
          sh 'docker  builder build --platform linux/arm64 -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .' // Commande Docker pour construire l'image ARM
          sh 'docker builder build --platform linux/amd64 -t ${ID_DOCKER}/$IMAGE_NAME:${IMAGE_TAG}-AMD .' // Commande Docker pour construire l'image AMD
        }
      }
    }
    
    stage('Run container based on builded image') {
      agent any
      steps {
        script {
          sh '''
            echo "Clean Environment"
            docker rm -f $IMAGE_NAME || echo "container does not exist"
            docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:5000 -e PORT=5000 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
            sleep 5
          '''
        }
      }
    }
    
    stage('Test image') {
        agent any
        steps {
            script {
                sh '''
                curl http://localhost:${PORT_EXPOSED} | grep -q "Redirecting..."
                '''
            }
        }
    }
    
    stage('Clean Container') {
      agent any
      steps {
        script {
          sh '''
            docker stop $IMAGE_NAME
            docker rm $IMAGE_NAME
          '''
          }
      }
    }
    
    stage ('Login and Push Image on docker hub') {
      agent any
      environment {
        DOCKERHUB_PASSWORD  = credentials('159e35f1-8092-4d4b-bd1a-d66088a6d6e0')
      }            
      steps {
        script {
          sh '''
            docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
            docker push ${ID_DOCKER}/$IMAGE_NAME:${IMAGE_TAG}-AMD
          '''
        }
      }
    }
    
    stage('Push image in staging and deploy it') {
      when {
        expression { GIT_BRANCH == 'origin/main' }
      }
      agent any
      environment {
        RENDER_STAGING_DEPLOY_HOOK = credentials('render_flask_key')
      }  
      steps {
        script {
          sh '''
            echo "Staging"
            echo $RENDER_STAGING_DEPLOY_HOOK
            curl $RENDER_STAGING_DEPLOY_HOOK
            '''
          }
      }
    }
  }
  
  post {
    always {
      script {
        emailNotifier currentBuild.result
      }
    }  
  }
}
