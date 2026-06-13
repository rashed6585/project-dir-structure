# Install AWS CDK
npm install -g aws-cdk
pip install aws-cdk-lib constructs

# Initialize CDK project
mkdir my-sagemaker-cdk-project
cd my-sagemaker-cdk-project
cdk init app --language python

# Install SageMaker CDK constructs
pip install aws-cdk.aws-sagemaker-alpha

# Create SageMaker MLOps stack
cat > app.py << 'EOF'
#!/usr/bin/env python3
import aws_cdk as cdk
from constructs import Construct
from aws_cdk import (
    aws_sagemaker as sagemaker,
    aws_codepipeline as codepipeline,
    aws_codepipeline_actions as cpactions,
    aws_codebuild as codebuild,
    aws_s3 as s3,
    aws_iam as iam,
    Stack
)

class SageMakerMLOpsStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        
        # S3 bucket for artifacts
        artifact_bucket = s3.Bucket(
            self, "MLOpsArtifactBucket",
            bucket_name=f"sagemaker-mlops-{self.account}-{self.region}",
            versioned=True,
            removal_policy=cdk.RemovalPolicy.DESTROY
        )
        
        # SageMaker execution role
        sagemaker_role = iam.Role(
            self, "SageMakerExecutionRole",
            assumed_by=iam.ServicePrincipal("sagemaker.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name("AmazonSageMakerFullAccess")
            ]
        )
        
        # CodeBuild project for ML pipeline
        build_project = codebuild.Project(
            self, "MLPipelineBuild",
            source=codebuild.Source.git_hub(
                owner="your-username",
                repo="your-sagemaker-repo",
                webhook=True
            ),
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage.STANDARD_5_0,
                compute_type=codebuild.ComputeType.SMALL
            ),
            build_spec=codebuild.BuildSpec.from_source_filename("buildspec.yml")
        )
        
        # CodePipeline for CI/CD
        source_output = codepipeline.Artifact()
        build_output = codepipeline.Artifact()
        
        pipeline = codepipeline.Pipeline(
            self, "MLOpsPipeline",
            stages=[
                codepipeline.StageProps(
                    stage_name="Source",
                    actions=[
                        cpactions.GitHubSourceAction(
                            action_name="GitHub_Source",
                            owner="your-username",
                            repo="your-sagemaker-repo",
                            branch="main",
                            oauth_token=cdk.SecretValue.secrets_manager("github-token"),
                            output=source_output
                        )
                    ]
                ),
                codepipeline.StageProps(
                    stage_name="Build",
                    actions=[
                        cpactions.CodeBuildAction(
                            action_name="Build_ML_Pipeline",
                            project=build_project,
                            input=source_output,
                            outputs=[build_output]
                        )
                    ]
                )
            ]
        )

app = cdk.App()
SageMakerMLOpsStack(app, "SageMakerMLOpsStack")
app.synth()
EOF

# Deploy the CDK stack
cdk bootstrap  # One-time setup per account/region
cdk deploy

# Generate project structure after CDK deployment
mkdir -p {src,tests,notebooks,data,models}
touch src/{preprocess.py,train.py,evaluate.py,inference.py}
touch buildspec.yml requirements.txt README.md