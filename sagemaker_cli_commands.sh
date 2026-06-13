# Install AWS CLI and SageMaker extensions
pip install awscli sagemaker boto3

# Configure AWS credentials
aws configure

# Create SageMaker project using CLI
aws sagemaker create-project \
    --project-name "my-mlops-project" \
    --project-description "MLOps project for model training and deployment" \
    --service-catalog-provisioning-details '{
        "ProductId": "prod-xxxxxxxxx",
        "ProvisioningArtifactId": "pa-xxxxxxxxx",
        "ProvisioningParameters": [
            {
                "Key": "SeedCodeCheckinRepository",
                "Value": "https://github.com/yourusername/your-repo.git"
            },
            {
                "Key": "ModelDeploymentBranch", 
                "Value": "main"
            }
        ]
    }'

# List available project templates
aws sagemaker list-project-templates

# Describe specific template details
aws sagemaker describe-project-template \
    --template-name "MLOps template for model building training and deployment"

# Clone the generated repositories locally
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/my-mlops-project-modelbuild
git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/my-mlops-project-modeldeploy

# Alternative: Use SageMaker Python SDK
python -c "
import sagemaker
from sagemaker.projects import Project

# Create project programmatically
project = Project.create(
    project_name='my-python-mlops-project',
    project_description='Created via Python SDK',
    project_template_name='MLOps template for model building training and deployment with third party git using CodePipeline'
)
print(f'Project ARN: {project.arn}')
"