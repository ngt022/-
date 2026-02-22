-- CI test seed: create test player for regression tests
INSERT INTO players (id, wallet, name, level, realm, game_data, spirit_stones, combat_power, vip_level, total_recharge, first_recharge, state_version)
VALUES (
  13,
  '0xbot0000000000000000000000000000000000e5',
  'TestBot',
  10,
  '铸炉一重',
  '{"level":10,"realm":"铸炉一重","spirit":1000,"cultivation":0,"maxCultivation":1000,"spiritStones":50000,"spiritRate":1.5,"baseAttributes":{"attack":100,"health":1000,"defense":50,"speed":30},"combatAttributes":{"critRate":0.1,"comboRate":0.05,"counterRate":0.03,"dodgeRate":0.05,"vampireRate":0.02,"stunRate":0},"specialAttributes":{"healBoost":0,"critDamageBoost":0.1,"critDamageReduce":0,"finalDamageBoost":0.05,"finalDamageReduce":0.03,"combatBoost":0.02,"resistanceBoost":0},"combatResistance":{"counterResist":0,"stunResist":0,"dodgeResist":0,"vampireResist":0},"items":[{"id":"test-weapon-1","type":"weapon","name":"测试焰杖","quality":"rare","stats":{"attack":25,"critRate":0.02,"critDamageBoost":0.03},"level":10}],"equippedArtifacts":{},"pets":[],"herbs":[],"pillRecipes":[],"pillFragments":{},"buffs":{},"reinforceStones":10,"refinementStones":5,"petEssence":0,"storageExpand":{},"autoSellQualities":[],"autoReleaseRarities":[],"unlockedRealms":["燃火一重"],"breakthroughCount":9,"isNewPlayer":false}',
  50000,
  500,
  0,
  0,
  false,
  1
)
ON CONFLICT (id) DO NOTHING;
