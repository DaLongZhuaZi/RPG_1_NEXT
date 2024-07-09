import featureAbility from '@ohos.ability.featureAbility';
import { BusinessError } from '@ohos.base';
import { updateCharacterData, playerData, PlayerData } from '../../global/globalState';

interface Position {
  x: number;
  y: number;
}

interface ItemData {
  name: string; // 道具名称
  description: string; // 道具描述
  type: 'consumable' | 'equipment' | 'keyItem'; // 道具类型
  effect: (character: CharacterData) => void; // 道具效果函数
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
}


@Entry
@Component
struct CharacterEntry {
  @State showLevelUpPanel: boolean = false;
  @State availablePoints: number = 0;

  onInit() {
    // 数据同步
    updateCharacterData({});
  }

  build() {
    Column() {
      // 角色头像和基本信息
      Row() {
        Image($r(playerData.avatar)).width(100).height(100).margin({ right: 20 })
        Column() {
          Text(playerData.name).fontSize(20).fontWeight(FontWeight.Bold)
          Text('等级: ' + playerData.level).fontSize(16)
          Text('职业: ' + playerData.class).fontSize(16)
          // 经验条
          Row() {
            Text(`${playerData.exp}/${playerData.nextLevelExp}`).fontSize(14)
            Shape()
              .width((playerData.exp / playerData.nextLevelExp) * 100)
              .height(10)
              .borderRadius(5)
              .backgroundColor(Color.Yellow)
          }.margin({ top: 5 })
        }
      }.margin({ top: 20, bottom: 20 })

      Divider().strokeWidth(1).color(Color.Gray)

      // 角色属性
      Column() {
        Text('属性').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
        Text(`力量:${playerData.strength}`).fontSize(16)
        Text(`敏捷: ${playerData.dexterity}`).fontSize(16)
        Text(`智力: ${playerData.intelligence}`).fontSize(16)
      }.margin({ bottom: 20 })

      Divider().strokeWidth(1).color(Color.Gray)

      // 击杀记录和金币记录
      Column() {
        Text('记录').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
        // 这里你需要根据你的实际数据结构来修改
        Text(`击杀怪物: ${playerData.monstersKilled ?? 0}`).fontSize(16) // 使用可选链操作符
        Text(`收集金币: ${playerData.goldCollected ?? 0}`).fontSize(16)
      }.margin({ bottom: 20 })

      // 加点按钮（仅在升级时显示）
      if (playerData.exp >= playerData.nextLevelExp) {
        Button('升级加点')
          .onClick(() => {
            this.showLevelUpPanel = true;
            this.availablePoints = 5; // 假设每次升级获得 5 点属性点
          })
          .margin({ bottom: 20 })
      }

      // 升级加点面板
      if (this.showLevelUpPanel) {
        Panel(this.showLevelUpPanel) {
          Column() {
            Text('可用属性点: ' + this.availablePoints).fontSize(16).margin({ bottom: 10 })
            Row() {
              Button('+').onClick(() => {
                if (this.availablePoints > 0) {
                  playerData.strength++; // 直接更新 playerData
                  this.availablePoints--;
                  updateCharacterData({ strength: playerData.strength });
                }
              })
              Text('力量: ' + playerData.strength).fontSize(16).margin({ left: 10, right: 10 })
            }

            // 添加其他属性的加点按钮
            // ... (与力量属性的加点按钮类似)
          }.width('100%').padding(20)
        }

        // ...
      }
    }

    // ...}
  }
}