@Entry
@Component
export struct MagicPage {
    build() {
    Column() {
      Text('魔法页面')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
  }
}