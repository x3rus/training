pipeline {
  agent {
    node {
      label 'premiertest'
    }
    
  }
  stages {
    stage('test blabla') {
      parallel {
        stage('test blabla') {
          steps {
            sh '''echo "toto balbal"





 





'''
            node(label: 'toto')
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