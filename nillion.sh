#!/bin/bash
show_menu() {
    echo "请选择一个操作:"
    echo "1) 安装必要依赖并安装节点"
    echo "2) 运行节点"
}

intall_docker(){
  if ! command -v docker &> /dev/null; then
          echo "未检测到 Docker，正在安装 Docker..."
          
          # 更新 apt 包索引并安装依赖
          sudo apt update && sudo apt install ca-certificates curl gnupg lsb-release -y
          
          # 添加 Docker 官方 GPG 密钥
          sudo mkdir -p /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
          
          # 设置 Docker 的 APT 源
          echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
          
          # 安装 Docker 引擎
          sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
          
          # 启动并启用 Docker 服务
          sudo systemctl start docker
          sudo systemctl enable docker
          
          echo "Docker 安装完成！"
      else
          echo "Docker 已安装，跳过安装步骤。
  }

install_nillion(){
  intall_docker
  docker pull nillion/verifier:v1.0.1
  mkdir -p nillion/verifier
  docker run -v ./nillion/verifier:/var/tmp nillion/verifier:v1.0.1 initialise
  cat nillion/accuser/credentials.json
}

run_nillion(){
  docker run -d -v ./nillion/verifier:/var/tmp nillion/verifier:v1.0.1 verify --rpc-endpoint "https://testnet-nillion-rpc.lavenderfive.com"
}


show_menu
read -p "请输入选项: " choice
case $choice in
    1)
        install_nesa
        ;;
    2)
        run_nillion
        ;;
