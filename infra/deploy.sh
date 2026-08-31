#!/bin/bash
# EC2 上でアプリをデプロイ／更新する。SSM Run Command から root で実行する想定。
#
#   aws ssm send-command --region us-east-1 \
#     --instance-ids <EC2_ID> --document-name AWS-RunShellScript \
#     --parameters 'commands=["curl -sSL https://raw.githubusercontent.com/takahiromorikawa/InquiryManagement/main/infra/deploy.sh | sudo bash"]'
#
set -euxo pipefail

REGION=us-east-1
PROJECT=inquiry-management
REPO=https://github.com/takahiromorikawa/InquiryManagement.git
APP_DIR=/opt/inquiry-management

# --- リポジトリ（clone / 最新化） ---
if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" fetch --depth 1 origin main
  git -C "$APP_DIR" reset --hard origin/main
else
  git clone --depth 1 "$REPO" "$APP_DIR"
fi
cd "$APP_DIR"

# --- 秘密情報を SSM Parameter Store から ---
SECRET_KEY_BASE=$(aws ssm get-parameter --region "$REGION" --name "/$PROJECT/secret_key_base" --with-decryption --query Parameter.Value --output text)
export SECRET_KEY_BASE

# --- DB 接続情報（user_data が未作成なら SSM から生成） ---
if [ ! -f /etc/inquiry-management.env ]; then
  DB_HOST=$(aws ssm get-parameter --region "$REGION" --name "/$PROJECT/db_host" --query Parameter.Value --output text)
  DB_PASS=$(aws ssm get-parameter --region "$REGION" --name "/$PROJECT/db_password" --with-decryption --query Parameter.Value --output text)
  {
    echo "DB_HOST=$DB_HOST"
    echo "DB_PORT=3306"
    echo "DB_NAME=inquiry_management_production"
    echo "DB_USERNAME=app"
    echo "DB_PASSWORD=$DB_PASS"
  } > /etc/inquiry-management.env
  chmod 600 /etc/inquiry-management.env
fi

# --- ビルド & 起動 ---
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d

# --- backend の起動待ち（entrypoint が db:prepare を実行） ---
for _ in $(seq 1 40); do
  if docker compose -f docker-compose.prod.yml exec -T backend curl -sf http://localhost:3000/up >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

# --- seed（RDS が作った DB なので db:prepare では seed されない。冪等） ---
docker compose -f docker-compose.prod.yml exec -T backend ./bin/rails db:seed

# --- 後片付け ---
docker image prune -f

docker compose -f docker-compose.prod.yml ps
echo "DEPLOY_DONE"
