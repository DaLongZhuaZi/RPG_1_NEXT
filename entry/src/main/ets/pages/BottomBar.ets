
import router from '@ohos.router';


@Component
struct BottomBar {
build() {
     Row() {
       Button({ type: ButtonType.Normal }) {
         Image($r('app.media.anonymous'))
           .width(40)
           .height(40)
       }
       .onClick(() => {
         // 跳转到角色页面
         router.pushUrl({
           url: 'pages/Character'
         }, router.RouterMode.Standard, (err) => {
           if (err) {
             console.error(`跳转到角色页面失败: ${err.code}, ${err.message}`);
             return;
           }
           console.info('跳转到角色页面成功');
         });
       })
       .width('20%')
       .height('100%')

       Button({ type: ButtonType.Normal }) {
         Image($r('app.media.backpack'))
           .width(40)
           .height(40)
       }
       .onClick(() => {
         // 跳转到背包页面
         router.pushUrl({
           url: 'pages/Bag'
         }, router.RouterMode.Standard, (err) => {
           if (err) {
             console.error(`跳转到背包页面失败: ${err.code}, ${err.message}`);
             return;
           }
           console.info('跳转到背包页面成功');
         });
       })
       .width('20%')
       .height('100%')

       // 添加其他按钮，例如技能、任务、商店、设置等
       Button({ type: ButtonType.Normal }) {
         Image($r('app.media.map'))
           .width(40)
           .height(40)
       }
       .onClick(() => {
         // 跳转到地图页面
         router.pushUrl({
           url: 'pages/Map'
         }, router.RouterMode.Standard, (err) => {
           if (err) {
             console.error(`跳转到地图页面失败: ${err.code}, ${err.message}`);
             return;
           }
           console.info('跳转到地图页面成功');
         });
       })
       .width('20%')
       .height('100%')

       Button({ type: ButtonType.Normal }) {
         Image($r('app.media.quest'))
           .width(40)
           .height(40)
       }
       .onClick(() => {
         // 跳转到任务页面
         router.pushUrl({
           url: 'pages/Quest'
         }, router.RouterMode.Standard, (err) => {
           if (err) {
             console.error(`跳转到任务页面失败: ${err.code}, ${err.message}`);
             return;
           }
           console.info('跳转到任务页面成功');
         });
       })
       .width('20%')
       .height('100%')

       Button({ type: ButtonType.Normal }) {
         Image($r('app.media.wizard'))
           .width(40)
           .height(40)
       }
       .onClick(() => {
         // 跳转到魔法页面
         router.pushUrl({
           url: 'pages/Magic'
         }, router.RouterMode.Standard, (err) => {
           if (err) {
             console.error(`跳转到魔法页面失败: ${err.code}, ${err.message}`);
             return;
           }
           console.info('跳转到魔法页面成功');
         });
       })
       .width('20%')
       .height('100%')
     }
     .width('100%')
     .height('100%')
   }}

export { BottomBar };
