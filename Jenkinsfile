pipeline {
environment {
    PROJECT = "lets-sail-development"
    APP_NAME = "first-app"
    FE_SVC_NAME = "${APP_NAME}-service"
    CLUSTER = "first-cluster"
    CLUSTER_ZONE = "us-west1-b"
    IMAGE_TAG = "gcr.io/${PROJECT}/${APP_NAME}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
    JENKINS_CRED = "${PROJECT}"
  }
agent {
    kubernetes {
      label 'first-app'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:  
labels:
  component: ci  
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: first-jenkins
  containers:
  - name: first-app
    image: gcr.io/lets-sail-development/first-app:1.0.0
    command:
    - cat
    tty: true
  - name: gcloud
    image: gcr.io/cloud-builders/gcloud
    command:
    - cat
    tty: true
  - name: kubectl
    image: gcr.io/cloud-builders/kubectl
    command:
    - cat
    tty: true
"""
}
  }
  stages {
    stage('Test') {
      steps {
        container('first-app') {
          sh """
            pwd     
            cd firstapp
            python test_firstapp.py
          """
        }
      }
    }
    stage('Build and push image with Container Builder') {
      steps {
        container('gcloud') {
          sh """
          cd firstapp
          PYTHONUNBUFFERED=1 gcloud builds submit -t ${IMAGE_TAG} .
          """
        }
      }
    }
    stage('Deploy Dev') {
      // Developer Branches
      when {
        not { branch 'master' }
        not { branch 'uat' }
      }
      steps {
        container('kubectl') {
          sh("sed -i.bak 's#gcr.io/lets-sail-development/first-app:1.0.0#${IMAGE_TAG}#' ./docker/dev/*.yaml")
          step([$class: 'KubernetesEngineBuilder', namespace: "dev", projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/dev/firstappservice.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
          step([$class: 'KubernetesEngineBuilder', namespace: "dev", projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/dev/firstapp.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: true])
        }
      }
    }
    stage('Deploy uat') {
      // Canary branch
      when { branch 'uat' }
      steps {
        container('kubectl') {
          // Change deployed image in canary to the one we just built
          sh("sed -i.bak 's#gcr.io/lets-sail-development/first-app:1.0.0#${IMAGE_TAG}#' ./docker/uat/*.yaml")
          step([$class: 'KubernetesEngineBuilder', namespace:'uat', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/uat/firstappservice.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
          step([$class: 'KubernetesEngineBuilder', namespace:'uat', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/uat/firstapp.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: true])          
        }
      }
    }
    stage('Deploy Production') {
      // Production branch
      when { branch 'master' }
      steps{
        container('kubectl') {
        // Change deployed image in canary to the one we just built
          sh("sed -i.bak 's#gcr.io/lets-sail-development/first-app:1.0.0#${IMAGE_TAG}#' ./docker/prod/*.yaml")
          step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/prod/firstappservice.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
          step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'docker/prod/firstapp.yaml', credentialsId: env.JENKINS_CRED, verifyDeployments: true])          
        }
      }
    }
  }
}