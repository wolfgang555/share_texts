import Config

# 当应用运行在反向代理（如 Caddy）后面时，这些配置会被忽略
# 应用会自动从 X-Forwarded-Host 和 X-Forwarded-Proto 请求头中获取真实的主机名和协议
# 这些配置仅在没有反向代理时使用
config :share_texts, host: "localhost"
config :share_texts, port: 4000
