# CI/CD Pipeline with Jenkins and Docker

A complete CI/CD pipeline implementation using Jenkins, Docker, and GitHub webhooks for a Flask web application.

## 📁 Project Directory Structure

```
cicd-with-jenkins/
├── app.py              # Flask web application
├── Dockerfile          # Multi-stage Docker configuration
├── Jenkinsfile         # Jenkins pipeline configuration
├── README.md           # Project documentation
├── .gitignore          # Git ignore rules
└── .gitattributes      # Git attributes configuration
```

## 🚀 Features

- **Flask Web Application**: Simple Python web app serving on port 5000
- **Multi-stage Dockerfile**: Optimized Docker build for production
- **Jenkins Pipeline**: Automated CI/CD with Build, Test, and Deploy stages
- **GitHub Integration**: Webhook-triggered builds on code changes
- **Docker Containerization**: Consistent deployment environment

## 🏗️ Architecture Overview

The pipeline follows a standard CI/CD workflow:
1. **Source Control**: Code changes pushed to GitHub
2. **Trigger**: GitHub webhook notifies Jenkins
3. **Build**: Jenkins builds Docker image
4. **Test**: Automated testing within container
5. **Deploy**: Container deployment to local environment

## 🐳 Dockerfile Explanation

The project uses a **multi-stage Docker build** for optimization:

### Stage 1: Builder Environment
```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app.py .
RUN pip install flask --no-cache-dir
```
- Uses Python 3.11 slim image as base
- Sets up working directory
- Copies application code
- Installs Flask dependencies

### Stage 2: Runtime Environment
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /app /app
RUN pip install flask --no-cache-dir
EXPOSE 5000
CMD ["python", "app.py"]
```
- Creates clean runtime environment
- Copies built application from builder stage
- Reinstalls runtime dependencies
- Exposes port 5000 for the Flask application
- Sets the default command to run the app

> **Note**: The current Dockerfile installs Flask twice (builder and runtime stages). For optimization, consider using a requirements.txt file and copying the installed packages from the builder stage.

## 📋 Prerequisites

Before setting up the pipeline, ensure you have:

- [x] Jenkins server installed and running
- [x] Docker installed on Jenkins server
- [x] Git plugin installed in Jenkins
- [x] GitHub repository with this project
- [x] ngrok account (for webhook setup)

## 🛠️ Local Setup Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/cicd-with-jenkins.git
cd cicd-with-jenkins
```

### Step 2: Test Local Docker Build

```bash
# Build the Docker image
docker build -t myapp:latest .

# Run the container locally
docker run -d --name myapp -p 5000:5000 myapp:latest

# Test the application
curl http://localhost:5000
# Expected output: "CI/CD Pipeline Working Elegantly on Jenkins + Docker!"

# Clean up
docker stop myapp
docker rm myapp
```

## 🔧 Jenkins Pipeline Setup

### Step 3: Create New Jenkins Job

1. **Open Jenkins Dashboard**
   - Navigate to `http://localhost:8080` (or your Jenkins URL)

2. **Create New Item**
   - Click "New Item"
   - Enter job name: `cicd-with-jenkins`
   - Select "Pipeline"
   - Click "OK"

3. **Configure Pipeline**
   - In "General" section:
     - ✅ Check "GitHub project"
     - Enter Project URL: `https://github.com/samvictordr/cicd-with-jenkins`

4. **Build Triggers**
   - ✅ Check "GitHub hook trigger for GITScm polling"
   - ✅ **Important**: Also check "Poll SCM" (leave the schedule field empty)

5. **Pipeline Configuration**
   - Definition: "Pipeline script from SCM"
   - SCM: "Git"
   - Repository URL: `https://github.com/samvictordr/cicd-with-jenkins.git`
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`

6. **Save Configuration**

### Step 4: Test Manual Build

1. Click "Build Now" to test the pipeline
2. Monitor the build in "Console Output"
3. Verify all stages (Build, Test, Deploy) complete successfully

## Setting up ngrok for GitHub Webhooks

### Step 5: Install and Configure ngrok

1. **Download ngrok**
   ```bash
   # Visit https://ngrok.com/download
   # Sign up for a free account
   # Download the appropriate version for your OS. Alternatively, you can use chocolatey (Windows) or your linux distro's package manager, like:

   choco install ngrok
   sudo apt-get ngrok
   yum install ngrok
   pacman -S ngrok
   nix-shell -p ngrok # Ephemeric run, destroyed after exiting nix shell
   ```

2. **Install ngrok**
   ```bash
   # Extract the downloaded file
   # Add ngrok to your PATH
   
   # Authenticate with your token
   ngrok config add-authtoken YOUR_NGROK_TOKEN
   ```

3. **Expose Jenkins Server**
   ```bash
   # Start ngrok tunnel to Jenkins (assuming Jenkins runs on port 8080)
   ngrok http 8080
   ```

4. **Note the Public URL**
   - ngrok will display a public URL like: `https://abc123.ngrok.io`
   - Keep this terminal window open

### Step 6: Configure GitHub Webhook

1. **Navigate to GitHub Repository**
   - Go to your repository: `https://github.com/your-username/cicd-with-jenkins`

2. **Access Webhook Settings**
   - Click "Settings" tab
   - Click "Webhooks" in the left sidebar
   - Click "Add webhook"

3. **Configure Webhook**
   - **Payload URL**: `https://your-ngrok-url.ngrok.io/github-webhook/`
     - Replace `your-ngrok-url` with your actual ngrok URL
     - Important: Include the trailing slash `/`
   - **Content type**: `application/json`
   - **Secret**: Leave empty (or add for enhanced security)
   - **Events**: Select "Just the push event"
   - ✅ Check "Active"

4. **Save Webhook**
   - Click "Add webhook"
   - GitHub will test the webhook and show a green checkmark if successful

### Step 7: Test the Complete Pipeline

1. **Make a Code Change**
   ```bash
   # Edit app.py
   # Change the return message in the home() function
   git add .
   git commit -m "Test webhook trigger"
   git push origin main
   ```

2. **Verify Automatic Build**
   - Check Jenkins dashboard for new build
   - Monitor build progress
   - Verify deployment success

3. **Test the Application**
   ```bash
   curl http://localhost:5000
   # or just access it from your browser.
   ```

## Pipeline Stages

### Build Stage
```groovy
stage('Build') {
    steps {
        bat 'docker build -t myapp:latest .'
    }
}
```
- Builds Docker image with tag `myapp:latest`
- Uses current directory (`.`) as build context

### Test Stage
```groovy
stage('Test') {
    steps {
        bat 'docker run --rm myapp:latest python -c "print(\'Test Passed\')"'
    }
}
```
- Runs container to test Python execution
- Container is automatically removed (`--rm`) after test
- Prints "Test Passed" if successful

### Deploy Stage
```groovy
stage('Deploy') {
    steps {
        bat '''
        docker stop myapp || true
        docker rm myapp || true
        docker run -d --name myapp -p 5000:5000 myapp:latest
        '''
    }
}
```
- Stops existing container (if running)
- Removes old container
- Starts new container in detached mode (`-d`)
- Maps port 5000 from container to host

## Troubleshooting

### Common Issues

1. **Jenkins Build Fails**
   - Check Docker is installed and running on Jenkins server
   - Verify Jenkins user has Docker permissions
   - Check Console Output for detailed error messages

2. **Webhook Not Triggering**
   - Verify ngrok tunnel is active
   - Check webhook URL includes `/github-webhook/`
   - Ensure Jenkins job has "GitHub hook trigger" enabled

3. **Application Not Accessible**
   - Verify container is running: `docker ps`
   - Check port mapping: `-p 5000:5000`
   - Test locally: `curl http://localhost:5000`

4. **Permission Issues (Linux/Mac)**
   ```bash
   # Add Jenkins user to docker group
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```


## Full Working Demonstration

<details>
<summary>Click to view</summary>

<video width="100%" controls>
  <source src="assets/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

