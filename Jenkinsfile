pipeline {
   agent any
   stages {
       stage('Copy Base Backup') {
           steps {
               sh 'sudo ansible dbslave -m service -a "name=postgresql state=stopped"'
               sh 'sudo ansible dbslave -a "whoami"'
               sh 'sudo ansible dbslave -a "rm -rf /var/lib/postgresql/11/main/*"'
               sh 'sudo ansible dbslave -a "cp -r /basebackup/* /var/lib/postgresql/11/main/"' 
               sh 'sudo ansible dbslave -a "rm -rf /var/lib/postgresql/11/main/pg_wal/*"'
           }    
       }
       stage('Import File Recovry') {
           steps {                
               sh 'sudo ansible dbslave -a "cp /var/lib/postgresql/recovery.conf /var/lib/postgresql/11/main/recovery.conf"' 
               sh 'sudo ansible dbslave -a "chown -R postgres.postgres /var/lib/postgresql/"'         
           }
       }
       stage('Restart Service Postgresql') {
        //    environment {
        //        registryCredential = 'dockerhub'
        //    }
           steps{
               sh 'sudo ansible dbslave -m service -a "name=postgresql state=started"'
               sh 'sudo ansible dbslave -a "cat /var/log/postgresql/postgresql-11-main.log"'
           }
       }

   }
}

// pipeline {
//    agent any
//    stages {
//        stage('Copy Base Backup') {
//            steps {
//                sh 'sudo systemctl stop postgresql'
//                sh 'sudo su - postgres -c "whoami"'
//                sh 'sudo su - postgres -c "rm -rf /var/lib/postgresql/11/main/*"'
//                sh 'sudo su - postgres -c "cp -r /basebackup/* /var/lib/postgresql/11/main/"' 
//                sh 'sudo su - postgres -c "rm -rf /var/lib/postgresql/11/main/pg_wal/*"'
               
//            }    
//        }
//        stage('Import File Recovry') {
//            steps {                
//                sh 'sudo su - postgres -c "cp /var/lib/postgresql/recovery.conf /var/lib/postgresql/11/main/recovery.conf"'          
//            }
//        }
//        stage('Restart Service Postgresql') {
//         //    environment {
//         //        registryCredential = 'dockerhub'
//         //    }
//            steps{
//                sh 'sudo systemctl start postgresql'
//                sh 'sudo systemctl status postgresql'
//                sh 'sudo su - postgres -c "cat /var/log/postgresql/postgresql-11-main.log"'
//            }
//        }

//    }
// }



