#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
# echo "The page was created by the user data" | sudo tee /var/www/html/index.html
sudo cp -r index.html /path/to/local/images /path/to/local/layout /path/to/local/pages /var/www/html/