const pg=require("pg");
const pool=new pg.Pool({connectionString:"postgresql://roon_user:RoonG%40ming2026!@127.0.0.1:5432/xiuxian_test"});
(async()=>{
  const wallet="0x82e402b05f3e936b63a874788c73e1552657c4f7";
  const r=await pool.query("SELECT game_data,spirit_stones FROM players WHERE wallet=$1",[wallet]);
  const gd=r.rows[0].game_data;
  const colStones=Number(r.rows[0].spirit_stones);
  
  // 1. 同步焰晶 (以列为准)
  console.log("Fix 1: 焰晶同步 gd:"+gd.spiritStones+" -> col:"+colStones);
  gd.spiritStones=colStones;
  
  // 2. 清理过期buff
  const now=Date.now();
  const buffs=gd.buffs||{};
  const expired=Object.entries(buffs).filter(([k,v])=>v<now&&v>0);
  for(const[k]of expired){
    console.log("Fix 2: 清理过期buff: "+k);
    delete buffs[k];
  }
  // 也清理对应的pillBuffValues
  const pbv=gd.pillBuffValues||{};
  for(const[k]of expired){
    if(pbv[k])delete pbv[k];
  }
  gd.buffs=buffs;
  gd.pillBuffValues=pbv;
  
  // 3. 修复多宠物deployed - 只保留activePet的deployed
  const activePetName=gd.activePet?gd.activePet.name:null;
  console.log("Fix 3: activePet="+activePetName);
  const items=gd.items||[];
  let fixedPets=0;
  for(const item of items){
    if(item.type==="pet"&&item.deployed===true){
      if(item.name!==activePetName){
        console.log("  取消deployed: "+item.name);
        item.deployed=false;
        fixedPets++;
      }
    }
  }
  gd.items=items;
  
  // 保存
  await pool.query("UPDATE players SET game_data=$1 WHERE wallet=$2",[JSON.stringify(gd),wallet]);
  console.log("Done! 焰晶同步+"+expired.length+"个过期buff清理+"+fixedPets+"个宠物deployed修复");
  await pool.end();
})();
