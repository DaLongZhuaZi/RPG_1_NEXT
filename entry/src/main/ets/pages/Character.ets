

interface CharacterData {
    name: string;
level: number;
class: string;
avatar: string;experience: number;
experienceToNextLevel: number;
strength: number;
dexterity: number;
intelligence: number;
monstersKilled: number;
goldCollected: number;
}

@Entry
@Component
struct CharacterEntry {
  // 定义角色数据，只包含固定信息
  @State characterData: CharacterData = {
    name: '勇者',
    level: 1, // 初始等级
    class: '战士',
    avatar: 'app.media.anonymous',
    experience: 15,
    experienceToNextLevel: 100, // 升级所需的经验值
    strength: 10,
    dexterity: 8,
    intelligence: 6,
    monstersKilled: 0,
    goldCollected: 0
  };

  build() {
    Column() {
      // 角色头像和基本信息
      Row() {
        Image($r(this.characterData.avatar)).width(100).height(100).margin({ right: 20 })
        Column() {
          Text(this.characterData.name).fontSize(20).fontWeight(FontWeight.Bold)
          Text('等级: ' + this.characterData.level).fontSize(16)
          Text('职业: ' + this.characterData.class).fontSize(16)
           // 经验条
 Row() { // 使用 Row 并设置左右分布
   Text(`${this.characterData.experience}/${this.characterData.experienceToNextLevel}`).fontSize(14) // 显示数字条
   Shape()
     .width((this.characterData.experience / this.characterData.experienceToNextLevel) * 100)
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
        Text(`力量: ${this.characterData.strength}`).fontSize(16)
        Text(`敏捷: ${this.characterData.dexterity}`).fontSize(16)
        Text(`智力: ${this.characterData.intelligence}`).fontSize(16)
      }.margin({ bottom: 20 })

      Divider().strokeWidth(1).color(Color.Gray)

      // 击杀记录和金币记录
      Column() {
        Text('记录').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
        Text(`击杀怪物: ${this.characterData.monstersKilled}`).fontSize(16)
        Text(`收集金币: ${this.characterData.goldCollected}`).fontSize(16)
      }.margin({ bottom: 20 })

      // 加点按钮（仅在升级时显示）
      if (this.characterData.experience >= this.characterData.experienceToNextLevel) {
        Column() {
          Text('升级可用！').fontSize(16).fontColor(Color.Green).margin({ bottom: 10 })
          Button('加点').onClick(() => {
            // 在这里处理加点逻辑
            console.log('加点');
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }
}