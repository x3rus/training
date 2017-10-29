pipeline {
  agent {
    node {
      label 'master'
    }
    
  }
  stages {
    stage('test blabla') {
      parallel {
        stage('test blabla') {
          steps {
            sh '''echo "toto balbal"





 





'''
            node(label: 'master')
          }
        }
        stage('titi') {
          steps {
            sh '''echo "
toto"


'''
          }
        }
      }
    }
  }
  environment {
    TOTO = 'blabal'
  }
}