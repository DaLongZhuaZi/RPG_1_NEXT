import router from '@ohos.router';
import { GameArea } from './GameArea';
import { BottomBar } from './BottomBar';




@Entry
@Component
struct Index {
build() {
     Column() {
       Stack({ alignContent: Alignment.TopStart }) {
         GameArea()
           .width('100%')
           .height('90%')
       }
       BottomBar()
         .width('100%')
         .height('10%')
     }
     .width('100%')
     .height('100%')
   }
 }

