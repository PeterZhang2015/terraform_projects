#!/bin/bash
# Update system packages
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Create application directory
mkdir -p /opt/simple-app
cd /opt/simple-app

# Create a simple Python web application
cat > app.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import json
import os
import socket
from datetime import datetime

class SimpleHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            
            html_content = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>Simple EC2 Application</title>
                <style>
                    body {{
                        font-family: Arial, sans-serif;
                        margin: 40px;
                        background-color: #f5f5f5;
                    }}
                    .container {{
                        max-width: 800px;
                        margin: 0 auto;
                        background-color: white;
                        padding: 30px;
                        border-radius: 10px;
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    }}
                    h1 {{
                        color: #333;
                        text-align: center;
                    }}
                    .info {{
                        background-color: #e8f4f8;
                        padding: 20px;
                        border-radius: 5px;
                        margin: 20px 0;
                    }}
                    .success {{
                        color: #2e7d32;
                        font-weight: bold;
                    }}
                    .endpoint {{
                        background-color: #f8f9fa;
                        padding: 15px;
                        border-left: 4px solid #007bff;
                        margin: 10px 0;
                    }}
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🚀 Simple EC2 Application</h1>
                    <div class="info">
                        <p class="success">✅ Application is running successfully!</p>
                        <p><strong>Server:</strong> {hostname}</p>
                        <p><strong>Local IP:</strong> {local_ip}</p>
                        <p><strong>Timestamp:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</p>
                        <p><strong>Port:</strong> ${app_port}</p>
                    </div>
                    
                    <h2>Available Endpoints:</h2>
                    <div class="endpoint">
                        <strong>GET /</strong> - This page
                    </div>
                    <div class="endpoint">
                        <strong>GET /health</strong> - Health check endpoint
                    </div>
                    <div class="endpoint">
                        <strong>GET /info</strong> - System information (JSON)
                    </div>
                    
                    <h2>Deployment Info:</h2>
                    <div class="info">
                        <p>This EC2 instance was deployed using Terraform with:</p>
                        <ul>
                            <li>terraform-aws-modules/vpc/aws</li>
                            <li>terraform-aws-modules/security-group/aws</li>
                            <li>terraform-aws-modules/ec2-instance/aws</li>
                        </ul>
                        <p>Remote state is stored in S3 with file locking.</p>
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
            
            response = {
                "status": "healthy",
                "timestamp": datetime.now().isoformat(),
                "service": "simple-ec2-app"
            }
            
            self.wfile.write(json.dumps(response).encode())
            
        elif self.path == '/info':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            
            response = {
                "hostname": hostname,
                "local_ip": local_ip,
                "timestamp": datetime.now().isoformat(),
                "port": ${app_port},
                "python_version": os.sys.version,
                "environment_variables": dict(os.environ)
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html><body><h1>404 Not Found</h1></body></html>')

# Start the server
PORT = ${app_port}
with socketserver.TCPServer(("", PORT), SimpleHTTPRequestHandler) as httpd:
    print(f"Server running on port {PORT}")
    httpd.serve_forever()
EOF

# Make the script executable
chmod +x app.py

# Create systemd service file
cat > /etc/systemd/system/simple-app.service << 'EOF'
[Unit]
Description=Simple Python Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/simple-app
ExecStart=/usr/bin/python3 /opt/simple-app/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set ownership
chown -R ec2-user:ec2-user /opt/simple-app

# Enable and start the service
systemctl daemon-reload
systemctl enable simple-app
systemctl start simple-app

# Create a simple health check script
cat > /opt/simple-app/health-check.sh << 'EOF'
#!/bin/bash
curl -f http://localhost:${app_port}/health > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Application is healthy"
    exit 0
else
    echo "Application is not responding"
    exit 1
fi
EOF

chmod +x /opt/simple-app/health-check.sh

# Log the completion
echo "Simple application setup completed at $(date)" >> /var/log/user-data.log
