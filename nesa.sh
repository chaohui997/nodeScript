#!/bin/bash

show_menu() {
    echo "请选择一个操作:"
    echo "1) 安装必要依赖并安装 Nesa 矿工节点"
    echo "2) 卸载 Nesa 矿工节点"
    echo "3) 查看 Nesa 矿工节点日志"
    echo "4) 查看 Nesa 节点 ID"
    echo "5) 退出"
}

# 安装必要依赖并安装 Nesa 矿工节点的函数
install_nesa() {
    echo "正在安装必要的依赖..."

    # 更新系统并安装 curl, jq 和 pip3
    sudo apt update && sudo apt install curl jq python3-pip -y
    
    # 检查 Docker 是否已经安装
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
        echo "Docker 已安装，跳过安装步骤。"
    fi
    
    # 检查是否已安装 Python3
    if ! command -v python3 &> /dev/null; then
        echo "未检测到 Python3，正在安装..."
        sudo apt install python3 -y
    fi
    
    # 检查并安装 ecdsa 模块
    echo "检查并安装 ecdsa 模块..."
    if ! python3 -c "import ecdsa" &> /dev/null; then
        echo "未安装 ecdsa，正在安装..."
        pip3 install ecdsa
        echo "ecdsa 模块安装完成！"
    else
        echo "ecdsa 模块已安装，跳过安装步骤。"
    fi

    # 安装 Nesa 矿工节点
    echo "正在安装 Nesa 矿工节点..."
    bash <(curl -s https://raw.githubusercontent.com/nesaorg/bootstrap/master/bootstrap.sh)
    echo "Nesa 矿工节点安装完成！"

    # 提示用户操作完成并返回菜单
    read -p "按回车键返回菜单..."
}

# 卸载 Nesa 矿工节点的函数
uninstall_nesa() {
    echo "正在卸载 Nesa 矿工节点..."
    
    # 在这里添加卸载命令，如停止服务，删除文件等
    # 示例: sudo systemctl stop nesa-miner
    #       sudo rm -rf /path/to/nesa/miner

    echo "Nesa 矿工节点卸载完成！"
    
    # 提示用户操作完成并返回菜单
    read -p "按回车键返回菜单..."
}

# 查看 Nesa 矿工节点日志的函数
view_logs() {
    echo "正在显示 Nesa 矿工节点日志..."
    
    # 假设日志文件路径为 /var/log/nesa-miner.log
    if [ -f /var/log/nesa-miner.log ]; then
        tail -f /var/log/nesa-miner.log
    else
        echo "未找到日志文件，确认 Nesa 矿工节点是否正确安装并运行。"
    fi
    
    # 提示用户按 Ctrl + C 退出日志查看模式
    echo "按 Ctrl + C 退出日志查看。"
    
    # 提示用户操作完成并返回菜单
    read -p "按回车键返回菜单..."
}

# 查看 Nesa 节点 ID 的函数
view_node_id() {
    if [ -f ~/.nesa/identity/node_id.id ]; then
        echo "Nesa 节点 ID 为:"
        cat ~/.nesa/identity/node_id.id
    else
        echo "未找到节点 ID 文件，确认 Nesa 矿工节点是否正确安装。"
    fi
    
    # 提示用户操作完成并返回菜单
    read -p "按回车键返回菜单..."
}

# 主循环，显示菜单并根据用户输入执行操作
while true; do
    show_menu
    read -p "请输入选项: " choice
    case $choice in
        1)
            install_nesa
            ;;
        2)
            uninstall_nesa
            ;;
        3)
            view_logs
            ;;
        4)
            view_node_id
            ;;
        5)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新选择。"
            ;;
    esac
done
