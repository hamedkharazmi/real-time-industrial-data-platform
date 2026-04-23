# Setup Guide

This guide provides detailed instructions for setting up the sensor data pipeline from scratch.

## Prerequisites

### System Requirements
- Python 3.12 or higher
- Git
- Docker (optional, for containerized deployment)
- Terraform 1.0+
- Google Cloud SDK (optional)

### Google Cloud Setup
1. Create a new GCP project or use existing one
2. Enable billing
3. Enable required APIs:
   - BigQuery API
   - Cloud Storage API
   - Cloud Resource Manager API

### Service Account Setup
1. Create a service account with necessary permissions:
   - BigQuery Admin
   - Storage Admin
   - Service Account Token Creator

2. Download the JSON key file

3. Set environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
   ```

## Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd pipeline
```

### 2. Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -e .
```

### 4. Install Development Dependencies (Optional)
```bash
pip install -e ".[dev]"
```

## Configuration

### Environment Variables
Create a `.env` file or set environment variables:

```bash
# Google Cloud
export GCP_PROJECT_ID="your-project-id"
export GCS_BUCKET="your-bucket-name"
export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"

# Kafka
export KAFKA_BOOTSTRAP_SERVERS="localhost:9092"

# Kestra
export KESTRA_BASE_URL="http://localhost:8080"
export KESTRA_API_TOKEN="your-token"

# dbt Cloud
export DBT_CLOUD_API_KEY="your-api-key"
export DBT_CLOUD_ACCOUNT_ID="your-account-id"
export DBT_CLOUD_JOB_ID="your-job-id"
```

### Kafka Setup
For local development, start Kafka using Docker:

```bash
# Using Docker Compose (if available)
docker-compose up -d kafka

# Or using standalone Docker
docker run -d --name kafka \
  -p 9092:9092 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  confluentinc/cp-kafka:latest
```

### Kestra Setup
1. Download and run Kestra:
   ```bash
   docker run -d --name kestra \
     -p 8080:8080 \
     -v kestra-data:/app/data \
     kestra/kestra:latest
   ```

2. Access Kestra UI at http://localhost:8080

3. Set up secrets and key-value pairs in Kestra UI

### dbt Cloud Setup
1. Create dbt Cloud account
2. Connect BigQuery project
3. Create a job for the sensor pipeline
4. Note the Account ID and Job ID

## Infrastructure Deployment

### Terraform Setup
```bash
cd infrastructure

# Initialize
terraform init

# Plan deployment
terraform plan -var="credentials=./keys/terraform-key.json"

# Apply changes
terraform apply -var="credentials=./keys/terraform-key.json"
```

### Verify Infrastructure
Check that the following resources are created:
- GCS bucket: `sensor-data-lake-hamed`
- BigQuery dataset: `sensor_data`

## Pipeline Configuration

### Kestra Pipelines
1. Import pipeline files from `orchestration/kestra/pipelines/`
2. Configure the following secrets:
   - `GCP_SERVICE_ACCOUNT`: Service account JSON
   - `KAGGLE_USERNAME`: Kaggle username
   - `KAGGLE_KEY`: Kaggle API key
   - `DBT_CLOUD_API_KEY`: dbt Cloud API token

3. Set key-value pairs:
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_LOCATION`: `US`
   - `GCP_BUCKET_NAME`: Your GCS bucket name
   - `DBT_CLOUD_ACCOUNT_ID`: dbt Cloud account ID
   - `DBT_CLOUD_JOB_ID`: dbt Cloud job ID

### dbt Project Setup
1. Import the dbt project from `transformation/dbt/`
2. Configure BigQuery connection
3. Update `profiles.yml` with your project details

## Data Setup

### Download Sample Data
```bash
# Using the script
python scripts/ingest_data.py --date 2018-04-01 --download

# Or manually via Kaggle
kaggle datasets download -d nphantawee/pump-sensor-data -p data --unzip
```

### Bootstrap Pipeline
Run the bootstrap pipeline in Kestra to:
1. Download data from Kaggle
2. Upload to GCS
3. Create BigQuery tables

## Testing

### Local Testing
```bash
# Test Kafka producer
cd ingestion
python -m kafka.producer

# Test processor (in another terminal)
python -m kafka.processor

# Test BigQuery writer (in another terminal)
python -m kafka.bq_writer
```

### dbt Testing
```bash
cd transformation/dbt
dbt test
```

### Pipeline Testing
1. Trigger bootstrap pipeline manually
2. Verify data loaded to BigQuery
3. Run main pipeline
4. Check ML predictions table

## Troubleshooting

### Common Issues

#### Kafka Connection Failed
- Ensure Kafka is running on localhost:9092
- Check firewall settings
- Verify Docker network if using containers

#### GCP Authentication Error
- Verify `GOOGLE_APPLICATION_CREDENTIALS` is set
- Check service account permissions
- Ensure project ID is correct

#### BigQuery Permission Denied
- Grant BigQuery Admin role to service account
- Check dataset exists and permissions

#### Kestra Pipeline Fails
- Check secrets are properly configured
- Verify API endpoints and credentials
- Check Kestra logs

#### dbt Connection Error
- Verify BigQuery connection in dbt Cloud
- Check service account key is valid
- Ensure dataset permissions

### Logs and Debugging
- Kestra UI: Pipeline execution logs
- BigQuery: Audit logs and query history
- Kafka: Consumer group lag monitoring
- Application logs: Check stdout/stderr

## Production Deployment

### Containerization
```bash
# Build Docker image
docker build -f scripts/Dockerfile -t sensor-pipeline .

# Run container
docker run -e GOOGLE_APPLICATION_CREDENTIALS=/app/keys/key.json \
  -v $(pwd)/infrastructure/keys:/app/keys \
  sensor-pipeline
```

### Cloud Deployment
- Use Cloud Build for CI/CD pipelines
- Deploy Kestra on Cloud Run or GKE
- Use Cloud Composer for advanced orchestration
- Set up monitoring with Cloud Monitoring

### Scaling Considerations
- Increase Kafka partitions for higher throughput
- Use BigQuery clustering and partitioning
- Implement incremental dbt models
- Set up auto-scaling for ML serving