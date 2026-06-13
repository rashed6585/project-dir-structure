# Install cookiecutter
pip install cookiecutter

# 1. Official AWS SageMaker MLOps template
cookiecutter https://github.com/aws-samples/sagemaker-mlops-project-template

# 2. Community SageMaker template with best practices
cookiecutter https://github.com/drivendata/cookiecutter-data-science-sagemaker

# 3. Advanced SageMaker template with monitoring
cookiecutter https://github.com/aws-samples/amazon-sagemaker-mlops-template

# 4. Custom template creation
cookiecutter gh:aws-samples/sagemaker-custom-project-templates

# Interactive prompts will ask for:
# - project_name: my-sagemaker-project
# - project_description: My ML project description  
# - author_name: Your Name
# - python_version: 3.8
# - sagemaker_region: us-east-1
# - include_monitoring: yes
# - include_batch_transform: yes
# - model_type: classification

# Example cookiecutter.json configuration
cat > cookiecutter.json << EOF
{
    "project_name": "{{ cookiecutter.project_name }}",
    "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '_').replace('-', '_') }}",
    "author_name": "{{ cookiecutter.author_name }}",
    "author_email": "{{ cookiecutter.author_email }}",
    "project_description": "{{ cookiecutter.project_description }}",
    "project_version": "0.1.0",
    "python_version": ["3.8", "3.9", "3.10"],
    "aws_region": "us-east-1",
    "sagemaker_execution_role": "{{ cookiecutter.sagemaker_execution_role }}",
    "include_model_monitoring": ["yes", "no"],
    "include_batch_transform": ["yes", "no"],
    "model_framework": ["sklearn", "xgboost", "tensorflow", "pytorch"],
    "deployment_type": ["real-time", "batch", "both"]
}
EOF