<h1>🌍🚀 Terraform-Powered AWS Cloud Infrastructure 💡🔧</h1>

<p>Hey there, Cloud Wizard! 🧙‍♂️</p>

<p>Welcome to the <strong>Ultimate AWS Infrastructure Setup</strong> using <strong>Terraform</strong> – tailored for the <strong>AWS Free Tier</strong> and DevOps dreamers like you. 🧰🌐</p>

<blockquote><strong>“Automate the cloud, rule the world!”</strong> 😎☁️</blockquote>

<hr>

<h2>✨ What’s Inside?</h2>

<p>This repo will auto-magically create the following on AWS using Infrastructure as Code 🏗️:</p>

<ul>
  <li>🖥️ <strong>Custom VPC</strong> with Public + Private Subnets</li>
  <li>🔐 <strong>Secure Security Groups</strong> and NAT Gateway</li>
  <li>💾 <strong>EC2 Instances</strong> with provisioned scripts</li>
  <li>🌐 <strong>Internet Gateway</strong> + Route Tables</li>
  <li>📦 <strong>S3 Buckets</strong> (public for static content + private)</li>
  <li>🛡️ <strong>CloudFront CDN</strong> for blazing-fast delivery</li>
  <li>🧩 <strong>IAM Roles & Policies</strong></li>
  <li>💽 <strong>RDS (MySQL)</strong> - fully Free Tier-ready!</li>
</ul>

<hr>

<h2>🗂️ Project Structure</h2>

<pre><code>.
├── main.tf             # 🌟 Main infrastructure config
├── variables.tf        # 🧮 Input variables
├── outputs.tf          # 📤 Output values
├── terraform.tfvars    # ⚙️ Custom variable values
└── README.md           # 📘 You’re reading it!
</code></pre>

<hr>

<h2>🛠️ How to Deploy Your Cloud Empire</h2>

<h3>1️⃣ Clone the Repo</h3>

<pre><code>git clone git@github.com:sharma987piyush/serverless-infra.git
cd aws-terraform-infra
</code></pre>

<h3>2️⃣ Initialize Terraform</h3>

<pre><code>terraform init
</code></pre>

<h3>3️⃣ Validate & Plan 🧪</h3>

<pre><code>terraform validate
terraform plan
</code></pre>

<h3>4️⃣ Apply the Magic! 🧙‍♂️✨</h3>

<pre><code>terraform apply
</code></pre>

<p>☑️ Type <code>yes</code> when prompted. Your AWS empire will be built!</p>

<h3>5️⃣ Destroy When Done (Cloud Cleanup) 🧹</h3>

<pre><code>terraform destroy
</code></pre>

<hr>

<h2>✅ Prerequisites</h2>

<ul>
  <li>🧰 Terraform installed</li>
  <li>🌐 AWS CLI configured (<code>aws configure</code>)</li>
  <li>🔐 IAM permissions to create AWS resources</li>
</ul>

<hr>

<h2>🌟 Features</h2>

<ul>
  <li>♻️ Modular & Reusable</li>
  <li>🔐 Production-Grade Security</li>
  <li>⚡ Speedy Deployments with CloudFront</li>
  <li>☁️ AWS Free Tier Compatible</li>
  <li>🚀 Perfect for Dev, Test, and Demo Environments</li>
</ul>

<hr>

<h2>💡 Pro Tips</h2>

<ul>
  <li>✨ Format with <code>terraform fmt</code></li>
  <li>🌱 Use workspaces for dev/staging/prod</li>
  <li>🧠 Store Terraform state remotely using S3 + DynamoDB</li>
</ul>

<hr>

<h2>🤝 Let's Collaborate!</h2>

<p>Love this setup? Found a bug? Have a killer idea? Fork it, star it ⭐, and contribute!</p>
<p>Your pull requests are always welcome 💌</p>

<hr>

<h2>📜 License</h2>

<p>This project is licensed under the <strong>MIT License</strong>. 📄</p>

<hr>

<h3>🚀 Made with 💙 for Cloud Builders Everywhere!</h3>
