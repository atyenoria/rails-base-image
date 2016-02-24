
if [ ! -d "/app/sample/config" ]; then
rm -f /app/sample
echo "rails install "
rails new --skip-bundle sample
cd /app/sample && bundle install --path vendor/bundle
fi

cd /app/sample && unicorn_rails -p 80

