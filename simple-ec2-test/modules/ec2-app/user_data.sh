#!/bin/bash
# User data script for EC2 instance
# This script sets up a simple Python web application

# Update the system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Create application directory
mkdir -p /opt/webapp
cd /opt/webapp

# Create a simple Python web application
cat > app.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
import datetime
import os

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html_content = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>${app_name}</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }}
                    .container {{ max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
                    h1 {{ color: #333; text-align: center; }}
                    .info {{ background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }}
                    .status {{ background: #d4edda; padding: 15px; border-radius: 5px; margin: 20px 0; }}
                    .footer {{ text-align: center; margin-top: 30px; color: #666; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🚀 ${app_name}</h1>
                    <div class="status">
                        <h3>✅ Application Status: Running</h3>
                        <p><strong>Server Time:</strong> {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</p>
                        <p><strong>Instance ID:</strong> {os.environ.get('INSTANCE_ID', 'Unknown')}</p>
                        <p><strong>Region:</strong> {os.environ.get('AWS_DEFAULT_REGION', 'Unknown')}</p>
                    </div>
                    
                    <div class="info">
                        <h3>📋 Application Information</h3>
                        <ul>
                            <li>This is a simple Python web application running on AWS EC2</li>
                            <li>Instance Type: t2.micro (AWS Free Tier)</li>
                            <li>Operating System: Amazon Linux 2</li>
                            <li>Web Server: Python HTTP Server</li>
                            <li>Port: 8080</li>
                        </ul>
                    </div>
                    
                    <div class="info">
                        <h3>🔗 Available Endpoints</h3>
                        <ul>
                            <li><a href="/">/ - This page</a></li>
                            <li><a href="/health">/health - Health check endpoint</a></li>
                            <li><a href="/info">/info - System information</a></li>
                        </ul>
                    </div>
                    
                    <div class="footer">
                        <p>Deployed with Terraform | AWS Free Tier | {datetime.datetime.now().year}</p>
                    </div>
                </div>
            </body>
            </html>
            """
            self.wfile.write(html_content.encode())
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            health_data = {{
                "status": "healthy",
                "timestamp": datetime.datetime.now().isoformat(),
                "uptime": "running"
            }}
            self.wfile.write(json.dumps(health_data).encode())
            
        elif self.path == '/info':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            info_data = {{
                "application": "${app_name}",
                "version": "1.0.0",
                "python_version": "3.x",
                "server": "Python HTTP Server",
                "port": PORT,
                "timestamp": datetime.datetime.now().isoformat()
            }}
            self.wfile.write(json.dumps(info_data).encode())
        else:
            super().do_GET()

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"Server running on port {{PORT}}")
        print(f"Access the application at: http://localhost:{{PORT}}")
        httpd.serve_forever()
EOF

# Make the script executable
chmod +x app.py

# Create a systemd service for the application
cat > /etc/systemd/system/webapp.service << 'EOF'
[Unit]
Description=Simple Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/webapp
ExecStart=/usr/bin/python3 /opt/webapp/app.py
Restart=always
RestartSec=10
Environment=INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
Environment=AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

[Install]
WantedBy=multi-user.target
EOF

# Change ownership to ec2-user
chown -R ec2-user:ec2-user /opt/webapp

# Enable and start the service
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

# Install and configure CloudWatch agent (optional, for monitoring)
yum install -y amazon-cloudwatch-agent

echo "Application setup completed successfully!"