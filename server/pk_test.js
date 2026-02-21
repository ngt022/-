const WebSocket = require("ws");
const jwt = require("/opt/xiuxian/server/node_modules/jsonwebtoken");
const http = require("http");

const JWT_SECRET = "xiuxian_secret_2026";
const WS_URL = "ws://localhost:3007/ws";

// 生成token
const tokenA1 = jwt.sign({wallet: "0xbot0000000000000000000000000000000000a1"}, JWT_SECRET, {expiresIn: "24h"});
const tokenB2 = jwt.sign({wallet: "0xbot0000000000000000000000000000000000b2"}, JWT_SECRET, {expiresIn: "24h"});

let wsA1, wsB2;
let challengeId = null;
let testResults = [];
let testsCompleted = 0;

function log(msg) {
    console.log(msg);
    testResults.push(msg);
}

// 执行HTTP请求
function httpRequest(path, token, method = "GET", postData = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: "localhost",
            port: 3007,
            path: path,
            method: method,
            headers: {
                "Authorization": "Bearer " + token,
                "Content-Type": "application/json"
            }
        };
        
        const req = http.request(options, (res) => {
            let data = "";
            res.on("data", (chunk) => data += chunk);
            res.on("end", () => {
                try {
                    resolve(JSON.parse(data));
                } catch(e) {
                    resolve(data);
                }
            });
        });
        
        req.on("error", reject);
        
        if (postData) {
            req.write(JSON.stringify(postData));
        }
        req.end();
    });
}

async function runTest() {
    log("===== 修仙游戏PK系统测试 =====");
    log("时间: " + new Date().toISOString());
    log("");

    // 测试1: 检查初始状态
    log("【测试1】检查初始PK记录和统计...");
    try {
        const statsA1 = await httpRequest("/api/pk/stats", tokenA1);
        log("  A1初始统计: " + JSON.stringify(statsA1));
        
        const statsB2 = await httpRequest("/api/pk/stats", tokenB2);
        log("  B2初始统计: " + JSON.stringify(statsB2));
        log("  [✓] 统计API正常");
    } catch(e) {
        log("  [✗] 统计API错误: " + e.message);
    }
    log("");

    // 连接Bot A1
    log("【测试2】连接Bot a1并认证...");
    await new Promise((resolve, reject) => {
        wsA1 = new WebSocket(WS_URL);
        
        wsA1.on("open", () => {
            wsA1.send(JSON.stringify({type: "auth", token: tokenA1}));
        });

        wsA1.on("message", (data) => {
            const msg = JSON.parse(data);
            log("  [A1接收] " + JSON.stringify(msg).substring(0, 200));
            
            if (msg.type === "auth_success") {
                log("  [✓] A1认证成功");
                resolve();
            }
            
            if (msg.type === "pk_challenge_sent") {
                challengeId = msg.challengeId;
                log("  [✓] 挑战已发送, challengeId: " + challengeId);
            }
            
            if (msg.type === "pk_result") {
                log("  [✓] A1收到PK结果");
                log("      胜者: " + msg.winnerName);
                log("      奖励: " + msg.reward);
                testsCompleted++;
                if (testsCompleted >= 2) {
                    setTimeout(finishTest, 1000);
                }
            }

            if (msg.type === "pk_error") {
                log("  [✗] A1收到PK错误: " + msg.msg);
            }
        });

        wsA1.on("error", (err) => {
            log("  [✗] A1错误: " + err.message);
            reject(err);
        });
    });
    log("");

    // 连接Bot B2
    log("【测试3】连接Bot b2并认证...");
    await new Promise((resolve, reject) => {
        wsB2 = new WebSocket(WS_URL);
        
        wsB2.on("open", () => {
            wsB2.send(JSON.stringify({type: "auth", token: tokenB2}));
        });

        wsB2.on("message", (data) => {
            const msg = JSON.parse(data);
            log("  [B2接收] " + JSON.stringify(msg).substring(0, 200));
            
            if (msg.type === "auth_success") {
                log("  [✓] B2认证成功");
                resolve();
            }
            
            if (msg.type === "pk_challenged") {
                challengeId = msg.challengeId;
                log("  [✓] B2收到挑战, challengeId: " + challengeId);
            }
            
            if (msg.type === "pk_result") {
                log("  [✓] B2收到PK结果");
                testsCompleted++;
                if (testsCompleted >= 2) {
                    setTimeout(finishTest, 1000);
                }
            }

            if (msg.type === "pk_error") {
                log("  [✗] B2收到PK错误: " + msg.msg);
            }
        });

        wsB2.on("error", (err) => {
            log("  [✗] B2错误: " + err.message);
            reject(err);
        });
    });
    log("");

    // 测试4: 自己挑战自己 (边界情况)
    log("【测试4】测试自己挑战自己(边界情况)...");
    wsA1.send(JSON.stringify({
        type: "pk_challenge",
        targetWallet: "0xbot0000000000000000000000000000000000a1"
    }));
    await new Promise(r => setTimeout(r, 1000));
    log("");

    // 测试5: 挑战不存在的玩家
    log("【测试5】测试挑战不存在的玩家...");
    wsA1.send(JSON.stringify({
        type: "pk_challenge",
        targetWallet: "0xnonexistent00000000000000000000000000"
    }));
    await new Promise(r => setTimeout(r, 1000));
    log("");

    // 测试6: 正常挑战
    log("【测试6】Bot a1向Bot b2发起PK挑战...");
    wsA1.send(JSON.stringify({
        type: "pk_challenge",
        targetWallet: "0xbot0000000000000000000000000000000000b2"
    }));
    await new Promise(r => setTimeout(r, 1500));
    log("");

    // 测试7: 接受挑战
    log("【测试7】Bot b2接受挑战...");
    if (challengeId) {
        wsB2.send(JSON.stringify({
            type: "pk_accept",
            challengeId: challengeId
        }));
    } else {
        log("  [✗] 没有challengeId，无法接受挑战");
    }
    
    // 等待PK结果
    await new Promise(r => setTimeout(r, 3000));
    log("");

    // 如果PK没有完成，继续检查
    if (testsCompleted < 2) {
        setTimeout(finishTest, 2000);
    }
}

async function finishTest() {
    log("【测试8】检查PK后的记录...");
    try {
        const statsA1 = await httpRequest("/api/pk/stats", tokenA1);
        log("  A1最终统计: " + JSON.stringify(statsA1));
        
        const statsB2 = await httpRequest("/api/pk/stats", tokenB2);
        log("  B2最终统计: " + JSON.stringify(statsB2));
        
        const historyA1 = await httpRequest("/api/pk/history", tokenA1);
        log("  A1历史记录数: " + (historyA1.records ? historyA1.records.length : 0));
        
        if (historyA1.records && historyA1.records.length > 0) {
            const record = historyA1.records[0];
            log("  最新记录: " + JSON.stringify(record));
            
            // 检查奖励
            if (record.reward && record.reward > 0) {
                log("  [✓] 胜者获得了焰晶奖励: " + record.reward);
            }
        }
    } catch(e) {
        log("  [✗] 检查记录错误: " + e.message);
    }
    log("");

    // 测试9: 测试冷却时间
    log("【测试9】测试PK冷却时间...");
    log("  立即再次发起挑战...");
    wsA1.send(JSON.stringify({
        type: "pk_challenge",
        targetWallet: "0xbot0000000000000000000000000000000000b2"
    }));
    await new Promise(r => setTimeout(r, 1000));
    log("");

    // 测试10: 测试重复接受
    log("【测试10】测试重复接受同一挑战...");
    if (challengeId) {
        wsB2.send(JSON.stringify({
            type: "pk_accept",
            challengeId: challengeId
        }));
    }
    await new Promise(r => setTimeout(r, 1000));
    log("");

    log("===== 测试结束 =====");
    
    // 写入结果文件
    const fs = require("fs");
    fs.writeFileSync("/tmp/pk_test_results.txt", testResults.join("\n"));
    log("结果已保存到 /tmp/pk_test_results.txt");
    
    if (wsA1) wsA1.close();
    if (wsB2) wsB2.close();
    
    process.exit(0);
}

runTest().catch(err => {
    log("[✗] 测试出错: " + err.message);
    const fs = require("fs");
    fs.writeFileSync("/tmp/pk_test_results.txt", testResults.join("\n"));
    process.exit(1);
});
