variable "region" {
  description = "デプロイ先の AWS リージョン"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "リソース名・タグの接頭辞"
  type        = string
  default     = "inquiry-management"
}

variable "vpc_cidr" {
  description = "VPC の CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "EC2 を置くパブリックサブネットの CIDR"
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "RDS を置くプライベートサブネットの CIDR（2 AZ 必要）"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "allowed_ingress_cidr" {
  description = "EC2 へのインバウンドを許可する CIDR。自分のグローバル IP に絞ることを推奨（例: \"203.0.113.4/32\"）"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ec2_ingress_ports" {
  description = "EC2 で開放するポート（SSH / アプリ）"
  type        = list(number)
  default     = [22, 80, 3000, 5173]
}

variable "ssh_public_key_path" {
  description = "EC2 に登録する SSH 公開鍵のパス。空にすると SSH 用キーペアを作らず SSM Session Manager のみ利用"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ec2_instance_type" {
  description = "EC2 インスタンスタイプ（無料利用枠は t3.micro もしくは t2.micro）"
  type        = string
  default     = "t3.micro"
}

variable "ec2_root_volume_gb" {
  description = "EC2 ルート EBS のサイズ(GB)"
  type        = number
  default     = 12
}

variable "db_instance_class" {
  description = "RDS インスタンスクラス（無料利用枠は db.t3.micro もしくは db.t4g.micro）"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage_gb" {
  description = "RDS のストレージ(GB)。無料利用枠は 20GB まで"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL のバージョン"
  type        = string
  default     = "8.0"
}

variable "db_name" {
  description = "作成するデータベース名"
  type        = string
  default     = "inquiry_management_production"
}

variable "db_username" {
  description = "RDS のマスターユーザー名"
  type        = string
  default     = "app"
}
