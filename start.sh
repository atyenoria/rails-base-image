

if [ ! -e /app/sample ]; then
echo "rails install "
cd /app && rails new sample
cd /app/sample && bundle install --path vendor/bundle
fi
ls -la
cd /app/sample && ls -la &&  unicorn_rails -p 80


