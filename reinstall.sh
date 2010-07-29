#/bin/bash 

env="development"
if [ $# -gt 0 ]; then
	env=$1
fi

sudo gem uninstall eco_apps -I
gem build eco_apps.gemspec
sudo gem install --no-rdoc --no-ri eco_apps-0.1.0.gem
