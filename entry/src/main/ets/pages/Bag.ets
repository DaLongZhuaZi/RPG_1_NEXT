

interface ItemData {
    name: string;
icon: string;
description: string;
quantity: number;
// ... 其他属性，如类型、效果等
}

@Entry
@Component
struct Bag {
  // 定义玩家物品数据
  private items: ItemData[] = [
    {
      name: '生命药水',
      icon: 'app.media.potion_red',
      description: '恢复一定生命值',
      quantity: 5
    },
    {
      name: '魔法药水',
      icon: 'app.media.potion_blue',
      description: '恢复一定魔法值',
      quantity: 3
    },
    {
      name: '金币',
      icon: 'app.media.coin',
      description: '游戏中的货币',
      quantity: 100
    },
  // ... 添加更多物品
  ];

  build() {
    Column() {
      Text('背包').fontSize(30).fontWeight(FontWeight.Bold).margin({ top: 10 })
      List({ space: 10 }) {
        ForEach(this.items, (item: ItemData) => {
          ListItem() {
           Row() { // 使用 Row 并设置左右分布
             Row() {
               Image($r(item.icon)).width(75).height(75).margin({ right: 10 })
               Column() {
                 Text(item.name).fontSize(22)
                 Text(`描述: ${item.description}`).fontSize(18)
                 Text(`数量: ${item.quantity}`).fontSize(18)
               }
             }
             Button('使用') // 添加使用按钮
               .onClick(() => {
                 // 在这里处理使用物品的逻辑
                 console.log(`使用 ${item.name}`);
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