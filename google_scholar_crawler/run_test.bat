@echo off
echo ========================================
echo Google Scholar + GitHub 数据测试脚本
echo ========================================
echo.

cd /d %~dp0

echo 1. 检查 Python...
python --version
if errorlevel 1 (
    echo 错误: 未找到 Python，请先安装 Python 3.x
    pause
    exit /b 1
)

echo.
echo 2. 安装依赖...
pip install -r requirements.txt
if errorlevel 1 (
    echo 错误: 依赖安装失败
    pause
    exit /b 1
)

echo.
echo 3. 运行测试脚本...
python test_local.py

echo.
echo ========================================
echo 测试完成！
echo.
echo 查看 results/gs_data_test.json 文件
echo 如果数据正确，可以运行完整脚本:
echo   set GOOGLE_SCHOLAR_ID=XDljV4YAAAAJ
echo   set GITHUB_USERNAME=sunnynexus
echo   python main.py
echo ========================================
pause

