# n8n on Google Cloud Run with SQLite

This project deploys n8n (workflow automation tool) on Google Cloud Run with persistent SQLite database storage using Google Cloud Storage.

## 🏗️ Architecture

- **n8n**: Latest version running in a Docker container
- **Database**: SQLite with persistent storage via Google Cloud Storage bucket
- **Platform**: Google Cloud Run (serverless, fully managed)
- **CI/CD**: Google Cloud Build for automated deployment

## 📁 Project Structure

```
.
├── Dockerfile          # Docker image configuration
├── startup.sh          # Container startup script
├── cloudbuild.yaml     # Google Cloud Build configuration
└── README.md           # This file
```

## 🐳 Docker Configuration

### Dockerfile
- Based on the official n8n Docker image (`docker.n8n.io/n8nio/n8n:latest`)
- Creates a data directory with proper permissions
- Includes custom startup script for Cloud Storage integration

### startup.sh
- Creates symbolic link from Cloud Storage mount to n8n data directory
- Ensures persistent data storage across container restarts

## ☁️ Google Cloud Setup

### Prerequisites
1. Google Cloud Project with billing enabled
2. Enable the following APIs:
   - Cloud Run API
   - Cloud Build API
   - Container Registry API
   - Cloud Storage API

### Required Resources
1. **Cloud Storage Bucket**: `my-n8n-on-gcp-cloud-run-n8n-vol`
2. **Container Registry**: `gcr.io/my-n8n-on-gcp-cloud-run`

## 🚀 Deployment

### Automatic Deployment (Recommended)
1. Connect this repository to Google Cloud Build
2. Push changes to trigger automatic deployment
3. Cloud Build will:
   - Build the Docker image
   - Push to Container Registry
   - Deploy to Cloud Run

### Manual Deployment
```bash
# Build and push Docker image
docker build -t gcr.io/YOUR_PROJECT_ID/n8n-sqlite:latest .
docker push gcr.io/YOUR_PROJECT_ID/n8n-sqlite:latest

# Deploy to Cloud Run
gcloud run deploy n8n-sqlite \
  --image gcr.io/YOUR_PROJECT_ID/n8n-sqlite:latest \
  --region us-central1 \
  --platform managed \
  --memory 512Mi \
  --min-instances 1 \
  --max-instances 1 \
  --allow-unauthenticated \
  --set-env-vars N8N_DB_SQLITE_FILE=/mnt/data/database.sqlite \
  --add-volume name=volume-1,type=cloud-storage,bucket=YOUR_BUCKET_NAME,target=/mnt/data
```

## ⚙️ Configuration

### Environment Variables
- `N8N_DB_SQLITE_FILE`: Path to SQLite database file (`/mnt/data/database.sqlite`)

### Cloud Run Settings
- **Memory**: 512Mi
- **CPU**: Default (1 vCPU)
- **Instances**: Min 1, Max 1 (for consistent database access)
- **Authentication**: Disabled (public access)

### Storage
- **Type**: Google Cloud Storage bucket mounted as volume
- **Mount Point**: `/mnt/data`
- **Database File**: `database.sqlite`

## 🔧 Customization

### Update Project Configuration
1. Replace `my-n8n-on-gcp-cloud-run` with your Google Cloud Project ID in `cloudbuild.yaml`
2. Update bucket name in the Cloud Build configuration
3. Modify resource limits as needed

### Environment Variables
Add additional n8n environment variables in the `cloudbuild.yaml` file:
```yaml
- '--set-env-vars'
- 'N8N_DB_SQLITE_FILE=/mnt/data/database.sqlite,N8N_HOST=your-domain.com'
```

## 📊 Monitoring

- **Cloud Run Logs**: View in Google Cloud Console
- **Metrics**: CPU, Memory, Request count available in Cloud Monitoring
- **Health Checks**: Automatic via Cloud Run

## 🔒 Security Considerations

- Currently configured for public access (`--allow-unauthenticated`)
- For production, consider:
  - Enabling authentication
  - Setting up custom domain with SSL
  - Implementing proper IAM roles
  - Network security policies

## 💰 Cost Optimization

- **Pay-per-use**: Only charged when processing requests
- **Minimum instances**: Set to 1 to avoid cold starts
- **Memory allocation**: 512Mi (adjust based on workflow complexity)

## 🛠️ Troubleshooting

### Common Issues
1. **Database connection errors**: Check Cloud Storage bucket permissions
2. **Memory issues**: Increase memory allocation in Cloud Run
3. **Cold starts**: Consider increasing minimum instances

### Logs
```bash
# View Cloud Run logs
gcloud logs read --service=n8n-sqlite --region=us-central1
```

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Google Cloud Build Documentation](https://cloud.google.com/build/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
