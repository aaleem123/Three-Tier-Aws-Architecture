#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
cat > /usr/share/nginx/html/index.html <<'HTML'
<h1>Web Tier</h1>
<p>Hello from the Web ASG behind the Public ALB.</p>
HTML
systemctl enable nginx
systemctl start nginx
