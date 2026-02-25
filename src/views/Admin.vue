<template>
  <div class="admin-page" v-if="!accessDenied">
    <div class="admin-header">
      <h1 class="admin-title">⚙ 焰修后台管理</h1>
      <div class="tab-bar">
        <button v-for="tab in tabs" :key="tab.key" :class="['tab-btn', { active: activeTab === tab.key }]" @click="activeTab = tab.key">{{ tab.label }}</button>
      </div>
    </div>
    <div class="admin-body">
      <!-- 仪表盘 -->
      <div v-if="activeTab === 'dashboard'" class="tab-content">
        <div class="stat-cards">
          <div class="stat-card" v-for="s in dashboardStats" :key="s.label">
            <div class="stat-value">{{ s.value }}</div>
            <div class="stat-label">{{ s.label }}</div>
          </div>
        </div>
        <div class="chart-section">
          <h3 class="section-title">VIP 分布</h3>
          <div class="pie-chart-container">
            <div class="pie-chart" :style="pieStyle"></div>
            <div class="pie-legend">
              <div v-for="(v, i) in vipDistribution" :key="i" class="legend-item">
                <span class="legend-color" :style="{ background: pieColors[i % pieColors.length] }"></span>
                <span>VIP{{ v.level }}: {{ v.count }}人 ({{ v.percent }}%)</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- 玩家管理 -->
      <div v-if="activeTab === 'players'" class="tab-content">
        <div class="toolbar">
          <input v-model="playerSearch" class="search-input" placeholder="搜索 wallet / 名称..." @keyup.enter="loadPlayers(1)" />
          <button class="gold-btn" @click="loadPlayers(1)">搜索</button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr>
              <th>Wallet</th><th>名称</th><th>等级</th><th>境界</th><th>VIP</th><th>焰晶</th><th>战力</th><th>注册时间</th><th>操作</th>
            </tr></thead>
            <tbody>
              <tr v-for="p in players" :key="p.wallet">
                <td class="mono">{{ shortAddr(p.wallet) }}</td>
                <td>{{ p.name }}</td><td>{{ p.level }}</td><td>{{ p.realm }}</td>
                <td>{{ p.vip_level }}</td><td>{{ formatNum(p.spirit_stones) }}</td>
                <td>{{ formatNum(p.combat_power) }}</td><td>{{ fmtDate(p.created_at) }}</td>
                <td class="actions">
                  <button class="sm-btn" @click="viewPlayer(p)">详情</button>
                  <button class="sm-btn" :class="p.banned ? 'green' : 'red'" @click="toggleBan(p)">{{ p.banned ? '解封' : '封禁' }}</button>
                  <button class="sm-btn" @click="openAdjustStones(p)">调整焰晶</button>
                  <button class="sm-btn" @click="openPlayerEdit(p)">编辑</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="pagination">
          <button class="page-btn" :disabled="playerPage <= 1" @click="loadPlayers(playerPage - 1)">上一页</button>
          <span class="page-info">第 {{ playerPage }} / {{ playerTotalPages }} 页</span>
          <button class="page-btn" :disabled="playerPage >= playerTotalPages" @click="loadPlayers(playerPage + 1)">下一页</button>
        </div>
      </div>
      <!-- 充值记录 -->
      <div v-if="activeTab === 'recharges'" class="tab-content">
        <div class="toolbar">
          <input v-model="rechargeWallet" class="search-input" placeholder="Wallet 搜索..." @keyup.enter="loadRecharges(1)" />
          <input v-model="rechargeDateFrom" type="date" class="date-input" />
          <input v-model="rechargeDateTo" type="date" class="date-input" />
          <button class="gold-btn" @click="loadRecharges(1)">筛选</button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr>
              <th>Wallet</th><th>TX Hash</th><th>金额(ROON)</th><th>焰晶</th><th>赠送</th><th>时间</th>
            </tr></thead>
            <tbody>
              <tr v-for="r in recharges" :key="r.id">
                <td class="mono">{{ shortAddr(r.wallet) }}</td>
                <td class="mono">{{ shortAddr(r.tx_hash) }}</td>
                <td>{{ r.amount }}</td><td>{{ r.spirit_stones }}</td>
                <td>{{ r.bonus_stones }}</td><td>{{ fmtDate(r.created_at) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="pagination">
          <button class="page-btn" :disabled="rechargePage <= 1" @click="loadRecharges(rechargePage - 1)">上一页</button>
          <span class="page-info">第 {{ rechargePage }} / {{ rechargeTotalPages }} 页</span>
          <button class="page-btn" :disabled="rechargePage >= rechargeTotalPages" @click="loadRecharges(rechargePage + 1)">下一页</button>
        </div>
      </div>
      <!-- 公告管理 -->
      <div v-if="activeTab === 'announcements'" class="tab-content">
        <div class="toolbar">
          <button class="gold-btn" @click="openAnnouncementForm()">+ 新建公告</button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>标题</th><th>内容</th><th>创建时间</th><th>操作</th></tr></thead>
            <tbody>
              <tr v-for="a in announcements" :key="a.id">
                <td>{{ a.title }}</td><td class="content-cell">{{ a.content }}</td>
                <td>{{ fmtDate(a.created_at) }}</td>
                <td class="actions">
                  <button class="sm-btn" @click="openAnnouncementForm(a)">编辑</button>
                  <button class="sm-btn red" @click="deleteAnnouncement(a.id)">删除</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- 焰盟管理 -->
      <div v-if="activeTab === 'sects'" class="tab-content">
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>焰盟名</th><th>盟主</th><th>等级</th><th>成员数</th><th>创建时间</th><th>操作</th></tr></thead>
            <tbody>
              <tr v-for="s in sects" :key="s.id">
                <td>{{ s.name }}</td><td class="mono">{{ shortAddr(s.leader_wallet) }}</td>
                <td>{{ s.level }}</td><td>{{ s.member_count }}</td>
                <td>{{ fmtDate(s.created_at) }}</td>
                <td class="actions"><button class="sm-btn red" @click="dissolveSect(s)">解散</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- 活动管理 -->
      <div v-if="activeTab === 'events'" class="tab-content">
        <div class="toolbar">
          <button class="gold-btn" @click="openEventForm()">+ 新建活动</button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>名称</th><th>类型</th><th>开始</th><th>结束</th><th>状态</th><th>操作</th></tr></thead>
            <tbody>
              <tr v-for="e in events" :key="e.id">
                <td>{{ e.name }}</td><td>{{ e.type }}</td>
                <td>{{ fmtDate(e.start_time) }}</td><td>{{ fmtDate(e.end_time) }}</td>
                <td><span :class="['status-badge', e.active ? 'active' : 'inactive']">{{ e.active ? '进行中' : '已结束' }}</span></td>
                <td class="actions">
                  <button class="sm-btn" @click="openEventForm(e)">编辑</button>
                  <button class="sm-btn red" @click="deleteEvent(e.id)">删除</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- Boss管理 -->
      <div v-if="activeTab === 'boss'" class="tab-content">
        <div class="toolbar">
          <button class="gold-btn" @click="spawnBoss()">🐉 生成新Boss</button>
        </div>
        <div v-if="currentBoss" class="boss-current">
          <h3 class="section-title">当前Boss</h3>
          <div class="stat-cards">
            <div class="stat-card"><div class="stat-value">{{ currentBoss.name }}</div><div class="stat-label">名称</div></div>
            <div class="stat-card"><div class="stat-value">{{ currentBoss.level }}</div><div class="stat-label">等级</div></div>
            <div class="stat-card"><div class="stat-value">{{ formatNum(currentBoss.hp) }} / {{ formatNum(currentBoss.max_hp) }}</div><div class="stat-label">血量</div></div>
            <div class="stat-card"><div class="stat-value">{{ currentBoss.status }}</div><div class="stat-label">状态</div></div>
          </div>
        </div>
        <h3 class="section-title">历史Boss</h3>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>名称</th><th>等级</th><th>状态</th><th>击杀者</th><th>生成时间</th></tr></thead>
            <tbody>
              <tr v-for="b in bossList" :key="b.id">
                <td>{{ b.name }}</td><td>{{ b.level }}</td>
                <td><span :class="['status-badge', b.status === 'dead' ? 'inactive' : 'active']">{{ b.status }}</span></td>
                <td class="mono">{{ b.killer ? shortAddr(b.killer) : '-' }}</td>
                <td>{{ fmtDate(b.created_at) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- 系统设置 -->
      <!-- 邮件管理 -->
      <div v-if="activeTab === 'mail'" class="tab-content">
        <div class="toolbar">
          <input v-model="mailTitle" class="search-input" placeholder="邮件标题" style="flex:1" />
          <select v-model="mailTarget" class="search-input" style="width:120px">
            <option value="all">全服发送</option>
            <option value="custom">指定玩家</option>
          </select>
        </div>
        <input v-if="mailTarget==='custom'" v-model="mailTargetWallet" class="search-input" placeholder="目标钱包地址" style="width:100%;margin:8px 0" />
        <textarea v-model="mailContent" class="search-input" placeholder="邮件内容" rows="3" style="width:100%;margin:8px 0;resize:vertical"></textarea>
        <div class="toolbar" style="gap:8px">
          <input v-model.number="mailRewardStones" class="search-input" placeholder="焰晶奖励" type="number" style="width:100px" />
          <input v-model.number="mailRewardReinforce" class="search-input" placeholder="淬火石" type="number" style="width:100px" />
          <input v-model.number="mailRewardEssence" class="search-input" placeholder="精华" type="number" style="width:100px" />
          <button class="gold-btn" @click="sendMail" :disabled="!mailTitle||!mailContent">发送邮件</button>
        </div>
        <div v-if="mailResult" class="stat-card" style="margin-top:12px">{{ mailResult }}</div>
      </div>
            <!-- 经济总览 -->
      <div v-if="activeTab === 'economy'" class="tab-content">
        <div class="stat-cards">
          <div class="stat-card"><div class="stat-value">{{ formatNum(economyData.totalStones) }}</div><div class="stat-label">全服焰晶总量</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatNum(economyData.avgStones) }}</div><div class="stat-label">人均焰晶</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatNum(economyData.totalPlayers) }}</div><div class="stat-label">玩家总数</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatNum(economyData.medianStones) }}</div><div class="stat-label">中位数焰晶</div></div>
        </div>
        <h3 class="section-title">💰 焰晶 Top 10</h3>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>#</th><th>Wallet</th><th>名称</th><th>等级</th><th>VIP</th><th>焰晶</th></tr></thead>
            <tbody>
              <tr v-for="(p, i) in economyData.richest" :key="p.wallet">
                <td>{{ i + 1 }}</td><td class="mono">{{ shortAddr(p.wallet) }}</td><td>{{ p.name }}</td>
                <td>{{ p.level }}</td><td>VIP{{ p.vip_level }}</td><td class="gold">{{ formatNum(p.spirit_stones) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 排行榜 -->
      <div v-if="activeTab === 'leaderboard'" class="tab-content">
        <div class="toolbar">
          <button v-for="t in ['power','level','recharge']" :key="t" :class="['sm-btn', { active: lbType === t }]" @click="lbType = t; loadLeaderboard()">
            {{ {power:'战力',level:'等级',recharge:'充值'}[t] }}
          </button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>#</th><th>Wallet</th><th>名称</th><th>等级</th><th>VIP</th><th>{{ {power:'战力',level:'等级',recharge:'充值额'}[lbType] }}</th></tr></thead>
            <tbody>
              <tr v-for="(p, i) in leaderboardData" :key="p.wallet">
                <td>{{ i + 1 }}</td><td class="mono">{{ shortAddr(p.wallet) }}</td><td>{{ p.name }}</td>
                <td>{{ p.level }}</td><td>VIP{{ p.vip_level }}</td>
                <td class="gold">{{ formatNum(lbType === 'power' ? p.combat_power : lbType === 'recharge' ? p.total_recharge : p.level) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 拍卖监控 -->
      <div v-if="activeTab === 'auction'" class="tab-content">
        <div class="toolbar">
          <button :class="['sm-btn', { active: auctionView === 'active' }]" @click="auctionView = 'active'; loadAuction()">当前拍品</button>
          <button :class="['sm-btn', { active: auctionView === 'history' }]" @click="auctionView = 'history'; loadAuction()">成交历史</button>
        </div>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>ID</th><th>物品</th><th>卖家</th><th>起拍价</th><th>当前价</th><th>一口价</th><th>状态</th><th v-if="auctionView==='active'">操作</th></tr></thead>
            <tbody>
              <tr v-for="a in auctionList" :key="a.id">
                <td>{{ a.id }}</td><td>{{ a.item_name || '装备' }}</td><td class="mono">{{ shortAddr(a.seller_wallet || a.seller) }}</td>
                <td>{{ formatNum(a.start_price) }}</td><td>{{ formatNum(a.current_price || a.final_price || '-') }}</td>
                <td>{{ formatNum(a.buyout_price || '-') }}</td><td>{{ a.status || (auctionView === 'active' ? '进行中' : '已成交') }}</td>
                <td v-if="auctionView==='active'"><button class="sm-btn red" @click="forceRemoveAuction(a.id)">强制下架</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 在线监控 -->
      <div v-if="activeTab === 'online'" class="tab-content">
        <div class="stat-cards">
          <div class="stat-card"><div class="stat-value">{{ onlineData.onlineCount || 0 }}</div><div class="stat-label">当前在线</div></div>
          <div class="stat-card"><div class="stat-value">{{ onlineData.activeCount || 0 }}</div><div class="stat-label">1小时活跃</div></div>
        </div>
        <h3 class="section-title">🟢 最近活跃玩家</h3>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>Wallet</th><th>名称</th><th>等级</th><th>VIP</th><th>最后活跃</th></tr></thead>
            <tbody>
              <tr v-for="p in onlineData.activePlayers" :key="p.wallet">
                <td class="mono">{{ shortAddr(p.wallet) }}</td><td>{{ p.name }}</td>
                <td>{{ p.level }}</td><td>VIP{{ p.vip_level }}</td><td>{{ fmtDate(p.updated_at) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- 批量空投 -->
      <div v-if="activeTab === 'airdrop'" class="tab-content">
        <h3 class="section-title">🎁 全服空投</h3>
        <p style="color:#a09880;margin-bottom:16px">向所有玩家发放资源，通过邮件附件形式发送</p>
        <div class="settings-grid">
          <label>焰晶<input type="number" v-model.number="airdropData.spiritStones" class="setting-input" min="0" /></label>
          <label>淬火石<input type="number" v-model.number="airdropData.reinforceStones" class="setting-input" min="0" /></label>
          <label>精炼石<input type="number" v-model.number="airdropData.refinementStones" class="setting-input" min="0" /></label>
          <label>焰兽精华<input type="number" v-model.number="airdropData.petEssence" class="setting-input" min="0" /></label>
        </div>
        <div style="margin-top:12px">
          <label>邮件标题<input v-model="airdropData.title" class="modal-input" placeholder="全服福利" /></label>
          <label style="margin-top:8px;display:block">邮件内容<textarea v-model="airdropData.content" class="modal-textarea" rows="3" placeholder="亲爱的焰修，感谢您的支持..."></textarea></label>
        </div>
        <button class="gold-btn save-btn" @click="sendAirdrop()" style="margin-top:16px">🚀 发送空投</button>
        <div v-if="airdropResult" style="margin-top:12px;color:#4caf50">{{ airdropResult }}</div>
      </div>

      <!-- 商城配置 -->
      <div v-if="activeTab === 'shopconfig'" class="tab-content">
        <h3 class="section-title">🛒 材料价格配置</h3>
        <div class="settings-grid">
          <label>淬火石(单个)<input type="number" v-model.number="shopConfig.reinforce_stone" class="setting-input" /></label>
          <label>淬火石(10连)<input type="number" v-model.number="shopConfig.reinforce_stone_10" class="setting-input" /></label>
          <label>精炼石(单个)<input type="number" v-model.number="shopConfig.refine_stone" class="setting-input" /></label>
          <label>精炼石(10连)<input type="number" v-model.number="shopConfig.refine_stone_10" class="setting-input" /></label>
        </div>
        <h3 class="section-title" style="margin-top:20px">Buff 价格</h3>
        <div class="settings-grid">
          <label>焰晶双倍卡<input type="number" v-model.number="shopConfig.buff_doubleCrystal" class="setting-input" /></label>
          <label>修炼加速卡<input type="number" v-model.number="shopConfig.buff_cultivationBoost" class="setting-input" /></label>
          <label>幸运符<input type="number" v-model.number="shopConfig.buff_luckyCharm" class="setting-input" /></label>
        </div>
        <button class="gold-btn save-btn" @click="saveShopConfig()" style="margin-top:16px">💾 保存商城配置</button>
      </div>

      <!-- 抽卡配置 -->
      <div v-if="activeTab === 'gachaconfig'" class="tab-content">
        <h3 class="section-title">🎰 抽卡概率配置 (%)</h3>
        <div class="settings-grid">
          <label>SSR概率<input type="number" v-model.number="gachaConfig.ssr_rate" class="setting-input" step="0.1" /></label>
          <label>SR概率<input type="number" v-model.number="gachaConfig.sr_rate" class="setting-input" step="0.1" /></label>
          <label>R概率<input type="number" v-model.number="gachaConfig.r_rate" class="setting-input" step="0.1" /></label>
        </div>
        <h3 class="section-title" style="margin-top:20px">保底设置</h3>
        <div class="settings-grid">
          <label>SSR保底(抽数)<input type="number" v-model.number="gachaConfig.ssr_pity" class="setting-input" /></label>
          <label>SR保底(抽数)<input type="number" v-model.number="gachaConfig.sr_pity" class="setting-input" /></label>
          <label>单抽价格(焰晶)<input type="number" v-model.number="gachaConfig.draw_cost" class="setting-input" /></label>
        </div>
        <button class="gold-btn save-btn" @click="saveGachaConfig()" style="margin-top:16px">💾 保存抽卡配置</button>
      </div>

      <!-- Bug 反馈管理 -->
      <div v-if="activeTab === 'bugs'" class="tab-content">
        <div class="section-title">🐛 Bug 反馈列表</div>
        <div class="filter-bar">
          <select v-model="bugStatusFilter" @change="loadBugs" class="setting-input">
            <option value="">全部</option>
            <option value="pending">待处理</option>
            <option value="resolved">已解决</option>
            <option value="ignored">已忽略</option>
          </select>
          <button class="gold-btn" @click="loadBugs">刷新</button>
        </div>
        <div v-if="!bugs.length" class="empty-text">暂无反馈</div>
        <table v-else class="data-table">
          <thead><tr><th>ID</th><th>玩家</th><th>等级</th><th>类型</th><th>描述</th><th>状态</th><th>时间</th><th>操作</th></tr></thead>
          <tbody>
            <tr v-for="b in bugs" :key="b.id">
              <td>{{ b.id }}</td>
              <td>{{ b.player_name || shortAddr(b.wallet) }}</td>
              <td>{{ b.player_level || '-' }}</td>
              <td><span :class="'bug-type-' + b.type">{{ b.type === 'auto' ? '自动' : '手动' }}</span></td>
              <td class="bug-desc">{{ b.description || b.error_message || '-' }}</td>
              <td><span :class="'status-' + b.status">{{ bugStatusText(b.status) }}</span></td>
              <td>{{ fmtDate(b.created_at) }}</td>
              <td class="action-cell">
                <button v-if="b.status==='pending'" class="sm-btn" @click="updateBugStatus(b.id,'resolved')">✅ 解决</button>
                <button v-if="b.status==='pending'" class="sm-btn red" @click="updateBugStatus(b.id,'ignored')">❌ 忽略</button>
                <button v-if="b.status!=='pending'" class="sm-btn" @click="updateBugStatus(b.id,'pending')">🔄 重开</button>
                <button class="sm-btn" @click="viewBugDetail(b.id)">📋 详情</button>
              </td>
            </tr>
          </tbody>
        </table>
        <!-- Bug 详情弹窗 -->
        <div v-if="showBugDetail" class="modal-overlay" @click.self="showBugDetail=false">
          <div class="modal-box" style="max-width:600px">
            <h3>Bug #{{ bugDetail.id }} 详情</h3>
            <div class="bug-detail-grid">
              <div><b>玩家:</b> {{ bugDetail.player_name || shortAddr(bugDetail.wallet) }}</div>
              <div><b>等级:</b> {{ bugDetail.player_level || '-' }}</div>
              <div><b>类型:</b> {{ bugDetail.type === 'auto' ? '自动捕获' : '手动反馈' }}</div>
              <div><b>状态:</b> {{ bugStatusText(bugDetail.status) }}</div>
              <div><b>时间:</b> {{ fmtDate(bugDetail.created_at) }}</div>
              <div><b>页面:</b> {{ bugDetail.page_url || '-' }}</div>
              <div v-if="bugDetail.error_message" style="grid-column:1/-1"><b>错误信息:</b><pre class="bug-pre">{{ bugDetail.error_message }}</pre></div>
              <div v-if="bugDetail.error_stack" style="grid-column:1/-1"><b>堆栈:</b><pre class="bug-pre">{{ bugDetail.error_stack }}</pre></div>
              <div v-if="bugDetail.description" style="grid-column:1/-1"><b>描述:</b><p>{{ bugDetail.description }}</p></div>
              <div v-if="bugDetail.screenshot" style="grid-column:1/-1"><b>截图:</b><br/><img :src="bugDetail.screenshot" style="max-width:100%;border-radius:8px;margin-top:8px"/></div>
              <div v-if="bugDetail.browser_info" style="grid-column:1/-1"><b>浏览器:</b> {{ bugDetail.browser_info }}</div>
            </div>
            <div style="text-align:right;margin-top:12px"><button class="gold-btn" @click="showBugDetail=false">关闭</button></div>
          </div>
        </div>
      </div>

      <!-- 数据监控 -->
      <div v-if="activeTab === 'monitor'" class="tab-content">
        <div class="section-title">📈 数据监控 <button class="gold-btn" @click="loadMonitor" style="margin-left:12px">刷新</button></div>
        <div class="stat-cards">
          <div class="stat-card"><div class="stat-value">{{ monitorData.totalPlayers }}</div><div class="stat-label">总玩家</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.todayNew }}</div><div class="stat-label">今日新增</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.todayActive }}</div><div class="stat-label">今日活跃</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.todayLogins }}</div><div class="stat-label">今日登录次数</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.avgLevel }}</div><div class="stat-label">平均等级</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.maxLevel }}</div><div class="stat-label">最高等级</div></div>
          <div class="stat-card"><div class="stat-value">{{ formatNum(monitorData.totalStones) }}</div><div class="stat-label">全服焰晶</div></div>
          <div class="stat-card"><div class="stat-value">{{ monitorData.bugsPending }}/{{ monitorData.bugsTotal }}</div><div class="stat-label">待处理Bug</div></div>
        </div>
        <div class="chart-section">
          <h3 class="section-title">📊 7日登录趋势</h3>
          <div class="bar-chart">
            <div v-for="d in loginTrend" :key="d.day" class="bar-item">
              <div class="bar-fill" :style="{ height: barHeight(d.cnt) }"></div>
              <div class="bar-label">{{ d.day?.slice(5) }}</div>
              <div class="bar-value">{{ d.cnt }}</div>
            </div>
          </div>
        </div>
        <div class="chart-section">
          <h3 class="section-title">📊 等级分布</h3>
          <div class="bar-chart">
            <div v-for="d in levelDist" :key="d.range" class="bar-item">
              <div class="bar-fill" :style="{ height: barHeight(d.cnt) }"></div>
              <div class="bar-label">{{ d.range }}</div>
              <div class="bar-value">{{ d.cnt }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 操作日志 -->
      <div v-if="activeTab === 'logs'" class="tab-content">
        <h3 class="section-title">📋 管理员操作日志</h3>
        <div class="table-wrap">
          <table class="data-table">
            <thead><tr><th>时间</th><th>管理员</th><th>操作</th><th>目标</th><th>详情</th></tr></thead>
            <tbody>
              <tr v-for="log in adminLogs" :key="log.id">
                <td>{{ fmtDate(log.created_at) }}</td><td class="mono">{{ shortAddr(log.admin_wallet) }}</td>
                <td>{{ log.action }}</td><td class="mono">{{ shortAddr(log.target) }}</td>
                <td style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ typeof log.detail === 'object' ? JSON.stringify(log.detail) : log.detail }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="pagination" v-if="logTotalPages > 1">
          <button class="page-btn" :disabled="logPage <= 1" @click="loadLogs(logPage - 1)">上一页</button>
          <span class="page-info">第 {{ logPage }} / {{ logTotalPages }} 页</span>
          <button class="page-btn" :disabled="logPage >= logTotalPages" @click="loadLogs(logPage + 1)">下一页</button>
        </div>
      </div>

      <!-- 玩家深度编辑弹窗 -->
      <div v-if="showPlayerEditModal" class="modal-overlay" @click.self="showPlayerEditModal = false">
        <div class="modal wide">
          <h3>编辑玩家 - {{ editPlayerData.name }}</h3>
          <div class="settings-grid">
            <label>等级<input type="number" v-model.number="editPlayerData.level" class="setting-input" /></label>
            <label>境界<input v-model="editPlayerData.realm" class="setting-input" /></label>
            <label>VIP等级<input type="number" v-model.number="editPlayerData.vip_level" class="setting-input" min="0" max="10" /></label>
            <label>焰晶调整<input type="number" v-model.number="editPlayerData.stoneAdjust" class="setting-input" placeholder="正数加/负数减" /></label>
          </div>
          <div class="modal-actions">
            <button class="gold-btn" @click="savePlayerEdit()">保存修改</button>
            <button class="sm-btn" @click="showPlayerEditModal = false">取消</button>
          </div>
        </div>
      </div>

      <div v-if="activeTab === 'settings'" class="tab-content">
        <div class="settings-section">
          <h3 class="section-title">VIP 配置</h3>
          <div class="table-wrap">
            <table class="data-table">
              <thead><tr><th>VIP等级</th><th>所需充值(ROON)</th><th>经验加成(%)</th><th>掉落加成(%)</th><th>每日焰晶</th></tr></thead>
              <tbody>
                <tr v-for="v in settingsData.vip_config" :key="v.level">
                  <td>VIP{{ v.level }}</td>
                  <td><input type="number" v-model.number="v.required_recharge" class="table-input" /></td>
                  <td><input type="number" v-model.number="v.exp_bonus" class="table-input" /></td>
                  <td><input type="number" v-model.number="v.drop_bonus" class="table-input" /></td>
                  <td><input type="number" v-model.number="v.daily_stones" class="table-input" /></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="settings-section">
          <h3 class="section-title">月卡参数</h3>
          <div class="settings-grid">
            <label>月卡价格(ROON)<input type="number" v-model.number="settingsData.monthly_card_price" class="setting-input" /></label>
            <label>每日焰晶<input type="number" v-model.number="settingsData.monthly_card_daily" class="setting-input" /></label>
            <label>持续天数<input type="number" v-model.number="settingsData.monthly_card_days" class="setting-input" /></label>
          </div>
        </div>
        <div class="settings-section">
          <h3 class="section-title">充值比率</h3>
          <div class="settings-grid">
            <label>1 ROON = 焰晶<input type="number" v-model.number="settingsData.recharge_rate" class="setting-input" /></label>
          </div>
        </div>
        <button class="gold-btn save-btn" @click="saveSettings()">💾 保存设置</button>
      </div>
    </div>
    <!-- 弹窗: 调整焰晶 -->
    <div v-if="showAdjustModal" class="modal-overlay" @click.self="showAdjustModal = false">
      <div class="modal">
        <h3>调整焰晶 - {{ adjustTarget?.name }}</h3>
        <p class="modal-hint">正数增加，负数扣除</p>
        <input type="number" v-model.number="adjustAmount" class="modal-input" placeholder="输入数量" />
        <div class="modal-actions">
          <button class="gold-btn" @click="confirmAdjustStones()">确认</button>
          <button class="sm-btn" @click="showAdjustModal = false">取消</button>
        </div>
      </div>
    </div>
    <!-- 弹窗: 公告编辑 -->
    <div v-if="showAnnouncementModal" class="modal-overlay" @click.self="showAnnouncementModal = false">
      <div class="modal">
        <h3>{{ editingAnnouncement?.id ? '编辑公告' : '新建公告' }}</h3>
        <input v-model="editingAnnouncement.title" class="modal-input" placeholder="标题" />
        <textarea v-model="editingAnnouncement.content" class="modal-textarea" placeholder="内容" rows="5"></textarea>
        <div class="modal-actions">
          <button class="gold-btn" @click="saveAnnouncement()">保存</button>
          <button class="sm-btn" @click="showAnnouncementModal = false">取消</button>
        </div>
      </div>
    </div>
    <!-- 弹窗: 活动编辑 -->
    <div v-if="showEventModal" class="modal-overlay" @click.self="showEventModal = false">
      <div class="modal">
        <h3>{{ editingEvent?.id ? '编辑活动' : '新建活动' }}</h3>
        <input v-model="editingEvent.name" class="modal-input" placeholder="活动名称" />
        <input v-model="editingEvent.type" class="modal-input" placeholder="类型" />
        <label class="modal-label">开始时间<input type="datetime-local" v-model="editingEvent.start_time" class="modal-input" /></label>
        <label class="modal-label">结束时间<input type="datetime-local" v-model="editingEvent.end_time" class="modal-input" /></label>
        <textarea v-model="editingEvent.description" class="modal-textarea" placeholder="描述" rows="3"></textarea>
        <div class="modal-actions">
          <button class="gold-btn" @click="saveEvent()">保存</button>
          <button class="sm-btn" @click="showEventModal = false">取消</button>
        </div>
      </div>
    </div>
    <!-- 弹窗: 玩家详情 -->
    <div v-if="showPlayerDetail" class="modal-overlay" @click.self="showPlayerDetail = false">
      <div class="modal wide">
        <h3>玩家详情</h3>
        <div class="detail-grid" v-if="detailPlayer">
          <div class="detail-item" v-for="(val, key) in detailPlayer" :key="key">
            <span class="detail-key">{{ key }}</span>
            <span class="detail-val">{{ val }}</span>
          </div>
        </div>
        <div class="modal-actions"><button class="sm-btn" @click="showPlayerDetail = false">关闭</button></div>
      </div>
    </div>
  </div>
  <!-- 无权限 -->
  <div v-else class="access-denied">
    <div class="denied-box">
      <div class="denied-icon">🚫</div>
      <h2>无权限访问</h2>
      <p>你没有管理员权限</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'

const API_BASE = '/api/admin'
const token = () => localStorage.getItem('xx_token') || ''
const headers = () => ({ 'Content-Type': 'application/json', Authorization: `Bearer ${token()}` })

const accessDenied = ref(false)
const mailTitle = ref('')
const mailContent = ref('')
const mailTarget = ref('all')
const mailTargetWallet = ref('')
const mailRewardStones = ref(0)
const mailRewardReinforce = ref(0)
const mailRewardEssence = ref(0)
const mailResult = ref('')

const sendMail = async () => {
  try {
    const rewards = {}
    if (mailRewardStones.value > 0) rewards.spiritStones = mailRewardStones.value
    if (mailRewardReinforce.value > 0) rewards.reinforceStones = mailRewardReinforce.value
    if (mailRewardEssence.value > 0) rewards.petEssence = mailRewardEssence.value
    const target = mailTarget.value === 'all' ? 'all' : mailTargetWallet.value
    const data = await authStore.apiPost('/admin/mail/send', {
      title: mailTitle.value, content: mailContent.value, rewards, target
    })
    mailResult.value = '✅ 发送成功！共发送 ' + data.sent + ' 封'
    mailTitle.value = ''; mailContent.value = ''
    mailRewardStones.value = 0; mailRewardReinforce.value = 0; mailRewardEssence.value = 0
  } catch (e) { mailResult.value = '❌ ' + e.message }
}

const activeTab = ref('dashboard')
const tabs = [
  { key: 'dashboard', label: '📊 仪表盘' },
  { key: 'players', label: '👤 玩家管理' },
  { key: 'economy', label: '💰 经济总览' },
  { key: 'leaderboard', label: '🏆 排行榜' },
  { key: 'auction', label: '🏪 拍卖监控' },
  { key: 'online', label: '🟢 在线监控' },
  { key: 'recharges', label: '💎 充值记录' },
  { key: 'announcements', label: '📢 公告管理' },
  { key: 'sects', label: '⚔️ 焰盟管理' },
  { key: 'events', label: '🎉 活动管理' },
  { key: 'boss', label: '👹 Boss管理' },
  { key: 'mail', label: '📬 邮件管理' },
  { key: 'airdrop', label: '🎁 批量空投' },
  { key: 'shopconfig', label: '🛒 商城配置' },
  { key: 'gachaconfig', label: '🎰 抽卡配置' },
  { key: 'bugs', label: '🐛 Bug反馈' },
  { key: 'monitor', label: '📈 数据监控' },
  { key: 'logs', label: '📋 操作日志' },
  { key: 'settings', label: '⚙️ 系统设置' },
]

// helpers
const shortAddr = (s) => s ? (s.length > 12 ? s.slice(0, 6) + '...' + s.slice(-4) : s) : '-'
const formatNum = (n) => n != null ? Number(n).toLocaleString() : '0'
const fmtDate = (d) => d ? new Date(d).toLocaleString('zh-CN') : '-'

async function apiFetch(path, opts = {}) {
  const res = await fetch(API_BASE + path, { headers: headers(), ...opts })
  if (res.status === 403) { accessDenied.value = true; return null }
  if (!res.ok) { const t = await res.text(); alert('请求失败: ' + t); return null }
  return res.json()
}

// Bug 反馈
const bugs = ref([])
const bugStatusFilter = ref('')
const showBugDetail = ref(false)
const bugDetail = ref({})

function bugStatusText(s) { return { pending: '待处理', resolved: '已解决', ignored: '已忽略' }[s] || s }

async function loadBugs() {
  const params = bugStatusFilter.value ? '?status=' + bugStatusFilter.value : ''
  const data = await apiFetch('/bug-reports' + params)
  if (data) bugs.value = data.reports || data || []
}

async function updateBugStatus(id, status) {
  await apiFetch('/bug-reports/' + id + '/status', { method: 'POST', headers: { ...headers(), 'Content-Type': 'application/json' }, body: JSON.stringify({ status }) })
  loadBugs()
}

async function viewBugDetail(id) {
  const data = await apiFetch('/bug-reports/' + id)
  if (data) { bugDetail.value = data.report || data; showBugDetail.value = true }
}

// 数据监控
const monitorData = ref({ totalPlayers: 0, todayNew: 0, todayActive: 0, todayLogins: 0, avgLevel: 0, maxLevel: 0, totalStones: 0, totalRecharge: 0, bugsPending: 0, bugsTotal: 0 })
const loginTrend = ref([])
const levelDist = ref([])

async function loadMonitor() {
  const data = await apiFetch('/monitor')
  if (data) {
    monitorData.value = data.overview || {}
    loginTrend.value = data.loginTrend || []
    levelDist.value = data.levelDistribution || []
  }
}

function barHeight(cnt) {
  const max = Math.max(...loginTrend.value.map(d => +d.cnt), ...levelDist.value.map(d => +d.cnt), 1)
  return Math.max(10, (+cnt / max) * 120) + 'px'
}

// ===== Dashboard =====
const dashboardData = ref({})
const dashboardStats = computed(() => {
  const d = dashboardData.value
  return [
    { label: '玩家总数', value: formatNum(d.total_players) },
    { label: '今日新增', value: formatNum(d.today_new) },
    { label: '充值总额(ROON)', value: formatNum(d.total_recharge) },
    { label: '今日充值', value: formatNum(d.today_recharge) },
  ]
})
const vipDistribution = computed(() => {
  const dist = dashboardData.value.vip_distribution || []
  const total = dist.reduce((s, v) => s + (v.count || 0), 0) || 1
  return dist.map(v => ({ ...v, percent: ((v.count / total) * 100).toFixed(1) }))
})
const pieColors = ['#d4af37', '#8b6914', '#c0a060', '#e8c84a', '#a08030', '#f0d860', '#706020', '#b09840', '#d0c070', '#605010']
const pieStyle = computed(() => {
  const dist = vipDistribution.value
  if (!dist.length) return {}
  let acc = 0
  const stops = dist.map((v, i) => {
    const start = acc
    acc += parseFloat(v.percent)
    return `${pieColors[i % pieColors.length]} ${start}% ${acc}%`
  })
  return { background: `conic-gradient(${stops.join(', ')})` }
})

async function loadDashboard() {
  const d = await apiFetch('/dashboard')
  if (d) dashboardData.value = d
}

// ===== Players =====
const players = ref([])
const playerSearch = ref('')
const playerPage = ref(1)
const playerTotal = ref(0)
const playerLimit = 20
const playerTotalPages = computed(() => Math.max(1, Math.ceil(playerTotal.value / playerLimit)))

async function loadPlayers(page = 1) {
  playerPage.value = page
  const q = new URLSearchParams({ page, limit: playerLimit })
  if (playerSearch.value) q.set('search', playerSearch.value)
  const d = await apiFetch('/players?' + q)
  if (d) { players.value = d.players || d.data || []; playerTotal.value = d.total || 0 }
}

const showPlayerDetail = ref(false)
const detailPlayer = ref(null)
function viewPlayer(p) { detailPlayer.value = { ...p }; showPlayerDetail.value = true }

async function toggleBan(p) {
  const action = p.banned ? 'unban' : 'ban'
  if (!confirm(`确定${p.banned ? '解封' : '封禁'} ${p.name}?`)) return
  await apiFetch(`/players/${p.wallet}/${action}`, { method: 'POST' })
  loadPlayers(playerPage.value)
}

const showAdjustModal = ref(false)
const adjustTarget = ref(null)
const adjustAmount = ref(0)
function openAdjustStones(p) { adjustTarget.value = p; adjustAmount.value = 0; showAdjustModal.value = true }
async function confirmAdjustStones() {
  if (!adjustAmount.value) return
  await apiFetch(`/players/${adjustTarget.value.wallet}/adjust-stones`, {
    method: 'POST', body: JSON.stringify({ amount: adjustAmount.value })
  })
  showAdjustModal.value = false
  loadPlayers(playerPage.value)
}

// ===== Recharges =====
const recharges = ref([])
const rechargeWallet = ref('')
const rechargeDateFrom = ref('')
const rechargeDateTo = ref('')
const rechargePage = ref(1)
const rechargeTotal = ref(0)
const rechargeLimit = 20
const rechargeTotalPages = computed(() => Math.max(1, Math.ceil(rechargeTotal.value / rechargeLimit)))

async function loadRecharges(page = 1) {
  rechargePage.value = page
  const q = new URLSearchParams({ page, limit: rechargeLimit })
  if (rechargeWallet.value) q.set('wallet', rechargeWallet.value)
  if (rechargeDateFrom.value) q.set('from', rechargeDateFrom.value)
  if (rechargeDateTo.value) q.set('to', rechargeDateTo.value)
  const d = await apiFetch('/recharges?' + q)
  if (d) { recharges.value = d.recharges || d.data || []; rechargeTotal.value = d.total || 0 }
}

// ===== Announcements =====
const announcements = ref([])
const showAnnouncementModal = ref(false)
const editingAnnouncement = reactive({ id: null, title: '', content: '' })

async function loadAnnouncements() {
  const d = await apiFetch('/announcements')
  if (d) announcements.value = d.announcements || d.data || d || []
}
function openAnnouncementForm(a) {
  editingAnnouncement.id = a?.id || null
  editingAnnouncement.title = a?.title || ''
  editingAnnouncement.content = a?.content || ''
  showAnnouncementModal.value = true
}
async function saveAnnouncement() {
  const body = JSON.stringify({ title: editingAnnouncement.title, content: editingAnnouncement.content })
  if (editingAnnouncement.id) {
    await apiFetch(`/announcements/${editingAnnouncement.id}`, { method: 'PUT', body })
  } else {
    await apiFetch('/announcements', { method: 'POST', body })
  }
  showAnnouncementModal.value = false
  loadAnnouncements()
}
async function deleteAnnouncement(id) {
  if (!confirm('确定删除此公告?')) return
  await apiFetch(`/announcements/${id}`, { method: 'DELETE' })
  loadAnnouncements()
}

// ===== Sects =====
const sects = ref([])
async function loadSects() {
  const d = await apiFetch('/sects')
  if (d) sects.value = d.sects || d.data || d || []
}
async function dissolveSect(s) {
  if (!confirm(`确定解散焰盟「${s.name}」?`)) return
  await apiFetch(`/sects/${s.id}`, { method: 'DELETE' })
  loadSects()
}

// ===== Events =====
const events = ref([])
const showEventModal = ref(false)
const editingEvent = reactive({ id: null, name: '', type: '', start_time: '', end_time: '', description: '' })

async function loadEvents() {
  const d = await apiFetch('/events')
  if (d) events.value = d.events || d.data || d || []
}
function openEventForm(e) {
  editingEvent.id = e?.id || null
  editingEvent.name = e?.name || ''
  editingEvent.type = e?.type || ''
  editingEvent.start_time = e?.start_time ? e.start_time.slice(0, 16) : ''
  editingEvent.end_time = e?.end_time ? e.end_time.slice(0, 16) : ''
  editingEvent.description = e?.description || ''
  showEventModal.value = true
}
async function saveEvent() {
  const body = JSON.stringify({ ...editingEvent })
  if (editingEvent.id) {
    await apiFetch(`/events/${editingEvent.id}`, { method: 'PUT', body })
  } else {
    await apiFetch('/events', { method: 'POST', body })
  }
  showEventModal.value = false
  loadEvents()
}
async function deleteEvent(id) {
  if (!confirm('确定删除此活动?')) return
  await apiFetch(`/events/${id}`, { method: 'DELETE' })
  loadEvents()
}

// ===== Boss =====
const bossList = ref([])
const currentBoss = ref(null)

async function loadBoss() {
  const d = await apiFetch('/boss/list')
  if (d) {
    const list = d.bosses || d.data || d || []
    currentBoss.value = list.find(b => b.status === 'alive') || null
    bossList.value = list
  }
}
async function spawnBoss() {
  if (!confirm('确定生成新Boss?')) return
  await apiFetch('/boss/spawn', { method: 'POST' })
  loadBoss()
}

// ===== Settings =====
const settingsData = reactive({
  vip_config: [],
  monthly_card_price: 0,
  monthly_card_daily: 0,
  monthly_card_days: 30,
  recharge_rate: 100,
})

async function loadSettings() {
  const d = await apiFetch('/settings')
  if (d) Object.assign(settingsData, d)
}
async function saveSettings() {
  await apiFetch('/settings', { method: 'PUT', body: JSON.stringify(settingsData) })
  alert('设置已保存')
}

// ===== Economy =====
const economyData = ref({ totalStones: 0, avgStones: 0, medianStones: 0, totalPlayers: 0, richest: [] })
async function loadEconomy() {
  const d = await apiFetch('/economy')
  if (d) economyData.value = d
}

// ===== Leaderboard =====
const lbType = ref('power')
const leaderboardData = ref([])
async function loadLeaderboard() {
  const d = await apiFetch('/leaderboard/' + lbType.value)
  if (d) leaderboardData.value = d.leaderboard || d.data || d || []
}

// ===== Auction Monitor =====
const auctionView = ref('active')
const auctionList = ref([])
async function loadAuction() {
  const d = await apiFetch('/auction/' + auctionView.value)
  if (d) auctionList.value = d.auctions || d.data || d || []
}
async function forceRemoveAuction(id) {
  if (!confirm('确定强制下架此拍品?')) return
  await apiFetch('/auction/' + id, { method: 'DELETE' })
  loadAuction()
}

// ===== Online Monitor =====
const onlineData = ref({ onlineCount: 0, activeCount: 0, activePlayers: [] })
async function loadOnline() {
  const d = await apiFetch('/online')
  if (d) onlineData.value = d
}

// ===== Airdrop =====
const airdropData = reactive({ spiritStones: 0, reinforceStones: 0, refinementStones: 0, petEssence: 0, title: '全服福利', content: '' })
const airdropResult = ref('')
async function sendAirdrop() {
  if (!confirm('确定向全服玩家发送空投?')) return
  airdropResult.value = ''
  const d = await apiFetch('/airdrop', { method: 'POST', body: JSON.stringify(airdropData) })
  if (d) airdropResult.value = '✅ 空投成功！共发送 ' + (d.sent || d.count || '?') + ' 人'
}

// ===== Shop Config =====
const shopConfig = reactive({ reinforce_stone: 1000, reinforce_stone_10: 9000, refine_stone: 1500, refine_stone_10: 13500, buff_doubleCrystal: 5000, buff_cultivationBoost: 3000, buff_luckyCharm: 8000 })
async function loadShopConfig() {
  const d = await apiFetch('/shop-config')
  if (d) Object.assign(shopConfig, d.config || d)
}
async function saveShopConfig() {
  await apiFetch('/shop-config', { method: 'PUT', body: JSON.stringify(shopConfig) })
  alert('商城配置已保存')
}

// ===== Gacha Config =====
const gachaConfig = reactive({ ssr_rate: 1.5, sr_rate: 10, r_rate: 88.5, ssr_pity: 80, sr_pity: 10, draw_cost: 1000 })
async function loadGachaConfig() {
  const d = await apiFetch('/gacha-config')
  if (d) Object.assign(gachaConfig, d.config || d)
}
async function saveGachaConfig() {
  await apiFetch('/gacha-config', { method: 'PUT', body: JSON.stringify(gachaConfig) })
  alert('抽卡配置已保存')
}

// ===== Admin Logs =====
const adminLogs = ref([])
const logPage = ref(1)
const logTotal = ref(0)
const logLimit = 30
const logTotalPages = computed(() => Math.max(1, Math.ceil(logTotal.value / logLimit)))
async function loadLogs(page = 1) {
  logPage.value = page
  const d = await apiFetch('/logs?page=' + page + '&limit=' + logLimit)
  if (d) { adminLogs.value = d.logs || d.data || d || []; logTotal.value = d.total || 0 }
}

// ===== Player Deep Edit =====
const showPlayerEditModal = ref(false)
const editPlayerData = reactive({ wallet: '', name: '', level: 1, realm: '', vip_level: 0, stoneAdjust: 0 })
function openPlayerEdit(p) {
  editPlayerData.wallet = p.wallet
  editPlayerData.name = p.name
  editPlayerData.level = p.level
  editPlayerData.realm = p.realm
  editPlayerData.vip_level = p.vip_level
  editPlayerData.stoneAdjust = 0
  showPlayerEditModal.value = true
}
async function savePlayerEdit() {
  const w = editPlayerData.wallet
  // Update level
  await apiFetch('/players/' + w + '/level', { method: 'PUT', body: JSON.stringify({ level: editPlayerData.level, realm: editPlayerData.realm }) })
  // Update VIP
  await apiFetch('/players/' + w + '/vip', { method: 'PUT', body: JSON.stringify({ vipLevel: editPlayerData.vip_level }) })
  // Adjust stones
  if (editPlayerData.stoneAdjust !== 0) {
    await apiFetch('/players/' + w + '/stones', { method: 'PUT', body: JSON.stringify({ amount: editPlayerData.stoneAdjust }) })
  }
  showPlayerEditModal.value = false
  loadPlayers(playerPage.value)
  alert('玩家数据已更新')
}

// ===== Tab watcher =====
const loaders = {
  dashboard: loadDashboard,
  players: () => loadPlayers(1),
  economy: loadEconomy,
  leaderboard: loadLeaderboard,
  auction: loadAuction,
  online: loadOnline,
  recharges: () => loadRecharges(1),
  announcements: loadAnnouncements,
  sects: loadSects,
  events: loadEvents,
  boss: loadBoss,
  mail: () => {},
  airdrop: () => {},
  shopconfig: loadShopConfig,
  gachaconfig: loadGachaConfig,
  bugs: loadBugs,
  monitor: loadMonitor,
  logs: () => loadLogs(1),
  settings: loadSettings,
}
watch(activeTab, (tab) => { if (loaders[tab]) loaders[tab]() })

onMounted(async () => {
  await loadDashboard()
})
</script>

<style scoped>
.admin-page {
  min-height: 100vh;
  background: #0a0a0a;
  color: #e0d5c0;
  font-family: 'Noto Serif SC', serif;
  padding: 20px;
  box-sizing: border-box;
}
.admin-header {
  text-align: center;
  margin-bottom: 24px;
}
.admin-title {
  color: #d4af37;
  font-size: 1.8em;
  margin: 0 0 16px;
  text-shadow: 0 0 10px rgba(212,175,55,0.3);
}
.tab-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}
.tab-btn {
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #e0d5c0;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.9em;
  transition: all 0.2s;
}
.tab-btn:hover { border-color: #d4af37; color: #d4af37; }
.tab-btn.active {
  background: rgba(212,175,55,0.15);
  border-color: #d4af37;
  color: #d4af37;
  font-weight: bold;
}
.admin-body { max-width: 1200px; margin: 0 auto; }
.tab-content { animation: fadeIn 0.3s ease; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }

/* Stat Cards */
.stat-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  border-radius: 10px;
  padding: 20px;
  text-align: center;
}
.stat-value {
  font-size: 1.6em;
  color: #d4af37;
  font-weight: bold;
  margin-bottom: 6px;
}
.stat-label { font-size: 0.85em; color: #a09880; }
.section-title {
  color: #d4af37;
  font-size: 1.1em;
  margin: 20px 0 12px;
  padding-bottom: 6px;
  border-bottom: 1px solid rgba(212,175,55,0.2);
}

/* Pie Chart */
.pie-chart-container { display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
.pie-chart {
  width: 160px; height: 160px;
  border-radius: 50%;
  border: 2px solid rgba(212,175,55,0.3);
  flex-shrink: 0;
}
.pie-legend { display: flex; flex-direction: column; gap: 6px; }
.legend-item { display: flex; align-items: center; gap: 8px; font-size: 0.85em; }
.legend-color { width: 14px; height: 14px; border-radius: 3px; flex-shrink: 0; }

/* Toolbar */
.toolbar {
  display: flex; flex-wrap: wrap; gap: 10px;
  margin-bottom: 16px; align-items: center;
}
.search-input, .date-input {
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #e0d5c0;
  padding: 8px 12px;
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9em;
}
.search-input { min-width: 220px; }
.search-input:focus, .date-input:focus { outline: none; border-color: #d4af37; }
.gold-btn {
  background: linear-gradient(135deg, #d4af37, #8b6914);
  color: #0a0a0a;
  border: none;
  padding: 8px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-family: inherit;
  font-weight: bold;
  font-size: 0.9em;
  transition: opacity 0.2s;
}
.gold-btn:hover { opacity: 0.85; }

/* Table */
.table-wrap { overflow-x: auto; }
.data-table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.2);
  border-radius: 8px;
  overflow: hidden;
}
.data-table th {
  background: rgba(212,175,55,0.1);
  color: #d4af37;
  padding: 10px 12px;
  text-align: left;
  font-size: 0.85em;
  white-space: nowrap;
}
.data-table td {
  padding: 10px 12px;
  border-top: 1px solid rgba(212,175,55,0.1);
  font-size: 0.85em;
  vertical-align: middle;
}
.data-table tr:hover td { background: rgba(212,175,55,0.05); }
.mono { font-family: 'Courier New', monospace; font-size: 0.82em; }
.content-cell { max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.actions { white-space: nowrap; display: flex; gap: 6px; }
.sm-btn {
  background: rgba(212,175,55,0.15);
  border: 1px solid rgba(212,175,55,0.3);
  color: #d4af37;
  padding: 4px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.8em;
  font-family: inherit;
  transition: all 0.2s;
}
.sm-btn:hover { background: rgba(212,175,55,0.25); }
.sm-btn.red { color: #e74c3c; border-color: rgba(231,76,60,0.3); background: rgba(231,76,60,0.1); }
.sm-btn.red:hover { background: rgba(231,76,60,0.2); }
.sm-btn.green { color: #2ecc71; border-color: rgba(46,204,113,0.3); background: rgba(46,204,113,0.1); }
.sm-btn.green:hover { background: rgba(46,204,113,0.2); }
.status-badge {
  padding: 2px 8px; border-radius: 10px; font-size: 0.8em;
}
.status-badge.active { background: rgba(46,204,113,0.15); color: #2ecc71; }
.status-badge.inactive { background: rgba(231,76,60,0.15); color: #e74c3c; }

/* Pagination */
.pagination {
  display: flex; justify-content: center; align-items: center;
  gap: 16px; margin-top: 16px; padding: 12px 0;
}
.page-btn {
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #d4af37;
  padding: 6px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-family: inherit;
}
.page-btn:disabled { opacity: 0.3; cursor: not-allowed; }
.page-btn:not(:disabled):hover { border-color: #d4af37; background: rgba(212,175,55,0.1); }
.page-info { color: #a09880; font-size: 0.85em; }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.7);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}
.modal {
  background: #141414;
  border: 1px solid rgba(212,175,55,0.4);
  border-radius: 12px;
  padding: 24px;
  min-width: 360px;
  max-width: 90vw;
  max-height: 80vh;
  overflow-y: auto;
  animation: fadeIn 0.2s ease;
}
.modal.wide { min-width: 500px; }
.modal h3 { color: #d4af37; margin: 0 0 16px; font-size: 1.1em; }
.modal-hint { color: #a09880; font-size: 0.85em; margin-bottom: 12px; }
.modal-input {
  width: 100%;
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #e0d5c0;
  padding: 10px 12px;
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9em;
  margin-bottom: 12px;
  box-sizing: border-box;
}
.modal-input:focus { outline: none; border-color: #d4af37; }
.modal-textarea {
  width: 100%;
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #e0d5c0;
  padding: 10px 12px;
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9em;
  margin-bottom: 12px;
  resize: vertical;
  box-sizing: border-box;
}
.modal-textarea:focus { outline: none; border-color: #d4af37; }
.modal-label { display: block; color: #a09880; font-size: 0.85em; margin-bottom: 4px; }
.modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 8px; }

/* Detail */
.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 10px;
  margin-bottom: 16px;
}
.detail-item {
  background: rgba(20,20,20,0.8);
  border: 1px solid rgba(212,175,55,0.15);
  border-radius: 6px;
  padding: 8px 12px;
}
.detail-key { color: #a09880; font-size: 0.8em; display: block; margin-bottom: 2px; }
.detail-val { color: #e0d5c0; font-size: 0.9em; word-break: break-all; }

/* Settings */
.settings-section { margin-bottom: 28px; }
.settings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}
.settings-grid label {
  display: flex; flex-direction: column; gap: 4px;
  color: #a09880; font-size: 0.85em;
}
.setting-input {
  background: rgba(20,20,20,0.9);
  border: 1px solid rgba(212,175,55,0.3);
  color: #e0d5c0;
  padding: 8px 10px;
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9em;
}
.setting-input:focus { outline: none; border-color: #d4af37; }
.table-input {
  background: rgba(10,10,10,0.8);
  border: 1px solid rgba(212,175,55,0.2);
  color: #e0d5c0;
  padding: 4px 8px;
  border-radius: 4px;
  width: 80px;
  font-family: inherit;
  font-size: 0.85em;
  text-align: center;
}
.table-input:focus { outline: none; border-color: #d4af37; }
.save-btn { margin-top: 8px; padding: 10px 32px; font-size: 1em; }

/* Boss */
.boss-current { margin-bottom: 20px; }

/* Access Denied */
.access-denied {
  min-height: 100vh;
  background: #0a0a0a;
  display: flex; align-items: center; justify-content: center;
  font-family: 'Noto Serif SC', serif;
}
.denied-box { text-align: center; color: #e0d5c0; }
.denied-icon { font-size: 4em; margin-bottom: 16px; }
.denied-box h2 { color: #e74c3c; margin-bottom: 8px; }
.denied-box p { color: #a09880; }

/* Responsive */
@media (max-width: 768px) {
  .admin-page { padding: 12px; }
  .admin-title { font-size: 1.3em; }
  .tab-btn { padding: 6px 10px; font-size: 0.8em; }
  .stat-cards { grid-template-columns: repeat(2, 1fr); }
  .stat-value { font-size: 1.2em; }
  .modal { min-width: auto; width: 95vw; padding: 16px; }
  .modal.wide { min-width: auto; }
  .pie-chart-container { flex-direction: column; align-items: flex-start; }
  .detail-grid { grid-template-columns: 1fr; }
  .settings-grid { grid-template-columns: 1fr; }
  .data-table { font-size: 0.8em; }
}
.gold { color: #d4af37; font-weight: bold; }
.sm-btn.active { background: #d4af37; color: #0a0a0a; border-color: #d4af37; }
.settings-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
.settings-grid label { display: flex; flex-direction: column; gap: 4px; color: #a09880; font-size: 0.85em; }
.setting-input { background: #1a1a1a; border: 1px solid #333; color: #e0d5c0; padding: 8px; border-radius: 4px; font-size: 1em; }
.modal-textarea { background: #1a1a1a; border: 1px solid #333; color: #e0d5c0; padding: 8px; border-radius: 4px; width: 100%; font-size: 0.95em; resize: vertical; }
.save-btn { display: block; margin-top: 16px; }


/* Bug 反馈 */
.bug-type-auto { color: #ff9800; }
.bug-type-manual { color: #4caf50; }
.status-pending { color: #ff9800; font-weight: bold; }
.status-resolved { color: #4caf50; }
.status-ignored { color: #999; }
.bug-desc { max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.bug-detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; font-size: 13px; }
.bug-pre { background: #1a1a2e; padding: 8px; border-radius: 6px; font-size: 11px; overflow-x: auto; max-height: 150px; white-space: pre-wrap; word-break: break-all; }
.action-cell { white-space: nowrap; }
.filter-bar { display: flex; gap: 8px; margin-bottom: 12px; align-items: center; }

/* 数据监控柱状图 */
.bar-chart { display: flex; align-items: flex-end; gap: 12px; padding: 16px 0; min-height: 160px; }
.bar-item { display: flex; flex-direction: column; align-items: center; flex: 1; }
.bar-fill { width: 100%; max-width: 40px; background: linear-gradient(180deg, #ff6a00, #ff2d55); border-radius: 4px 4px 0 0; transition: height 0.3s; min-height: 4px; }
.bar-label { font-size: 11px; color: #aaa; margin-top: 4px; }
.bar-value { font-size: 12px; color: #ffddaa; font-weight: bold; }
</style>
