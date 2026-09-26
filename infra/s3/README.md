# S3 image storage

The production bucket is `painter-studio-images-732633980608-eu-west-3` in
`eu-west-3` (Paris). It is private, uses S3-managed encryption, has bucket
owner enforced (ACLs disabled), and blocks all public access.

`cors.json`, `lifecycle.json`, and `iam-policy.json` record the production
configuration. The IAM policy intentionally permits only `s3:GetObject` and
`s3:PutObject` for objects in this bucket. Netlify Functions receive the
credentials as `S3_ACCESS_KEY_ID` and `S3_SECRET_ACCESS_KEY`: Netlify reserves
the standard `AWS_*` variable names, so the storage function must explicitly
map them when instantiating the AWS SDK client.

Do not store access keys in this directory, in `.env.example`, or in git.
