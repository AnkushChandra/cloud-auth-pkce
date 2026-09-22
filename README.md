# Assignment 2 — Serverless HR Lookup

Authenticated employee lookup on AWS. The browser calls an API Gateway REST API. `GET /` returns the UI. `GET /employee/{id}` requires a Cognito ID token and reads one item from DynamoDB.

The application was built in the AWS console. The Terraform configuration in `terraform/` is imported against that live stack, and `terraform plan` reports no changes.

## Architecture

```
Browser
  |  HTTPS
  v
API Gateway REST API (stage: prod)
  |                         |
  | GET /                   | GET /employee/{id}
  v                         v
UI Lambda                   Cognito user-pool authorizer
(HTML / CSS / JS)           |
                            v
                        Backend Lambda
                            |  dynamodb:GetItem
                            v
                        DynamoDB Employees
```

Login uses a Cognito user pool with managed login (version 2), a public app client, no client secret, the authorization-code grant, and PKCE. The UI sends the ID token, not the access token.

## Repository layout

| Path | Purpose |
| --- | --- |
| `lambda/ui/index.mjs` | UI Lambda. Serves the page and performs the PKCE login in the browser. |
| `lambda/backend/lambda_function.py` | Backend Lambda. `GetItem` on `EmployeeID`. |
| `terraform/` | DynamoDB, IAM, Lambda, Cognito, and API Gateway. |

## Linked console deployment

These are the resources now managed by the local Terraform state in `ap-south-1`. Use them for the functional specification.

| Item | Value |
| --- | --- |
| API URL | `https://6w2y1dou6h.execute-api.ap-south-1.amazonaws.com/prod/` |
| Cognito client ID | `509g3mtvqd5qasl9luj67obo8` |
| Cognito user pool ID | `ap-south-1_sxYaC8kr4` |
| User pool subject (`sub`) | `d1d30d2a-00e1-70f2-8157-774594627244` |
| Managed login domain | `https://ap-south-1sxyac8kr4.auth.ap-south-1.amazoncognito.com` |
| Student record | Employee ID `1005`, Name `Ankush Chandrashekar`, Description `arn:aws:iam::279497544138:user/ankushc` |

There is no client secret.

## Terraform state

From `terraform/`:

```bash
terraform init
terraform plan
```

`plan` should print `No changes`. The state file is `terraform/terraform.tfstate`. It is gitignored. Do not commit it.

The Cognito login user is not a Terraform resource. Employee `1005` is the only DynamoDB item in the table and in state. Its Description is `arn:aws:iam::279497544138:user/ankushc`.

## What Terraform manages

- DynamoDB table `Employees`, partition key `EmployeeID` (string), on-demand billing, and the student item `1005`.
- UI Lambda (`nodejs22.x`) and backend Lambda (`python3.12`), using the console execution roles.
- Cognito user pool `User pool - abevrm`, managed-login domain `ap-south-1sxyac8kr4`, and public app client `Assingment 2 - abevrm` (no client secret). OAuth code grant, scopes `openid`, `email`, and `profile`.
- API Gateway `Assignment 2 API` (`6w2y1dou6h`), stage `prod`: unauthenticated `GET /`, Cognito-protected `GET /employee/{id}`, and mock `OPTIONS /employee/{id}`.
- The IAM roles and policies already attached in the console. The backend role includes `AmazonDynamoDBReadOnlyAccess`, `AWSLambdaDynamoDBExecutionRole`, and `AWSLambdaInvocation-DynamoDB`. No AWS credentials are in the application code.

## Testing

1. Open the API URL. The employee search page loads over HTTPS.
2. Choose **Sign in** and complete Cognito managed login. The search form appears after the code is exchanged for an ID token.
3. Search `1005`. The page shows Employee ID, Name, Salary, Date of Join, and Description.
4. That result is the student record: Name `Ankush Chandrashekar`, Description `arn:aws:iam::279497544138:user/ankushc`.
5. Search an ID that does not exist, such as `9999`. The page shows `Employee not found`.
6. Call the employee route with no token. API Gateway rejects it and returns no employee data:

```bash
curl -i "https://<api-id>.execute-api.ap-south-1.amazonaws.com/prod/employee/1001"
```

Expected result: HTTP 401 from API Gateway.

## Cleanup

`terraform destroy` deletes this live stack. The Cognito user pool has deletion protection enabled, so turn that off before a destroy can remove the pool. Confirm in the billing console that the API, Lambdas, table, user pool, and exercise IAM roles are gone.
