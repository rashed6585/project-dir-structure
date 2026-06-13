#!/bin/bash

# SageMaker MLOps Project Generator Script
# Usage: ./create-sagemaker-project.sh project-name

PROJECT_NAME=${1:-"my-sagemaker-project"}
PROJECT_DIR="$PROJECT_NAME"

echo "Creating SageMaker MLOps project: $PROJECT_NAME"

# Create main project structure
mkdir -p "$PROJECT_DIR"/{model-build,model-deploy,monitoring,infrastructure,notebooks,data,tests}

# Model Build Pipeline Structure
mkdir -p "$PROJECT_DIR/model-build"/{pipelines,src,tests}
mkdir -p "$PROJECT_DIR/model-build/pipelines"/{training,preprocessing,evaluation}

# Model Deployment Structure  
mkdir -p "$PROJECT_DIR/model-deploy"/{endpoint-config,lambda,tests}
mkdir -p "$PROJECT_DIR/model-deploy/endpoint-config"/{staging,production}

# Monitoring Structure
mkdir -p "$PROJECT_DIR/monitoring"/{data-quality,model-quality,bias-drift}

# Infrastructure as Code
mkdir -p "$PROJECT_DIR/infrastructure"/{cloudformation,terraform}

# Create essential files
cat > "$PROJECT_DIR/model-build/pipelines/pipeline.py" << 'EOF'
"""SageMaker Pipeline Definition"""
import boto3
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.steps import ProcessingStep, TrainingStep
from sagemaker.workflow.step_collections import RegisterModel

def create_pipeline(
    region,
    sagemaker_project_arn=None,
    role=None,
    default_bucket=None,
    model_package_group_name=None,
    pipeline_name=None,
    base_job_prefix=None,
):
    """Create SageMaker ML Pipeline"""
    
    # Define your pipeline steps here
    # preprocessing_step = ProcessingStep(...)
    # training_step = TrainingStep(...)
    # evaluation_step = ProcessingStep(...)
    # register_step = RegisterModel(...)
    
    pipeline = Pipeline(
        name=pipeline_name,
        parameters=[],  # Add your parameters
        steps=[],       # Add your steps
        sagemaker_session=sagemaker_session,
    )
    
    return pipeline

if __name__ == "__main__":
    pipeline = create_pipeline(
        region="us-east-1",
        pipeline_name="MyMLOpsPipeline"
    )
    pipeline.create(role_arn="your-sagemaker-role")
    execution = pipeline.start()
EOF

cat > "$PROJECT_DIR/model-build/src/preprocess.py" << 'EOF'
"""Data preprocessing script for SageMaker"""
import argparse
import os
import pandas as pd
from sklearn.model_selection import train_test_split

def preprocess_data(input_path, output_path):
    """Preprocess raw data for training"""
    # Load data
    data = pd.read_csv(os.path.join(input_path, "data.csv"))
    
    # Preprocessing logic here
    # feature_engineering(data)
    
    # Split data
    train, test = train_test_split(data, test_size=0.2, random_state=42)
    train, val = train_test_split(train, test_size=0.2, random_state=42)
    
    # Save processed data
    train.to_csv(os.path.join(output_path, "train.csv"), index=False)
    val.to_csv(os.path.join(output_path, "validation.csv"), index=False)  
    test.to_csv(os.path.join(output_path, "test.csv"), index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-data", type=str, default="/opt/ml/processing/input")
    parser.add_argument("--output-data", type=str, default="/opt/ml/processing/output")
    args = parser.parse_args()
    
    preprocess_data(args.input_data, args.output_data)
EOF

cat > "$PROJECT_DIR/model-build/src/train.py" << 'EOF'
"""Model training script for SageMaker"""
import argparse
import joblib
import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

def train_model(train_path, model_path):
    """Train machine learning model"""
    # Load training data
    train_data = pd.read_csv(os.path.join(train_path, "train.csv"))
    val_data = pd.read_csv(os.path.join(train_path, "validation.csv"))
    
    # Prepare features and target
    X_train = train_data.drop("target", axis=1)
    y_train = train_data["target"]
    X_val = val_data.drop("target", axis=1)  
    y_val = val_data["target"]
    
    # Train model
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Validate model
    val_pred = model.predict(X_val)
    accuracy = accuracy_score(y_val, val_pred)
    print(f"Validation Accuracy: {accuracy}")
    
    # Save model
    joblib.dump(model, os.path.join(model_path, "model.joblib"))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-dir", type=str, default=os.environ.get("SM_MODEL_DIR"))
    parser.add_argument("--train", type=str, default=os.environ.get("SM_CHANNEL_TRAIN"))
    args = parser.parse_args()
    
    train_model(args.train, args.model_dir)
EOF

cat > "$PROJECT_DIR/model-deploy/endpoint-config/staging/endpoint-config-template.yml" << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'SageMaker Endpoint for Staging Environment'

Parameters:
  ModelName:
    Type: String
    Description: Name of the SageMaker model
  EndpointConfigName:
    Type: String
    Description: Name of the endpoint configuration
  EndpointName:
    Type: String
    Description: Name of the endpoint

Resources:
  EndpointConfig:
    Type: AWS::SageMaker::EndpointConfig
    Properties:
      EndpointConfigName: !Ref EndpointConfigName
      ProductionVariants:
        - ModelName: !Ref ModelName
          VariantName: primary
          InitialInstanceCount: 1
          InstanceType: ml.t2.medium
          InitialVariantWeight: 1

  Endpoint:
    Type: AWS::SageMaker::Endpoint
    Properties:
      EndpointName: !Ref EndpointName
      EndpointConfigName: !GetAtt EndpointConfig.EndpointConfigName

Outputs:
  EndpointName:
    Description: Name of the created endpoint
    Value: !Ref Endpoint
    Export:
      Name: !Sub '${AWS::StackName}-EndpointName'
EOF

cat > "$PROJECT_DIR/buildspec.yml" << 'EOF'
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.8
    commands:
      - pip install --upgrade pip
      - pip install sagemaker boto3 pandas scikit-learn

  build:
    commands:
      - echo "Building SageMaker pipeline"
      - cd model-build
      - python pipelines/pipeline.py
      - echo "Pipeline created successfully"

  post_build:
    commands:
      - echo "Build completed on `date`"

artifacts:
  files:
    - '**/*'
EOF

cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

This is a SageMaker MLOps project generated automatically.

## Project Structure

- \`model-build/\` - ML pipeline and training code
- \`model-deploy/\` - Deployment configurations  
- \`monitoring/\` - Model monitoring setup
- \`infrastructure/\` - CloudFormation/Terraform templates
- \`notebooks/\` - Jupyter notebooks for exploration
- \`tests/\` - Unit and integration tests

## Getting Started

1. Configure AWS credentials:
   \`\`\`bash
   aws configure
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

3. Run the ML pipeline:
   \`\`\`bash
   cd model-build
   python pipelines/pipeline.py
   \`\`\`

## Deployment

Deploy to staging:
\`\`\`bash
aws cloudformation deploy \\
    --template-file model-deploy/endpoint-config/staging/endpoint-config-template.yml \\
    --stack-name $PROJECT_NAME-staging \\
    --parameter-overrides ModelName=my-model EndpointName=my-endpoint-staging
\`\`\`
EOF

cat > "$PROJECT_DIR/requirements.txt" << 'EOF'
sagemaker>=2.100.0
boto3>=1.24.0
pandas>=1.4.0
scikit-learn>=1.1.0
numpy>=1.21.0
matplotlib>=3.5.0
seaborn>=0.11.0
joblib>=1.1.0
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
EOF

echo "✅ SageMaker MLOps project '$PROJECT_NAME' created successfully!"
echo "📁 Project directory: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. pip install -r requirements.txt"
echo "3. Configure your AWS credentials"
echo "4. Customize the pipeline code in model-build/"
echo "5. Deploy using AWS CodePipeline or manual deployment"