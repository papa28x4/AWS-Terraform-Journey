HTTP works but HTTPS doesn't

this is key:  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.nic.id
    }
it made all the difference

sudo ss -tulpn | grep :443 -- to check if a port is in use

sudo a2enmod ssl #=> Enable module ssl.
sudo a2ensite default-ssl #=> Enabling site default-ssl.
sudo /etc/init.d/apache2 restart #=> restart apache
