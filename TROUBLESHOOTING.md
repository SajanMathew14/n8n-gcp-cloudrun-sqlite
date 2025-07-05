# Cloud Run Deployment Troubleshooting Guide

## Recent Fixes Applied

The following changes were made to resolve the "container failed to start" error:

### 1. Dockerfile Updates
- Added `EXPOSE 8080` directive
- Set `N8N_HOST=0.0.0.0` (required for Cloud Run)
- Added essential n8n environment variables
- Enabled metrics for better monitoring

### 2. Startup Script Improvements
- Added volume mount verification with retry logic
- Added proper error handling and logging
- Set all required n8n environment variables
- Added database directory creation
- Used `exec` for proper signal handling

### 3. Cloud Build Configuration
- Increased memory from 512Mi to 1Gi (n8n needs more memory)
- Added CPU allocation (1 CPU)
- Increased timeout to 300 seconds
- Added all required environment variables
- Improved resource allocation

## Common Issues and Solutions

### Issue: Container fails to start
**Symptoms:** "Revision is not ready and cannot serve traffic"
**Solutions:**
1. Check that n8n is binding to `0.0.0.0:8080` (not `localhost`)
2. Ensure sufficient memory allocation (minimum 1Gi for n8n)
3. Verify volume mount is accessible
4. Check startup timeout settings

### Issue: Database connection errors
**Symptoms:** SQLite database errors in logs
**Solutions:**
1. Verify Cloud Storage bucket exists and is accessible
2. Check volume mount permissions
3. Ensure database directory is writable
4. Verify `N8N_DB_SQLITE_FILE` path is correct

### Issue: Slow startup
**Symptoms:** Deployment times out during startup
**Solutions:**
1. Increase Cloud Run timeout (currently set to 300s)
2. Use startup probes with longer initial delay
3. Check volume mount performance
4. Monitor memory usage

## Debugging Commands

### Check Cloud Run logs:
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=n8n-sqlite" --limit=50 --format="table(timestamp,textPayload)"
```

### Test container locally:
```bash
# Build the image
docker build -t n8n-test .

# Run with environment variables
docker run -p 8080:8080 \
  -e PORT=8080 \
  -e N8N_DB_SQLITE_FILE=/tmp/database.sqlite \
  -v /tmp/n8n-data:/mnt/data \
  n8n-test
```

### Check service status:
```bash
gcloud run services describe n8n-sqlite --region=us-central1
```

## Environment Variables Reference

Required for Cloud Run:
- `PORT=8080` (set by Cloud Run)
- `N8N_HOST=0.0.0.0` (must bind to all interfaces)
- `N8N_PORT=8080` (should match PORT)
- `N8N_DB_SQLITE_FILE=/mnt/data/database.sqlite`

Optional but recommended:
- `N8N_PROTOCOL=http`
- `N8N_LOG_LEVEL=info`
- `N8N_METRICS=true`
- `N8N_DISABLE_UI=false`
- `N8N_BASIC_AUTH_ACTIVE=false`

## Next Steps After Deployment

1. **Test the deployment:**
   ```bash
   gcloud builds submit --config cloudbuild.yaml
   ```

2. **Monitor the logs during deployment:**
   - Check the Cloud Build logs for build issues
   - Check Cloud Run logs for runtime issues

3. **Verify the service is running:**
   ```bash
   curl -I https://n8n-sqlite-[hash]-uc.a.run.app
   ```

4. **If issues persist:**
   - Check the logs URL provided in the error message
   - Use the healthcheck.sh script for local testing
   - Verify Cloud Storage bucket permissions
   - Consider increasing memory or timeout further

## Performance Optimization

For production use, consider:
- Increasing memory to 2Gi or more
- Adding more CPU cores
- Using Cloud SQL instead of SQLite for better performance
- Implementing proper health checks
- Setting up monitoring and alerting
