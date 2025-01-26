variable "root_password" {
  type        = string
  description = "Password for root DB user"
  default     = "coupon_pass_root"
}

variable "root_username" {
    type = string
    default = "coupon_user_root"
}

variable "coupon_username" {
    type = string
    default = "coupon_user"
}

variable "coupon_password" {
type        = string
  description = "Password for coupon DB user"
  default     = "coupon_pass"
}

variable "coupon_schema" {
    type = string
    default = "coupon"
}

variable "coupon_db" {
    type = string
    default = "eia-coupons-db"
}

variable "amway_env_type" {
  type        = string
  description = "Environment tag type according to Amway's tag specification"
  default     = "DEV"
}

variable "engine_version" {
    type = string
    default = "11.15"
}