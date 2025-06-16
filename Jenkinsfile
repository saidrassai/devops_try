pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'devops-sample-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        EC2_IP = '3.86.184.138'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📁 Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo '🐳 Building Docker image...'
                    sh '''
                        echo "Building Docker image with tag: ${DOCKER_TAG}"
                        docker build -f docker/Dockerfile -t ${DOCKER_IMAGE}:${DOCKER_TAG} app/
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        echo "✅ Docker image built successfully"
                    '''
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo '🧪 Testing Docker image...'
                    sh '''
                        echo "Testing if image runs correctly..."
                        docker run --rm -d --name test-container -p 9999:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        sleep 5
                        
                        # Test if container is running and responding
                        if curl -f http://localhost:9999/health; then
                            echo "✅ Docker image test passed"
                        else
                            echo "❌ Docker image test failed"
                            exit 1
                        fi
                        
                        # Clean up test container
                        docker stop test-container || true
                    '''
                }
            }
        }
        
        stage('Deploy to Development') {
            steps {
                script {
                    echo '🚀 Deploying to Development environment...'
                    sh '''
                        # Stop existing dev containers
                        docker stop devops-dev || true
                        docker rm devops-dev || true
                        
                        # Start new dev container
                        docker run -d --name devops-dev \
                            -p 3000:3000 \
                            -e NODE_ENV=development \
                            --restart unless-stopped \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3000/health; then
                            echo "✅ Development deployment successful"
                            echo "🌐 Available at: http://${EC2_IP}:3000"
                        else
                            echo "❌ Development deployment failed"
                            docker logs devops-dev
                            exit 1
                        fi
                    '''
                }
            }
        }
          stage('Deploy to Staging') {
            steps {
                script {
                    echo '🎭 Deploying to Staging environment...'
                    sh '''
                        # Stop existing staging containers
                        docker stop devops-staging || true
                        docker rm devops-staging || true
                        
                        # Start new staging container
                        docker run -d --name devops-staging \
                            -p 3001:3000 \
                            -e NODE_ENV=staging \
                            --restart unless-stopped \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3001/health; then
                            echo "✅ Staging deployment successful"
                            echo "🌐 Available at: http://${EC2_IP}:3001"
                        else
                            echo "❌ Staging deployment failed"
                            docker logs devops-staging
                            exit 1
                        fi
                    '''
                }
            }        }
        
        stage('Deploy to Production') {
            steps {                script {
                    echo '🏭 Deploying to Production environment...'
                    echo '⚠️ Auto-deploying to production for demo purposes'
                    sh '''
                        # Stop existing production containers
                        docker stop devops-prod || true
                        docker rm devops-prod || true
                        
                        # Start new production container
                        docker run -d --name devops-prod \
                            -p 3002:3000 \
                            -e NODE_ENV=production \
                            --restart unless-stopped \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3002/health; then
                            echo "✅ Production deployment successful"
                            echo "🌐 Available at: http://${EC2_IP}:3002"
                        else
                            echo "❌ Production deployment failed"
                            docker logs devops-prod
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            sh '''
                # Clean up test containers
                docker stop test-container || true
                docker rm test-container || true
                
                # Clean up unused Docker images
                docker image prune -f || true
                
                # Show running containers
                echo "📊 Currently running containers:"
                docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
            '''
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            sh '''
                echo "🌐 Application URLs:"
                echo "   Development: http://${EC2_IP}:3000"
                echo "   Staging: http://${EC2_IP}:3001" 
                echo "   Production: http://${EC2_IP}:3002"
                echo "   Jenkins: http://${EC2_IP}:8080"
            '''
        }
        failure {
            echo '❌ Pipeline failed!'
            sh '''
                echo "🔍 Checking logs for debugging..."
                docker logs devops-dev || true
                docker logs devops-staging || true  
                docker logs devops-prod || true
            '''
        }
    }
}
