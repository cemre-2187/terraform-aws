provider "aws" {
  region     = "us-west-2"
  access_key = "#ACCESS_KEY#"
  secret_key = "#SECRET_KEY#"
}

#create a linux server
resource "aws_instance" "app_server" {
  ami           = "ami-03f65b8614a860c29"
  instance_type = "t2.micro"

  key_name = "devops"

  tags = {
    Name = "QA Server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("devops.pem")
    host        = self.public_ip # Get the public IP address from the AWS instance
  }

  provisioner "remote-exec" {
    inline = [
      "sudo curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo mkdir qa", # Create a folder for production
      "cd qa",
      "sudo git clone https://github.com/cemre-2187/devops.git",
      "cd devops",
      "sudo git checkout release",
      "sudo npm install",
      "echo 'PORT=8000' | sudo tee .env",
      "sudo npm -g install pm2",
      "pm2 link k8mvgt1ss7m5vc8 1w3o6ew7pbrw6k2",
      "pm2 install pm2-server-monit",
      "pm2 start --name qa index.js"
      #"sudo apt-get install -y nginx" # This Part is Only for educational purposes. You can use Terraform to install Nginx as well. And configure it from here.
      #"sudo apt-get install -y redis" --- This Part is Only for educational purposes. You can use Terraform to install Databses as well. This is just an example.
    ]
  }
}
