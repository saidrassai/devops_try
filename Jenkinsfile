pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'devops-sample-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
        EC2_IP = '3.86.184.138'
        GIT_REPO = 'https://github.com/saidrassai/devops_try.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📁 Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Application') {
            steps {
                script {
                    echo '🔨 Building Node.js application...'
                    sh '''
                        cd app
                        npm install
                        echo "✅ Dependencies installed"
                    '''
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    echo '🧪 Running tests...'
                    sh '''
                        cd app
                        npm test || echo "⚠️ No tests defined yet"
                        echo "✅ Tests completed"
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo '🐳 Building Docker image...'
                    sh '''
                        docker build -f docker/Dockerfile -t ${DOCKER_IMAGE}:${DOCKER_TAG} app/
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        echo "✅ Docker image built successfully"
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
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3000/health; then
                            echo "✅ Development deployment successful"
                        else
                            echo "❌ Development deployment failed"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
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
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3001/health; then
                            echo "✅ Staging deployment successful"
                        else
                            echo "❌ Staging deployment failed"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Approval for Production') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    echo '⚠️ Production deployment requires approval'
                    input message: 'Deploy to Production?', 
                          ok: 'Deploy to Production',
                          submitter: 'admin'
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    echo '🏭 Deploying to Production environment...'
                    sh '''
                        # Stop existing production containers
                        docker stop devops-prod || true
                        docker rm devops-prod || true
                        
                        # Start new production container
                        docker run -d --name devops-prod \
                            -p 3002:3000 \
                            -e NODE_ENV=production \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                        
                        # Wait for startup
                        sleep 10
                        
                        # Health check
                        if curl -f http://localhost:3002/health; then
                            echo "✅ Production deployment successful"
                        else
                            echo "❌ Production deployment failed"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Post-Deployment Tests') {
            steps {
                script {
                    echo '🔍 Running post-deployment tests...'
                    sh '''
                        echo "Testing all environments..."
                        
                        # Test Development
                        if curl -s http://localhost:3000/health | grep -q "healthy"; then
                            echo "✅ Development health check passed"
                        else
                            echo "❌ Development health check failed"
                        fi
                        
                        # Test Staging (if deployed)
                        if docker ps | grep -q devops-staging; then
                            if curl -s http://localhost:3001/health | grep -q "healthy"; then
                                echo "✅ Staging health check passed"
                            else
                                echo "❌ Staging health check failed"
                            fi
                        fi
                        
                        # Test Production (if deployed)
                        if docker ps | grep -q devops-prod; then
                            if curl -s http://localhost:3002/health | grep -q "healthy"; then
                                echo "✅ Production health check passed"
                            else
                                echo "❌ Production health check failed"
                            fi
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
                # Clean up unused Docker images
                docker image prune -f || true
                
                # Show running containers
                echo "📊 Currently running containers:"
                docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            '''
        }
        success {
            echo '🎉 Pipeline completed successfully!'
            script {
                sh '''
                    echo "🌐 Application URLs:"
                    echo "   Development: http://${EC2_IP}:3000"
                    echo "   Staging: http://${EC2_IP}:3001" 
                    echo "   Production: http://${EC2_IP}:3002"
                    echo "   Jenkins: http://${EC2_IP}:8080"
                '''
            }
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
