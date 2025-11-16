# Terraform Technical Challenge

## 📖 Background

Your team at **Wizard.Ai** seeks to enable other engineering teams at the organisation to provision cloud infrastructure independently, while still adhering to Wizard’s documented standards, policies and best practices.

To this end, your team maintains a centralised git repository of Terraform modules to be used by all engineering teams (including yours!). These modules will be Terraform equivalents of _L2 constructs_ as defined by the [AWS CDK Developer Guide](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html).

## 🎯 Challenge 

You have been tasked with adding an _AWS S3 Bucket_ module to this repository, the _L1 construct_ equivalent being the [s3_bucket resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) from Terraform’s AWS provider. The module will be deployed in the environments `development`, `staging` and `production`.

This module should:

- Enforce the following organisation-level policies:
 - _All data is encrypted at rest._
 - _All data is encrypted in transit._
- Enforce sensible security defaults.
- Enforce the naming convention `wizardai-<name>-<environment>`.

## 🧭 Guidelines

- This module will be used by engineers with varying degrees of skill and experience, but all with lots of work to do.
- Create the module in a directory `wizardai_aws_s3_bucket`.
- Use of AI Tooling is allowed. If used you are responsible/accountable for all code written.
- Feel free to document any of the following in `notes.md`:
 - Tooling decisions
 - Design decisions
 - Development process
 - Trade-offs
 - Wider considerations
- We know that time is precious and we don’t want this challenge to consume too much of yours - please don’t spend too long on it…🙏

## 📮 Submission

When you are totally finished, please switch to the `main` branch, create a file called `completed`, `commit` and `push`. Then let your friendly contact in Team People know that you're done.

Thank you for taking the time to complete this challenge - we look forward to reviewing it! 🙌
