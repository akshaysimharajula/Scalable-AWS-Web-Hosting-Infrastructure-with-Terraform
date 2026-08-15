
yum update -y
yum install -y httpd


systemctl enable httpd
systemctl start httpd


INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)


cat <<EOF > /var/www/html/index.html
<html>
  <head>
    <title>AWS Terraform Web Hosting</title>
  </head>
  <body>
    <h1>Deployed via Terraform</h1>
    <p>Instance ID: $INSTANCE_ID</p>
    <p>Availability Zone: $AZ</p>
    <p>Auto Scaling, ALB, CloudWatch integration</p>
    <p>Secure & Scalable Infrastructure</p>
  </body>
</html>
EOF
