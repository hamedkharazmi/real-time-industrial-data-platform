# Documentation Index

Welcome to the Sensor Data Pipeline documentation. This comprehensive guide covers all aspects of the pipeline from setup to operation.

## Quick Start

- **[README](../README.md)**: High-level project overview and quick start guide
- **[Setup Guide](setup.md)**: Detailed installation and configuration instructions

## Architecture & Design

- **[Architecture Overview](architecture.md)**: System architecture and component interactions
- **[Data Model](data_model.md)**: Database schemas and data flow documentation

## APIs & Integration

- **[ML Inference API](api.md)**: REST API for real-time predictions

## Development

- **Code Structure**: See project folders for component-specific documentation
- **Contributing**: Guidelines for code contributions
- **Testing**: Unit and integration testing procedures

## Operations

- **Monitoring**: Pipeline health and performance monitoring
- **Troubleshooting**: Common issues and solutions
- **Deployment**: Production deployment guides

## Reference

- **Configuration**: Environment variables and settings
- **Dependencies**: Python packages and versions
- **Changelog**: Version history and updates

## Support

For questions or issues:
- Check the troubleshooting section
- Review component-specific READMEs
- Open an issue in the repository

## Table of Contents

### Core Components
- [Ingestion Layer](../ingestion/): Kafka streaming components
- [Transformation Layer](../transformation/): dbt models and analytics
- [Orchestration Layer](../orchestration/): Kestra workflow management
- [Infrastructure Layer](../infrastructure/): Terraform configurations

### Utilities
- [Scripts](../scripts/): Utility scripts and tools
- [Notebooks](../notebooks/): Data exploration and analysis
- [Data](../data/): Sample datasets and schemas

### Configuration Files
- [pyproject.toml](../pyproject.toml): Python project configuration
- [Dockerfile](../scripts/Dockerfile): Container build instructions

---

*This documentation is automatically generated and kept in sync with the codebase.*