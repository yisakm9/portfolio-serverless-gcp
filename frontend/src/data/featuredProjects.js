/**
 * Featured Projects — Curated from CV
 *
 * These are your flagship projects displayed prominently above
 * the auto-fetched GitHub repos. Update this file and push to deploy.
 */

const featuredProjects = [
  {
    name: 'CloudPulse — Uptime Monitoring Platform',
    description:
      'A production-grade, serverless uptime monitoring service that continuously monitors website and API health, tracks response times, calculates uptime percentages, and sends automated alerts when services go down.',
    highlights: [
      '59-resource infrastructure across 12 Terraform modules',
      '4-stage CI/CD with Workload Identity Federation (keyless)',
      'Real-time alerting: DOWN detected → custom metric → email in 60s',
      'Defense-in-depth: private DB, Secret Manager, least-privilege IAM',
    ],
    tech: ['Cloud Run', 'Cloud SQL', 'VPC', 'Cloud NAT', 'Global LB', 'Terraform', 'Docker', 'FastAPI', 'pytest'],
    platform: 'GCP',
    github: 'https://github.com/yisakm9/CloudPulse-UptimeMonitor',
    color: 'from-cyan-400 to-blue-500',
  },
  {
    name: 'AWS Cost Calculator & Alerting System',
    description:
      'An end-to-end serverless cost monitoring platform providing real-time AWS cost visibility through a dynamic dashboard and proactive budget alerting — solving the "surprise cloud bill" problem.',
    highlights: [
      'At-a-glance weekly cost breakdowns by AWS service',
      'Automated budget alerting via CloudWatch → SNS',
      'Checkov + TFLint security scanning in CI/CD',
      '9 reusable Terraform modules for reproducibility',
    ],
    tech: ['Lambda', 'API Gateway', 'CloudFront', 'S3', 'CloudWatch', 'SNS', 'SES', 'KMS', 'Terraform'],
    platform: 'AWS',
    github: 'https://github.com/yisakm9/Project-12-Cloud-CostCalculator',
    color: 'from-orange-400 to-amber-500',
  },
  {
    name: 'Event-Driven S3 Backup System',
    description:
      'A professional-grade, automated disaster recovery system that replicates S3 objects across AWS regions, validates backup integrity via checksum comparison, and alerts operators on failures — all without human intervention.',
    highlights: [
      'Event-driven pipeline: S3 → EventBridge → SQS → Lambda',
      'Checksum validation with automatic retry for replication lag',
      'DLQ for poison-pill isolation + SNS failure alerting',
      'End-to-end KMS encryption on all resources',
    ],
    tech: ['S3', 'EventBridge', 'SQS', 'Lambda', 'SNS', 'KMS', 'DLQ', 'Terraform'],
    platform: 'AWS',
    github: 'https://github.com/yisakm9/Project-13-Automatic-Backup-System',
    color: 'from-emerald-400 to-teal-500',
  },
  {
    name: 'The Meeting Analyst — AI Transcription Pipeline',
    description:
      'An end-to-end AI pipeline that automatically transcribes meeting recordings using Amazon Transcribe and generates intelligent summaries with key decisions and action items using Generative AI (Amazon Bedrock / Meta Llama 3).',
    highlights: [
      'Audio → Transcribe → Bedrock (Llama 3) → structured summaries',
      'Extracts key decisions and action items automatically',
      'Async event-driven: SQS decouples ingestion from processing',
      'REST API for on-demand summary retrieval',
    ],
    tech: ['Transcribe', 'Bedrock', 'Lambda', 'SQS', 'EventBridge', 'DynamoDB', 'API Gateway', 'Terraform'],
    platform: 'AWS',
    github: 'https://github.com/yisakm9/The-Meeting-Analyst',
    color: 'from-violet-400 to-purple-500',
  },
];

export default featuredProjects;
