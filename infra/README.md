# infra — AWS (Terraform)

動作確認・デプロイ用の AWS 最小構成。EC2（アプリ）＋ RDS（MySQL）。

```
             Internet
                │
        ┌───────┴────────┐
        │  Internet GW    │
        └───────┬────────┘
   VPC 10.20.0.0/16
        │
   ┌────┴─────────────── public subnet (10.20.1.0/24) ──────┐
   │   EC2  t3.micro  (SG: inquiry-management-ec2)           │
   │     - 自動割り当てパブリック IP                          │
   │     - SSM Session Manager / SSH                          │
   └────┬───────────────────────────────────────────────────┘
        │ 3306（EC2 SG からのみ）
   ┌────┴──── private subnets (10.20.11-12.0/24, 2 AZ) ──────┐
   │   RDS  db.t3.micro  MySQL 8.0  (SG: inquiry-management-rds)│
   │     - publicly_accessible = false                        │
   │     - インターネット経路なし（NAT Gateway 不使用）        │
   └────────────────────────────────────────────────────────┘
```

## 前提

- Terraform >= 1.6、AWS CLI v2
- AWS 認証情報が有効なこと（`aws sts get-caller-identity` が通る。SSO を使っている場合は `aws sso login`）
- SSH で入るなら公開鍵（既定 `~/.ssh/id_ed25519.pub`）。無ければ `ssh_public_key_path = ""` にして SSM Session Manager で入る

## 使い方

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集（特に allowed_ingress_cidr を自分の IP に）

terraform init
terraform plan       # 作成されるリソースを確認
terraform apply      # 作成（RDS 作成に 5〜10 分）
```

出力される主な値:

| 出力 | 用途 |
|---|---|
| `ec2_public_ip` | ブラウザ / SSH で接続 |
| `ssh_command` | SSH コマンド（キーペア作成時） |
| `rds_endpoint` / `rds_address` | EC2 内から MySQL 接続 |
| `db_password` | RDS マスターパスワード（`terraform output -raw db_password`） |

接続情報は SSM Parameter Store (`/inquiry-management/db_host`, `/inquiry-management/db_password`) にも保存され、
EC2 起動時に `/etc/inquiry-management.env` へ書き出される（DB_HOST / DB_PORT / DB_NAME / DB_USERNAME / DB_PASSWORD）。

## EC2 に入る

```bash
# SSH（キーペアを作成した場合）
$(terraform output -raw ssh_command)

# または SSM Session Manager（キーペア不要）
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

user_data で `git` / `docker` / `docker compose` を導入済み。アプリのデプロイ（リポジトリの clone、
`backend` の起動、`frontend` のビルド配信など）は手動で行う。RDS への疎通確認:

```bash
source /etc/inquiry-management.env
sudo dnf install -y mariadb105   # mysql クライアント
mysql -h "$DB_HOST" -P 3306 -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" -e 'SELECT 1;'
```

## コスト（us-east-1 / 目安）

| リソース | 無料利用枠（12ヶ月・対象アカウント） | 枠外 |
|---|---|---|
| EC2 t3.micro | 750 時間/月まで無料 | 約 $7.5/月 |
| RDS db.t3.micro (Single-AZ) | 750 時間/月まで無料 | 約 $12〜13/月 |
| RDS ストレージ 20GB gp2 | 20GB まで無料 | 約 $2.3/月 |
| EC2 EBS 12GB gp3 | 30GB まで無料 | 約 $1/月 |
| バックアップ / SSM パラメータ(標準) / データ転送(少量) | 実質無料 | 少額 |

- NAT Gateway・EIP・Multi-AZ を使わないことで固定費を抑えている
- **使わないときは `terraform destroy` で削除**すれば課金は止まる（`skip_final_snapshot = true`）

## 破棄

```bash
terraform destroy
```

## スコープ外

CI/CD、Ansible 等によるデプロイ自動化、独自ドメイン・HTTPS（ACM/Route53）、Multi-AZ、オートスケール。
