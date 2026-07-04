@echo off
:: check-siyuan.cmd — 会话启动时检查思源笔记 MCP 是否可达
:: 输出 JSON 让 zCode 解析为 HookJSONOutput

curl -s -o NUL -w "%%{http_code}" -X POST http://127.0.0.1:36806/mcp -H "Content-Type: application/json" -H "Authorization: Bearer 0f2fa9d18b66f37127698a52633e5c95724f1bd8448878ecee3d4de793eee59f" -d "{\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"id\":1,\"params\":{\"protocolVersion\":\"2025-03-26\",\"capabilities\":{},\"clientInfo\":{\"name\":\"zcode-hook\",\"version\":\"0.1.0\"}}}" > "%TEMP%\siyuan-status.txt" 2>NUL

set /p STATUS=<"%TEMP%\siyuan-status.txt"
del "%TEMP%\siyuan-status.txt" 2>NUL

if "%STATUS%"=="200" (
    echo {"type":"success","data":{"message":"SiYuan MCP server is reachable at 127.0.0.1:36806"}}
) else (
    echo {"type":"success","data":{"message":"SiYuan MCP server is NOT reachable (HTTP %STATUS%). Make sure SiYuan is running and the Sisyphus plugin is enabled."}}
)
