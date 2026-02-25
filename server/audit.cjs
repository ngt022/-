const pg=require("pg");
const pool=new pg.Pool({connectionString:"postgresql://roon_user:RoonG%40ming2026!@127.0.0.1:5432/xiuxian_test"});
(async()=>{
  const r=await pool.query("SELECT wallet,game_data,spirit_stones FROM players WHERE wallet NOT LIKE '0xbot%'");
  const now=Date.now();
  console.log("=== 焰晶同步检查 ===");
  for(const row of r.rows){
    const gd=row.game_data||{};
    const col=Number(row.spirit_stones)||0;
    const gdS=Number(gd.spiritStones)||0;
    const diff=col-gdS;
    if(diff!==0)console.log("  MISMATCH "+row.wallet.slice(0,10)+" col:"+col+" gd:"+gdS+" diff:"+diff);
  }
  console.log("\n=== 装备强化检查 ===");
  for(const row of r.rows){
    const gd=row.game_data||{};
    const eq=gd.equippedArtifacts||{};
    for(const[slot,item] of Object.entries(eq)){
      if(!item)continue;
      if((item.enhanceLevel||0)>20)console.log("  HIGH "+row.wallet.slice(0,10)+" "+item.name+" +"+item.enhanceLevel);
    }
  }
  console.log("\n=== 过期Buff检查 ===");
  for(const row of r.rows){
    const gd=row.game_data||{};
    const buffs=gd.buffs||{};
    const expired=Object.entries(buffs).filter(([k,v])=>v<now&&v>0);
    if(expired.length)console.log("  "+row.wallet.slice(0,10)+" expired: "+expired.map(([k])=>k).join(","));
  }
  console.log("\n=== 宠物deployed检查 ===");
  for(const row of r.rows){
    const gd=row.game_data||{};
    const pet=gd.activePet;
    if(pet&&!pet.deployed)console.log("  "+row.wallet.slice(0,10)+" activePet "+pet.name+" deployed="+pet.deployed);
    const items=gd.items||[];
    const dp=items.filter(i=>i.type==="pet"&&i.deployed===true);
    if(dp.length>1)console.log("  "+row.wallet.slice(0,10)+" MULTI DEPLOYED: "+dp.map(p=>p.name).join(","));
  }
  console.log("\n=== 装备百分比溢出检查 ===");
  const PS=["critRate","critDamageBoost","dodgeRate","vampireRate","comboRate","counterRate","stunRate","healBoost","spiritRate","combatBoost","resistanceBoost","finalDamageBoost","finalDamageReduce","critDamageReduce","stunResist","vampireResist","dodgeResist","comboResist","counterResist","critResist","cultivationRate"];
  for(const row of r.rows){
    const gd=row.game_data||{};
    const all=[...Object.values(gd.equippedArtifacts||{}),...(gd.items||[]).filter(i=>i.stats)];
    for(const item of all){
      if(!item||!item.stats)continue;
      for(const s of PS){
        if(item.stats[s]&&item.stats[s]>0.25)console.log("  HIGH "+row.wallet.slice(0,10)+" "+item.name+" "+s+"="+item.stats[s]);
      }
    }
  }
  console.log("\n=== 完成 ===");
  await pool.end();
})();
