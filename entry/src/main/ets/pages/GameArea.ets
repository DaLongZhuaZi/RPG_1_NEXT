import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';


interface Position {
  x: number;
y: number;
}

// 定义敌人的数据类型
interface EnemyDataType {
  avatar: string;
  name: string;
}

// 定义宝箱奖励的数据类型
interface RewardData {
  type: 'gold' | 'weapon' | 'keyItem';
  amount?: number; // 对于金币，表示获得的金币数量
  name?: string; // 对于武器和任务道具，表示名称
  description?: string; // 对于武器和任务道具，表示描述
}

interface CharacterData {
  type: 'player' | 'enemy' | 'npc' | 'treasure'; // 角色类型
name: string; // 角色名称
level: number; // 角色等级
class: string; // 角色职业
hp: number; // 当前生命值
maxHp: number; // 最大生命值
mp: number; // 当前魔法值
maxMp: number; // 最大魔法值
strength: number; // 力量属性
dexterity: number; // 敏捷属性
intelligence: number; // 智力属性
avatar: string; // 角色头像资源路径
position: Position; // 角色当前位置
direction: 'up' | 'down' | 'left' | 'right' | null; // 角色移动方向，null 表示静止
collisionRadius: number; // 角色碰撞半径
  exp: number; // 当前经验值
  nextLevelExp: number; //升级所需的经验值
  inventory: ItemData[]; // 角色的背包
}

interface ItemData {
  name: string; // 道具名称
  description: string; // 道具描述
  type: 'consumable' | 'equipment' | 'keyItem'; // 道具类型
  effect: (character: CharacterData) => void; // 道具效果函数
}

@Component
export struct GameArea {

  @State enemyAndTreasureNames: Map<number, string> = new Map(); // 用于存储敌人和宝箱的名字
  @State battleReportAboveEnemy: Map<CharacterData, string> = new Map(); // 用于存储要显示在敌人头上的战斗报告

  @State isPlayerMoving: boolean = false; // 玩家是否正在移动
  @State battleReportAbovePlayer: string = ''; // 玩家头顶的战斗报告
  @State isPlayerStopped: boolean = true; // 玩家是否停止移动
  @State playerScaleX: number = 1; // 玩家图片的 X 轴缩放比例
  @State actionStart: boolean = false; // 事件开始标识
  @State actionEnd: boolean = true; // 事件结束标识

  @State gameAreaWidth: number = 400; // 设置游戏区域的宽度
  @State gameAreaHeight: number = 600; // 设置游戏区域的高度

  @State joystickX: number = 0; // joystick 的 x 坐标（不受限制）
  @State joystickY: number = 0; // joystick 的 y 坐标（不受限制）
  @State offsetX: number = 0; // joystick 指示器的 x 偏移量（受限制）
  @State offsetY: number = 0; // joystick 指示器的 y 偏移量（受限制）
  @State isDragging: boolean = false; // 是否正在拖动指示器
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });

  @State numEnemy: number =0;
  @State numTreasure: number = 0;
  @State numNpc: number = 0;


  @State dialogMessage: string = '';
  @State npcDialogMessage: string = '';
  @State showMoveDialog: boolean = false;
  // 显示弹窗的函数
  showDialog() {
    if (this.dialogMessage !== '') {
      try {
        promptAction.showDialog({
          title: '事件',
          message: this.dialogMessage,
          buttons: []
        });
      } catch (error) {
        let message = (error as BusinessError).message;
        let code = (error as BusinessError).code;
        console.error(`showDialog args error code is ${code}, message is ${message}`);
      }
    }
  }

  @State someStateVariable: number = 0;
  private updateState: () => void = () => {};

  constructor() {
    super();
    this.updateState = () => {
      this.someStateVariable++; // 修改 someStateVariable 的值，触发重新渲染

    }; // 初始化 updateState 变量
  }

  onInit() {
    // 在组件加载时生成敌人和宝箱
    this.generateRandomEntities();
  }



  //初始化角色、物品属性
  @State characters: CharacterData []= [
    {
    // ... 角色数据 ...
    position: { x: 180, y: 100 } ,
    name: '',
    level: 0,
    class: '',
    hp: 50,
    maxHp: 100,
    mp: 5,
    maxMp: 5,
    strength: 80,
    dexterity: 5,
    intelligence: 3,
    avatar: '',
    direction: null,
    collisionRadius: 25,
      type: 'player',
      exp: 0,
      nextLevelExp: 100,
      inventory: []
  },];

  // 随机生成敌人和宝箱的方法
  generateRandomEntities() {


    // 创建一个临时数组来存储正在生成的敌人和宝箱
    const newCharacters: CharacterData[] = [];

    // 计算剩余可生成的敌人数量
    const remainingEnemies = 7 - this.numEnemy;
    // 随机生成 0 到 3 个敌人，但不超过剩余可生成的敌人数量
    const numEnemiesToGenerate = Math.min(Math.floor(Math.random() * 4), remainingEnemies);
    for (let i= 0; i < numEnemiesToGenerate; i++) {
      let enemy: CharacterData;
      let isOverlapping: boolean;
      do {
        // 随机选择敌人图片和名字
        const enemyData: EnemyDataType[] = [
          { avatar: 'app.media.samurai', name: '剑客' },
          { avatar: 'app.media.gunnery', name: '枪手' },
          { avatar: 'app.media.magician', name: '法师' }
        ];
        const randomIndex = Math.floor(Math.random() * enemyData.length);
        const randomData = enemyData[randomIndex];

        enemy = {
          type: 'enemy',
          name: randomData.name + ' ' + (this.numEnemy + 1), // 使用随机选择的名字
          level: Math.floor(Math.random() * 5) + 1,
          class: '',
          hp: 50 + Math.floor(Math.random() * 50), // 基础生命值 50，随机增加 0-49
          maxHp: 100 + Math.floor(Math.random() * 50), // 基础最大生命值 100，随机增加 0-49
          mp: 0,
          maxMp: 0,
          strength: 20 + Math.floor(Math.random() * 20), // 基础力量 20，随机增加 0-19
          dexterity: 5 + Math.floor(Math.random() * 5), // 基础敏捷 5，随机增加 0-5
          intelligence: 3 + Math.floor(Math.random() * 5), // 基础智力 3，随机增加 0-5
          avatar: randomData.avatar, // 使用随机选择的图片
          position: {
            x: Math.floor(Math.random() * (this.gameAreaWidth - 75)),
            y: Math.floor(Math.random() * (this.gameAreaHeight - 75))
          },
          direction: null,
          collisionRadius: 25,
          exp:0, // 初始经验值
          nextLevelExp: 100, // 升级所需经验值
          inventory: [] // 初始空背包
        };

        // 检查新生成的敌人是否与现有角色或正在生成的敌人和宝箱重叠
        isOverlapping = this.isCharacterOverlapping(enemy, [...this.characters, ...newCharacters]);
      } while (isOverlapping); // 如果重叠，则重新生成位置

      newCharacters.push(enemy); // 将敌人添加到临时数组
      this.numEnemy++;

      // ... 显示弹窗的代码 ...
    }

    // 计算剩余可生成的宝箱数量
    const remainingTreasures = 4 - this.numTreasure;
    // 随机生成 0 到 3 个宝箱，但不超过剩余可生成的宝箱数量
    const numTreasuresToGenerate = Math.min(Math.floor(Math.random() * 4), remainingTreasures);
    for (let i = 0; i < numTreasuresToGenerate; i++) {
      let treasure: CharacterData;
      let isOverlapping: boolean;
      do {
        treasure = {
          type: 'treasure',
          name: '宝箱 ' + (this.numTreasure + 1),
          level: 0,
          class: '',
          hp: 0,
          maxHp: 0,
          mp: 0,
          maxMp: 0,
          strength: 0,
          dexterity: 0,
          intelligence: 0,
          avatar: 'app.media.chest',
          position: {
            x: Math.floor(Math.random() * (this.gameAreaWidth - 75)),
            y: Math.floor(Math.random() * (this.gameAreaHeight - 75))
          },
          direction: null,
          collisionRadius: 25,
          exp:0, // 初始经验值
          nextLevelExp: 100, // 升级所需经验值
          inventory: [] // 初始空背包
        };

        //检查新生成的宝箱是否与现有角色或正在生成的敌人和宝箱重叠
        isOverlapping = this.isCharacterOverlapping(treasure, [...this.characters, ...newCharacters]);
      } while (isOverlapping); // 如果重叠，则重新生成位置

      newCharacters.push(treasure); // 将宝箱添加到临时数组
      this.numTreasure++;

      // ... 显示弹窗的代码 ...
    }

    // 将新生成的敌人和宝箱添加到 characters 数组
    this.characters.push(...newCharacters);

    this.updateState(); // 更新状态以重新渲染界面
  }

  // 修改 isCharacterOverlapping 函数，使其接受一个额外的数组作为参数
  isCharacterOverlapping(newCharacter: CharacterData, allCharacters: CharacterData[]): boolean {
    for (const existingCharacter of allCharacters) {
      const distance = Math.sqrt(
        Math.pow(newCharacter.position.x - existingCharacter.position.x, 2) +
        Math.pow(newCharacter.position.y - existingCharacter.position.y, 2)
      );

      if (distance < newCharacter.collisionRadius * 3) { // 这里使用 3 作为倍数，以确保角色之间有足够的间距
        return true; // 重叠
      }
    }

    return false; // 不重叠
  }



  @State isMoving: boolean = false; // 是否正在移动

  // 处理触摸事件


  // 更新角色位置
  updateCharacterPosition() {
    // 计算角色的移动速度
    const speed = 5; // 可以根据需要调整

    // 计算角色的移动方向
    const angle = Math.atan2(this.joystickY, this.joystickX);

    // 计算角色在 x 和 y 方向上的移动距离
    const dx = speed * Math.cos(angle);
    const dy = speed * Math.sin(angle);

    // 更新角色的位置
    this.characters[0].position.x += dx;
    this.characters[0].position.y += dy;

    // 处理边界碰撞
    const gameAreaWidth = 200;
    const gameAreaHeight = 600;
    const characterWidth = 50;
    const characterHeight = 50;

    if (this.characters[0].position.x < 0) {
      this.characters[0].position.x = 0;
    } else if (this.characters[0].position.x + characterWidth > gameAreaWidth) {
      this.characters[0].position.x = gameAreaWidth - characterWidth;
    }

    if (this.characters[0].position.y < 0) {
      this.characters[0].position.y = 0;
    } else if (this.characters[0].position.y + characterHeight > gameAreaHeight) {
      this.characters[0].position.y = gameAreaHeight - characterHeight;
    }

    this.isPlayerMoving = true; // 设置玩家正在移动
    this.isPlayerStopped = false; // 设置玩家没有停止移动
    // 在移动结束后重置 isPlayerMoving 和 isPlayerStopped，并调整玩家图片的朝向
    // 在移动结束后重置 isPlayerMoving 和 isPlayerStopped，并调整玩家图片的朝向
    setTimeout(() => {
      this.isPlayerMoving = false;
      this.isPlayerStopped = true;
      if (this.actionEnd) { // 在事件结束后检测碰撞
        this.checkCollisions();
      }


      // 如果玩家停止移动且 joystickX 小于 0，则翻转玩家图片
      if (this.isPlayerStopped && this.joystickX < 0) {this.playerScaleX = -1;
      } else {
        this.playerScaleX = 1;
      }
    }, 16); // 16 毫秒相当于 60 帧每秒


    if (this.shouldStartBattle && this.battleTarget) {
      // 开始战斗
      this.startBattle(this.battleTarget);
      this.shouldStartBattle = false;
      this.battleTarget = null;
    }

      // 显示弹窗，判断角色是否移动以及画面刷新是否生效
      this.showMoveDialog = true; // 显示移动弹窗
      //this.showDialog();
      //this.dialogMessage = `角色正在向 ${direction} 移动，新位置为 (${this.characters[0].position.x}, ${this.characters[0].position.y})`;


      this.updateState(); // 触发重新渲染

      this.checkCollisions(); // 检测碰撞

      //this.showCharacterPositions(); // 显示所有角色的信息

      this.generateRandomEntities(); // 刷新敌人和宝箱

  }


  @State shouldStartBattle: boolean = false; // 是否应该开始战斗
  @State battleTarget: CharacterData | null = null; // 战斗目标
  @State currentBattleEnemy: CharacterData | null = null; // 当前战斗的敌人

  // 判断玩家是否面向敌人
  isPlayerFacingEnemy(enemy: CharacterData): boolean {
    const playerX = this.characters[0].position.x;
    const enemyX = enemy.position.x;

    return playerX < enemyX;
  }

   // 检测角色之间的碰撞
   checkCollisions() {

     if (!this.isPlayerStopped || !this.actionEnd) {
       // 玩家没有停止移动或事件未结束，不检测碰撞
       return;
     }


     // 遍历所有角色（包括玩家）
     for (let i = 0; i < this.characters.length; i++) {
       for (let j = i + 1; j < this.characters.length; j++) {
         const character1 = this.characters[i];
         const character2 = this.characters[j];

         // 计算角色之间的距离
         const distance = Math.sqrt(
           Math.pow(character1.position.x - character2.position.x, 2) +
           Math.pow(character1.position.y - character2.position.y, 2)
         );

         // 如果距离小于两个角色的碰撞半径之和，则触发碰撞事件
         if (distance < character1.collisionRadius + character2.collisionRadius) {
           this.handleCollision(character1, character2);
         }
       }
     }
   }

  // 处理碰撞事件
  handleCollision(character1: CharacterData, character2: CharacterData) {
    if (character1 === this.characters[0]) { // 确保是玩家触发了碰撞
      this.showMoveDialog = false; // 不显示移动弹窗
      try{
        if (character2.type === 'enemy') {
          // 玩家与敌人发生碰撞，设置战斗标志
          this.shouldStartBattle = true;
          this.battleTarget = character2;
        } else if (character2.type === 'npc') {
          // 玩家与 NPC 发生碰撞，触发对话
          this.npcDialogMessage = `${character2.name}：欢迎来到冒险世界！`; // 存储对话内容
          this.showDialog();
        } else if (character2.type === 'treasure') {
          // 玩家与宝箱发生碰撞，触发开宝箱事件
          const reward = this.generateRandomReward();
          this.handleReward(reward); // 直接调用 handleReward 函数

          // 从 characters 数组中删除宝箱
          const index = this.characters.indexOf(character2);
          if (index > -1) {
            this.characters.splice(index, 1);
            this.numTreasure--;
          }
        }
      } catch (error) {
        let message = (error as BusinessError).message;
        let code = (error as BusinessError).code;
        console.error(`showDialog args error code is ${code}, message is ${message}`);
      }
    }
  }

  // 计算伤害
  calculateDamage(attacker: CharacterData, defender: CharacterData): number {
    let damage = attacker.strength;if (attacker === this.characters[0] && attacker.mp > 0) { // 只有玩家会消耗 MP
      damage += attacker.intelligence * attacker.mp;
      attacker.mp -= Math.floor(attacker.maxMp / 5); // 消耗 1/5 的 MP
    }
    return damage;
  }

  // 计算防御
  calculateDefense(defender: CharacterData): number {
    return defender.intelligence * defender.dexterity; // 防御值只由智力和敏捷组成
  }
  // 计算闪避率
  calculateDodgeRate(attacker: CharacterData, defender: CharacterData): number {
    return Math.min(0.2, (attacker.intelligence * attacker.dexterity) / (defender.strength * 3)); // 最大闪避率为 0.2，并降低 5 倍
  }


  // 开始战斗
  startBattle(enemy: CharacterData) {

    // 检查玩家的 HP 是否为 0
    if (this.characters[0].hp <= 0) {
      this.dialogMessage = '你已经死亡，无法战斗！';
      this.showDialog();
      this.actionStart = false;
      this.actionEnd = true;
      return;
    }

    if (this.currentBattleEnemy === enemy) {
      // 已经在与这个敌人战斗，不开始新的战斗
      return;
    }

    if (this.actionStart) {
      // 已经在事件中，不开始新的战斗
      return;
    }

    this.currentBattleEnemy = enemy;
    // 战斗开始时重置标识符
    this.actionStart = true;
    this.actionEnd = false;




    // 计算伤害、防御和闪避率
    const playerDamage = this.calculateDamage(this.characters[0], enemy);
    const enemyDamage = this.calculateDamage(enemy, this.characters[0]);
    const playerDefense = this.calculateDefense(this.characters[0]);
    const enemyDefense = this.calculateDefense(enemy);
    const playerDodgeRate = this.calculateDodgeRate(this.characters[0], enemy);
    const enemyDodgeRate = this.calculateDodgeRate(enemy, this.characters[0]);

    // 构建战斗报告
    let battleReport = '';
    // 将战斗报告存储在 battleReportAbovePlayer 中
    this.battleReportAbovePlayer = battleReport;

    // 玩家攻击
    if (Math.random() < enemyDodgeRate) {
      battleReport += `闪避\n`;
    } else {
      const actualPlayerDamage = Math.max(0, playerDamage - enemyDefense);
      enemy.hp -= actualPlayerDamage;
      battleReport += `${enemy.name}受伤${actualPlayerDamage} 点`;
    }

    // 检查敌人是否死亡
    if (enemy.hp <= 0) {
      battleReport += `${enemy.name} 死亡！`;
      this.handleEnemyDeath(enemy); // 处理敌人死亡
      this.battleReportAbovePlayer = battleReport; // 更新战斗报告
      this.actionStart = false;
      this.actionEnd = true;
      return; // 终止战斗
    }

    // 敌人攻击
    if (Math.random() < playerDodgeRate) {
      battleReport += `闪避\n`;
    } else {
      const actualEnemyDamage = Math.max(0, enemyDamage - playerDefense);
      this.characters[0].hp -= actualEnemyDamage;
      battleReport += `${enemy.name}受伤${actualEnemyDamage}点`;
    }

    // 检查玩家是否死亡
    if (this.characters[0].hp <= 0) {
      battleReport += `你死亡了！`;
      this.handlePlayerDeath(); // 处理玩家死亡
      this.battleReportAbovePlayer = battleReport; // 更新战斗报告
      this.actionStart = false;
      this.actionEnd = true;
      return; // 终止战斗
    }

    // 将战斗报告存储在 battleReportAboveEnemy 中
    this.battleReportAboveEnemy.set(enemy, battleReport); // 在每次战斗时更新战斗报告

    // 战斗结束后重置标识符
    this.actionStart = false;
    this.actionEnd = true;

    this.updateState(); // 触发重新渲染
  }

  // 处理敌人死亡
  handleEnemyDeath(enemy: CharacterData) {

    // 奖励经验值和道具
    const expGain = 0; // 可以根据敌人等级调整
    const itemGain = this.getRandomItem();

    this.characters[0].exp += expGain;
    this.characters[0].inventory.push(itemGain);

    // 从 characters 数组中删除敌人
    const index = this.characters.indexOf(enemy);
    if (index > -1) {
      this.characters.splice(index, 1);
      this.numEnemy--;
      this.enemyAndTreasureNames.delete(index); // 从 enemyAndTreasureNames 中删除敌人的名字
    }

    // 检查是否升级
    this.checkLevelUp();

    this.updateState(); // 触发重新渲染
  }

  // 处理玩家死亡
  handlePlayerDeath() {
    // 游戏结束
    this.dialogMessage = '你失败了！';
    this.showDialog();

    //this.updateState(); // 触发重新渲染
  }

  // 获取随机道具
  getRandomItem(): ItemData {
    // 这里可以实现更复杂的道具掉落逻辑
    const items: ItemData[] = [
      {
        name: '生命药水',
        description: '恢复 50 点生命值',
        type: 'consumable',
        effect: (character: CharacterData) => {
          character.hp = Math.min(character.hp + 50, character.maxHp);
        }
      },
    // 添加更多道具...
    ];
    const randomIndex = Math.floor(Math.random() * items.length);
    return items[randomIndex];
  }

  // 检查是否升级
  checkLevelUp() {
    if (this.characters[0].exp >= this.characters[0].nextLevelExp) {
      // 升级
      this.characters[0].level++;
      this.characters[0].exp = 0;
      this.characters[0].nextLevelExp *= 1.5; // 升级所需经验值增加

      // 提醒玩家前往人物页面增加属性点
      this.dialogMessage = '你升级了！请前往人物页面增加属性点';
      this.showDialog();
    }
    this.updateState(); // 触发重新渲染
  }

  // 生成随机奖励
  generateRandomReward(): RewardData {
  const rewardTypes = ['gold', 'weapon', 'keyItem'];
  const randomType = rewardTypes[Math.floor(Math.random() * rewardTypes.length)];

  switch (randomType) {
     case 'gold':
       return {
         type: 'gold',
         amount: Math.floor(Math.random() * 100) + 1 // 随机获得 1-100 金币
       };
  case 'weapon':
  return {
  type: 'weapon',
  name: '神秘之剑', // 替换为你实际的武器名称
  description: '一把散发着神秘气息的剑' // 替换为你实际的武器描述
};
case 'keyItem':
return {
  type: 'keyItem',
  name: '古老的钥匙', // 替换为你实际的任务道具名称
  description: '一把看起来非常古老的钥匙' // 替换为你实际的任务道具描述
};
default:
  return { type: 'gold', amount: 0 };
}

}

  // 处理宝箱奖励
  handleReward(reward: RewardData) {
    if (this.actionStart) {
      // 已经在事件中，不处理新的奖励事件
      return;
    }

    this.actionStart = true;
    this.actionEnd = false;

    switch (reward.type) {
      case 'gold':
      // 将金币添加到玩家背包（或直接增加玩家的金币数量）
        this.dialogMessage = `你获得了 ${reward.amount} 金币！`;
        break;
      case 'weapon':
      // 将武器添加到玩家背包
        this.characters[0].inventory.push({
          name: reward.name!,
          description: reward.description!,
          type: 'equipment',
          effect: (character: CharacterData) => {
            // 实现武器的效果
          }
        });
        this.dialogMessage = `你获得了 ${reward.name}！`;
        break;
      case 'keyItem':
      // 将任务道具添加到玩家背包
        this.characters[0].inventory.push({
          name: reward.name!,
          description: reward.description!,
          type: 'keyItem',
          effect: (character: CharacterData) => {
            // 实现任务道具的效果
          }
        });
        this.dialogMessage = `你获得了 ${reward.name}！`;
        break;
    }

    this.showDialog();
    this.actionStart = false;
    this.actionEnd = true;

    this.updateState(); // 触发重新渲染
  }

  // 背包弹窗
  showInventoryDialog() {
    let message = '你的背包：\n';
    const itemCounts = new Map<string, number>();

    // 统计每种物品的数量
    this.characters[0].inventory.forEach((item) => {
      if (itemCounts.has(item.name)) {
        itemCounts.set(item.name, itemCounts.get(item.name)! + 1);
      } else {
        itemCounts.set(item.name, 1);
      }
    });

    // 显示物品数量
    if (itemCounts.size === 0) {
      message += '空空如也！';
    } else {
      itemCounts.forEach((count, itemName) => {
        message += `${itemName} x${count}\n`;
      });
    }

    try {
      promptAction.showDialog({
        title: '背包',
        message: message,
        buttons: []
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`showDialog args error code is ${code}, message is ${message}`);
    }

  }
  // 调试功能：显示所有角色的所有信息
  showCharacterPositions() {
    let message = '';
    this.characters.forEach((character, index) => {
      message += `角色${index + 1} (${character.type}):\n`;
      message += `  名称: ${character.name}\n`;
      message += `  等级: ${character.level}\n`;
      message += `  职业: ${character.class}\n`;
      message += `  生命值: ${character.hp}/${character.maxHp}\n`;
      message += `  魔法值: ${character.mp}/${character.maxMp}\n`;
      message += `  力量: ${character.strength}\n`;
      message += `  敏捷: ${character.dexterity}\n`;
      message += `  智力: ${character.intelligence}\n`;
      message += `  位置: (${character.position.x}, ${character.position.y})\n`;
      message += `  碰撞半径: ${character.collisionRadius}\n\n`;
    });

    try {
      promptAction.showDialog({
        title: '角色信息',
        message: message,
        buttons: []
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`showDialog args error code is ${code}, message is ${message}`);
    }
  }



  build() {
    Stack() {

      // 显示 NPC 对话内容
      if (this.npcDialogMessage !== '') {
        Text(this.npcDialogMessage)
          .fontSize(16)
          .fontColor(Color.White)
          .width('100%')
          .textAlign(TextAlign.Center)
          .position({ x:0, y: 200 }) // 调整位置使其显示在屏幕中央
      }

      // 地面网格
      Grid() {
        ForEach(new Array(Math.ceil(this.gameAreaWidth / 71) + 2).fill(0), (item: void, columnIndex: number) => { // 增加 2 列缓冲区
          GridItem() {
            Column() {
              ForEach(new Array(Math.ceil(this.gameAreaHeight / 71) + 2).fill(0), (item: void, rowIndex: number) => { // 增加 2 行缓冲区
                //随机选择草地或石头素材
                if (Math.random() < 0.5) {
                  Image($r('app.media.grass'))
                    .width(71)
                    .height(71)
                } else {
                  Image($r('app.media.stone_l'))
                    .width(71)
                    .height(71)
                }
              })
            }
          }
        })
      }
      .width('100%')
      .height('100%')

      // 角色
      Image($r('app.media.knight'))
        .width(50)
        .height(50)
        .position({ x: this.characters[0].position.x, y: this.characters[0].position.y })
          // 添加 key 属性，确保在状态更新时重新创建 Image 组件
        .key(this.updateState.toString())
          // 添加条件判断，如果 joystick 在左侧，则翻转图片
        .scale({ x: this.playerScaleX, y: 1 }) // 直接修改 scale 属性


      // NPC
      ForEach(this.characters, (item: CharacterData, index: number) => {
        if (item.type === 'npc') {
          Image($r(item.avatar))
            .width(50)
            .height(50)
            .position({ x: item.position.x, y: item.position.y })
            .key(index.toString())
        }
      }, (item: CharacterData) => JSON.stringify(item))

      // 敌人和宝箱
      ForEach(this.characters, (item: CharacterData, index: number) => {
        if (item.type === 'enemy' || item.type === 'treasure') {
          Stack() {
            Image($r(item.avatar))
              .width(50)
              .height(50)
                // 移除 position 属性，直接使用 item.position.x 和 item.position.y
              .key(index.toString())
                // 敌人图片朝向玩家
              .scale({
                x: item.type === 'enemy' && this.isPlayerFacingEnemy(item) ? -1 : 1,
                y: 1
              })
            // 显示敌人和宝箱的名字
            Text(this.enemyAndTreasureNames.get(index) || '')
              .fontSize(12)
              .fontColor(Color.Red)
              .position({ x: 0, y: -20 })
            // 显示战斗报告
            if (this.battleReportAboveEnemy.has(item)) {
              Text(this.battleReportAboveEnemy.get(item) || '')
                .fontSize(14)
                .fontColor(Color.Red)
                .backgroundColor(Color.Gray)
                .position({
                  x: item.position.x + 10, // 根据敌人的位置调整 x 坐标
                  y: item.position.y - 50 // 根据敌人的位置调整 y 坐标
                })
            }
          }
          .width(50)
          .height(70)
          // 在 ForEach 循环中设置图片的位置
          .position({ x: item.position.x, y: item.position.y })
          .key(index.toString())
          .onAppear(() => {
            // 在敌人和宝箱出现时，将其名字存储在 enemyAndTreasureNames 中
            this.enemyAndTreasureNames.set(index, item.name);
          })
        }
      }, (item: CharacterData) => JSON.stringify(item))




      // UI 元素
      Column() {
        Text('角色状态')
          .fontSize(25)
          .margin({ top: 10, left: 10 })
          .fontColor(Color.Red)

        // 玩家等级和经验条
        Row() {
          Text(`等级: ${this.characters[0].level}`)
            .fontSize(18)
            .fontColor(Color.Red)
          Progress({ value: this.characters[0].exp / this.characters[0].nextLevelExp })
            .width(100)
            .height(10)
            .margin({ left: 10 }) // 添加左边距
          Text(`${this.characters[0].exp}/${this.characters[0].nextLevelExp}`)
            .fontSize(18)
            .fontColor(Color.Red)
            .margin({ left: 10 }) // 添加左边距
        }.margin({ top: 5, left: 10, right: 10 })

        // 血条和蓝条
        Row() {
          // 血条
          Row() {
            Text('HP: ')
              .fontSize(18)
              .fontColor(Color.Red)
            Shape()
            .width((this.characters[0].hp / this.characters[0].maxHp) * 100)
            .height(10)
            .borderRadius(5)
              .backgroundColor(Color.Red)
              .key(`hpBar-${this.characters[0].hp}`) // 添加 key 属性
            }
          .margin({ right: 50 })

          // 蓝条
          Row() {
            Text('MP: ')
              .fontSize(18)
              .fontColor(Color.Blue)
            Shape()
            .width((this.characters[0].mp / this.characters[0].maxMp) * 100)
            .height(10)
            .borderRadius(5)
            .backgroundColor(Color.Blue)
              .key(`mpBar-${this.characters[0].mp}`) // 添加 key 属性
            }
          .margin({ left: 10 })
        }.margin({ top: 5, left: 10, right: 10 }) // 添加 margin 以保持间距
        .width('100%')
        .align(Alignment.TopStart)

        // 玩家操作区域
        Column() {
          Row() {
            Column() {
              Blank() //占据 0% - 60% 的空间
                .height('70%')

              // 轮盘移动按钮
              Stack() {
                // 圆形区域
                Circle()
                  .width(150)
                  .height(150)
                  .backgroundColor(Color.Transparent)
                  .opacity(0.5)

                // 指示器
                Image($r('app.media.joystick'))
                  .width(50)
                  .height(50)
                  .position({ x: this.joystickX, y: this.joystickY })
                  .gesture(
                    PanGesture(this.panOption)
                      .onActionStart((event: GestureEvent) => {
                        console.info('Pan start');
                        this.isDragging = true;
                      })
                      .onActionUpdate((event: GestureEvent) => {
                        // 计算指示器的新位置
                        let newOffsetX = event.offsetX;
                        let newOffsetY = event.offsetY;

                        // 限制指示器的移动范围
                        const maxDistance = 75; // 指示器可以移动的最大距离
                        const distance = Math.min(Math.sqrt(newOffsetX * newOffsetX + newOffsetY * newOffsetY), maxDistance);
                        const angle = Math.atan2(newOffsetY, newOffsetX);
                        newOffsetX = distance * Math.cos(angle);
                        newOffsetY = distance * Math.sin(angle);

                        // 更新指示器的位置
                        this.joystickX = newOffsetX; // 直接设置偏移量
                        this.joystickY = newOffsetY; // 直接设置偏移量


                        // 更新角色位置
                        this.updateCharacterPosition(); // 每次 joystick 位置变化时都调用

                    })
                      .onActionEnd((event: GestureEvent) => {
                        console.info('Pan end');
                        this.isDragging = false;

                        // 使用动画效果将指示器移动回中心位置
                        animateTo({ duration: 200 }, () => {
                          this.joystickX = 0;
                          this.joystickY = 0;
                        });

                      })
                  )
              }
              .position({ x: 25, y: 425 }) // 设置轮盘中心的坐标
              .height('20%') // 移动按钮区域占据 20% 的屏幕高度
              .padding({ top: 10, bottom: 10, left: 10, right: 10 }) // 添加内边距

              Blank() // 占据 90% - 100% 的空间
                .height('10%')
            }
            .width('50%')


            // 背包按钮
            Stack({ alignContent: Alignment.Center }) {
              Column() {
                Button() {
                  Image($r('app.media.backpack'))
                    .width(80)
                    .height(80)
                    .backgroundColor(Color.Transparent)
                }
                .onClick(() => {
                  // 显示背包弹窗
                  this.showInventoryDialog();
                  this.updateState(); // 手动触发重新渲染
                })
              }
            }
            .width('70%')
            .height('70%')
            .align(Alignment.Bottom)


          }
          .width('100%')
          .height('100%') // 设置玩家操作区域的高度

        }
        .width('100%')

      }
      .width('100%')
      .height('100%')

    }
  }
}