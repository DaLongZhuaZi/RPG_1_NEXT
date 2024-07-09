// globalState.ts

interface Position {
    x: number;
    y: number;
}


interface QuestData {
    name: string; // 任务名称
    description: string; // 任务描述
    type: 'travel' | 'collection'; // 任务类型
    targetLocation?: Position; // 如果是旅行任务，则为目标位置
    targetItems?: string[]; // 如果是收集任务，则为目标物品列表
    reward: ItemData[]; // 完成任务后的奖励
    isCompleted: boolean; // 任务是否已完成
}

export interface ItemData {
    name: string; // 道具名称
    description: string; // 道具描述
    type: 'consumable' | 'equipment' | 'keyItem'; // 道具类型
    effect: (player: PlayerData) => void; // 道具效果函数
    icon: string;
    quantity: number;
}

export interface PlayerData {
    position: { x: number; y: number };
    name: string;
    level: number;
    class: string;
    hp: number;
    maxHp: number;
    mp: number;
    maxMp: number;
    strength: number;
    dexterity: number;
    intelligence: number;
    avatar: string;
    direction: string | null;
    collisionRadius: number;
    type: string;
    exp: number;
    nextLevelExp: number;
    inventory: ItemData[]; // 你可能需要为 inventory 中的项目定义一个更具体的类型
    live: boolean;
    monstersKilled: number; // 击杀怪物数量
    goldCollected: number; // 收集金币数量
    quest: QuestData[];
    activeQuests: QuestData[];
}

export const playerData: PlayerData = {
    position: { x: 180, y: 100 },
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
    avatar: 'app.media.knight',
    direction: null,
    collisionRadius: 25,
    type: 'player',
    exp: 30,
    nextLevelExp: 100,
    inventory: [],
    live: true,
    monstersKilled: 0, // 击杀怪物数量
    goldCollected: 0, // 收集金币数量
    quest: [],
    activeQuests: [],

};

export function updateCharacterData(newData: Record<string, any>) {
    Object.assign(playerData, newData);
}
