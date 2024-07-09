import { updateCharacterData, playerData, PlayerData  } from '../../global/globalState';
import { ItemData } from '../../global/globalState';

interface Position {
  x: number;
  y: number;
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
  live: boolean;
  monstersKilled: number; // 击杀怪物数量
  goldCollected: number; // 收集金币数量
}

interface BagItemData {
  name: string; // 道具名称
  description: string; // 道具描述
  type: 'consumable' | 'equipment' | 'keyItem'; // 道具类型
  effect: (player: PlayerData) => void; // 道具效果函数
  icon: string;
  quantity: number;
}


@Entry
@Component
struct Bag {
  @State items: BagItemData[] = playerData.inventory;


  useItem(itemIndex: number) {
    const item = this.items[itemIndex];
    if (item) {
      item.effect(playerData);
      this.items.splice(itemIndex, 1);
      updateCharacterData({ inventory: this.items });
    }
  }

  build() {
    Column() {
      Text('背包').fontSize(30).fontWeight(FontWeight.Bold).margin({ top: 10 })
      List({ space: 10 }) {
        ForEach(this.items, (item: BagItemData, index: number) => {
          ListItem() {
            Row() {
              Image($r(item.icon)).width(75).height(75).margin({ right: 10 })
              Column() {
                Text(item.name).fontSize(22)
                Text(`描述: ${item.description}`).fontSize(18)
                Text(`数量: ${item.quantity}`).fontSize(18)
              }
              Button('使用')
                .onClick(() => {
                  this.useItem(index);
                })
            }
          }
        })
      }.margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
