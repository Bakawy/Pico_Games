console.log(window.innerWidth);
console.log(window.innerHeight);
const gameScreen = document.getElementById("gameScreen");
if (window.innerWidth < window.innerHeight) {
    gameScreen.width = window.innerWidth * 0.6
    gameScreen.height = gameScreen.width * 0.75
} else {
    gameScreen.height = window.innerHeight * 0.8
    gameScreen.width = gameScreen.height * (4 / 3)
}
const screenDim = [800, 600];
const ctx = gameScreen.getContext("2d");
ctx.imageSmoothingEnabled = false;
ctx.scale(gameScreen.width / 800, gameScreen.height / 600);
let mouseData = {
    coords : [screenDim[0] / 2, screenDim[1] / 2]
};
const tankBase = new Image(14, 14);
tankBase.src = 'tank base sprite.png';
const tankHead = new Image(17, 8);
tankHead.src = 'tank head sprite.png';
const badTankBase = new Image(14, 14);
badTankBase.src = 'bad tank base sprite.png';
const badTankHead = new Image(17, 8);
badTankHead.src = 'bad tank head sprite.png';
const bulletNorm = new Image(6, 4)
bulletNorm.src = 'bulletNorm.png'
const keyInputs = {};
let frameCount = 0;
let testText = "";
const playerData = {
    coords : [screenDim[0] / 2, screenDim[1] / 2],
    size : 42,
    // width and height of base
    speed : (4 / 7),
    // pixels per frame
    vect : [0, 0],
    // movement vector, (distance, direction)
    dir : -90,
    // degrees where the tank is pointing 
    defdir: -90,
    // default direction, for turning while the tank isnt moving
    forces : [],
    // forces acting on player
    frict : 0.85,
    aim : 0,
    //angle that the head is pointing
    bulletSpeed : 4,
    bulletCount : 0,
    // number of bullets
    maxBulletCount : 70,
    turnSpeed : 4,
};
/*
[100, 100, 500, 50],
[100, 180, 500, 50],
[300, 350, 30, 180],
[300, 500, 150, 30]
*/
let borderWidth = 100;
let doorDim = [150, 10];
let curRoom = [0, 0];
/*
let rooms = [
    [
        { 
            walls : [

            ].concat(addBorder([false, true, false, true])),
            spawn : []
        }, 
        { 
            walls : [

            ].concat(addBorder([false, true, true, true])),
            spawn : []
        }, 
        { 
            walls : [

            ].concat(addBorder([false, true, true, false])),
            spawn : []
        }
    ],

    [
        { 
            walls : [

            ].concat(addBorder([true, true, false, true])),
            spawn : []
        },
        { 
            walls : [

            ].concat(addBorder([true, true, true, true])),
            spawn : [
                [0, [[randfloat(0, screenDim[0]), randfloat(0, screenDim[1])], 4]]
            ]
        }, 
        { 
            walls : [

            ].concat(addBorder([true, true, true, false])),
            spawn : []
        }
    ],

    [
        { 
            walls : [

            ].concat(addBorder([true, false, false, true])),
            spawn : []
        },
        { 
            walls : [

            ].concat(addBorder([true, false, true, true])),
            spawn : []
        }, 
        { 
            walls : [

            ].concat(addBorder([true, false, true, false])),
            spawn : []
        }
    ]
];
*/
let rooms = [];
generateFloor();

let walls;
const controls = {
    up : 'w',
    down : 's',
    left : "a",
    right : "d",
    spawn : "l"
};
let bullets = [];
let enemies = [];
let calcFPS = 0;
let time = performance.now();
let fps = -1;
let fpsTimestamp = 0;
class Bullet {
    constructor (coords, vect, size) {
        bullets.push(this);
        this.coords = coords;
        this.vect = vect;
        this.size = size;
        this.bounce = 0;
        this.self = this;
    }
}

class Enemy {
    constructor (coords, ai) {
        enemies.push(this);
        this.coords = coords;
        this.size = 42;
        this.dir = 0;
        this.self = this;
        this.aim = 0;
        this.ai = ai;
        this.turnSpeed = 8;
        this.aiData = {};
        this.speed = (4 / 7);
        this.vect = [0, 0];
        this.forces = [];
        this.frict = 0.85;
        this.target = "none";
        this.ff = 1
        // if its the enemie's first frame of spawn
        this.targetdir = [Math.atan2(this.target - this.coords[1], this.target - this.coords[0])  * (180 / pi), 0];
        this.bulletCD = [0, 0];
        this.bulletCD[0] = this.bulletCD[1]
        // [current cooldown, max cooldown]
        this.wallTouch = false;
        this.bulletSize = 2;
    }
    changeTarget(target) {
        this.target = target
        /*
        let walcol = 1;
        let squareSize = this.size / (2 ** 0.5);
        let targetRect = [
            this.target[0] - (squareSize / 2),
            this.target[1] - (squareSize / 2),
            squareSize,
            squareSize
        ];
        let loops = 0;
        while (walcol !== 0 && loops < 1000) {
            loops++;
            walcol = 0;
            walls.every((wall) =>{
                if (colRect(targetRect, wall)) {
                    walcol = wall;
                    return false;
                }
                return true;
            });
            if (walcol !== 0) {
                if (this.target[0] <= walcol[0] + (walcol[2] / 2)) {this.target[0]--;} else {this.target[0]++;}
                if (this.target[1] <= walcol[1] + (walcol[3] / 2)) {this.target[1]--;} else {this.target[1]++;}
            }
        }
        if (this.target[0] >= screenDim[0]) {this.target[0] = screenDim[0] - 1;}
        else if (this.target[0] <= 0) {this.target[0] = 1;}
        if (this.target[1] >= screenDim[1]) {this.target[1] = screenDim[1] - 1;}
        else if (this.target[1] <= 0) {this.target[1] = 1;}
        */
    }
    shoot() {
        new Bullet([this.coords[0] + (Math.cos(this.aim) * (12 * (this.size / 14))), this.coords[1] + (Math.sin(this.aim) * (12 * (this.size / 14)))], [4, this.aim], this.bulletSize);
        this.bulletCD[0] = this.bulletCD[1]
    }
}
const pi = Math.PI;
ctx.lineWidth = 2;
let testRects = [];
document.addEventListener ('keydown', (event) => {
    keyHandler(event.key, 1);
});
document.addEventListener ('keyup', (event) => {
    keyHandler(event.key, 0);
});
document.addEventListener ('mousemove', (event) => {
    mouseData.coords = [
        (event.clientX - gameScreen.getBoundingClientRect().left) * (800 / gameScreen.width),
        (event.clientY - gameScreen.getBoundingClientRect().top)  * (600 / gameScreen.height)
    ];
});
document.addEventListener ('click', (event) => {
    
    if (playerData.bulletCount < playerData.maxBulletCount) {
        new Bullet([playerData.coords[0] + (Math.cos(playerData.aim) * (12 * (playerData.size / 14))), playerData.coords[1] + (Math.sin(playerData.aim) * (12 * (playerData.size / 14)))], [playerData.bulletSpeed, playerData.aim], 2);
        playerData.bulletCount++;
    };
    
   /*
    for (let i = 0; i <= playerData.maxBulletCount; i++) {
        let x = randfloat(-30, 30);
        if (playerData.bulletCount < playerData.maxBulletCount) {
            new Bullet([playerData.coords[0] + (Math.cos(playerData.aim) * (12 * (playerData.size / 14))), playerData.coords[1] + (Math.sin(playerData.aim) * (12 * (playerData.size / 14)))], [playerData.bulletSpeed, playerData.aim + (x * (pi / 180))], 2);
            playerData.bulletCount++;
        };
    };
    */
});
window.addEventListener('resize', (event) =>{
    ctx.imageSmoothingEnabled = false;
    ctx.scale(800 / gameScreen.width, 600 / gameScreen.height);
    if (window.innerWidth < window.innerHeight) {
        gameScreen.width = window.innerWidth * 0.6
        gameScreen.height = gameScreen.width * 0.75
    } else {
        gameScreen.height = window.innerHeight * 0.8
        gameScreen.width = gameScreen.height * (4 / 3)
    }
    ctx.imageSmoothingEnabled = false;
    ctx.scale(gameScreen.width / 800, gameScreen.height / 600);
});
function init() {
    loadRoom(curRoom);
    window.requestAnimationFrame(runGame);
}

function runGame () {
    frameCount++;
    calcFPS++;
    time = performance.now();
    if (time - fpsTimestamp >= 1000) {
        fps = calcFPS;
        calcFPS = 0;
        fpsTimestamp = time;
    }
    processInput();
    processAI();
    moveStuff();
    ejectWalls();
    hitStuff();
    handleRooms();
    drawStuff();
    window.requestAnimationFrame(runGame);
}

function processInput () {
    if (checkKey(controls.right) && (!(checkKey(controls.up) || checkKey(controls.down)) && (playerData.dir < playerData.defdir + 30))) {
        playerData.dir += playerData.turnSpeed;
    } else if (!(checkKey(controls.left)) && ((playerData.dir > playerData.defdir ))) {
        playerData.dir -= playerData.turnSpeed;
    } 
    if (checkKey(controls.left) && (!(checkKey(controls.up) || checkKey(controls.down)) && (playerData.dir > playerData.defdir - 30))) {
        playerData.dir -= playerData.turnSpeed;
    } else if (!(checkKey(controls.right)) && ((playerData.dir < playerData.defdir ))) {
        playerData.dir += playerData.turnSpeed;
    } 
    if (checkKey(controls.up)) {
        if (checkKey(controls.right)) {
            playerData.dir += playerData.turnSpeed;
        }
        if (checkKey(controls.left)) {
            playerData.dir -= playerData.turnSpeed;
        }
        playerData.forces.push([playerData.speed, playerData.dir]);
        playerData.defdir = playerData.dir;
    }
    if (checkKey(controls.down)) {
        if (checkKey(controls.right)) {
            playerData.dir -= playerData.turnSpeed;
        }
        if (checkKey(controls.left)) {
            playerData.dir += playerData.turnSpeed;
        }
        playerData.forces.push([-1 * playerData.speed, playerData.dir]);
        playerData.defdir = playerData.dir;
    }
    if (checkKey(controls.spawn)) {
	if (enemies.length < 100) {
            new Enemy([randfloat(0, screenDim[0]), randfloat(0, screenDim[1])], 4);
	    enemies[enemies.length - 1].size /= 2;
	    enemies[enemies.length - 1].speed *= 2;
	}
    }
}

function moveStuff () {
    
    playerData.forces.forEach((force) => {
        playerData.vect = addVect(playerData.vect, [force[0], force[1]]);
    });
    playerData.forces.length = 0;
    playerData.vect[0] *= playerData.frict;
    let temp = (playerData.vect[1] * pi) / 180;
    
    playerData.coords[0] += Math.cos(temp) * playerData.vect[0];
    playerData.coords[1] += Math.sin(temp) * playerData.vect[0];
    playerData.aim = Math.atan2(mouseData.coords[1] - playerData.coords[1], mouseData.coords[0] - playerData.coords[0])

    ctx.strokeStyle = "rgb(0, 0, 255)";
    bullets.forEach ((bullet) => {
        temp = (bullet.vect[1] * pi) / 180;
        bullet.coords[0] += Math.cos(bullet.vect[1]) * bullet.vect[0];
        bullet.coords[1] += Math.sin(bullet.vect[1]) * bullet.vect[0];
    });

    enemies.forEach((enemy) =>{
        enemy.forces.forEach((force) => {
            enemy.vect = addVect(enemy.vect, [force[0], force[1]]);
        });
        enemy.forces.length = 0;
        enemy.vect[0] *= enemy.frict;
        let temp = (enemy.vect[1] * pi) / 180;
        
        enemy.coords[0] += Math.cos(temp) * enemy.vect[0];
        enemy.coords[1] += Math.sin(temp) * enemy.vect[0];
    
    });
    
}

function drawStuff() {
    ctx.clearRect(0, 0, screenDim[0], screenDim[1]);
    enemies.forEach ((enemy) =>{
        ctx.save();
        ctx.translate(enemy.coords[0], enemy.coords[1]);
        ctx.rotate(enemy.dir * (pi / 180));
        ctx.drawImage(badTankBase, 0 - (enemy.size / 2), 0 - (enemy.size / 2), enemy.size, enemy.size);
        ctx.restore();
        ctx.strokeStyle = "rgb(0, 0, 255)";
        let squareSize = enemy.size / (2 ** 0.5);
        ctx.strokeRect(
            enemy.coords[0] - ((squareSize) / 2), 
            enemy.coords[1] - ((squareSize) / 2), 
            squareSize, 
            squareSize
            );
        ctx.strokeStyle = "rgb(255, 0, 0)";
        ctx.beginPath();
        ctx.arc(enemy.coords[0], 
            enemy.coords[1], 
            enemy.size / 2, 
            0, 
            2 * pi,
            1,
        );
        ctx.stroke();
    });

    ctx.save();

    //ctx.fillRect(playerData.coords[0] - (playerData.size / 2), playerData.coords[1] - (playerData.size / 2), playerData.size, playerData.size);
    ctx.translate(playerData.coords[0], playerData.coords[1]);
    ctx.rotate(playerData.dir * (pi / 180));
    ctx.drawImage(tankBase, 0 - (playerData.size / 2), 0 - (playerData.size / 2), playerData.size, playerData.size);
    /*
    ctx.strokeRect(
        0 - (playerData.size / 2), 
        0 - (playerData.size / 2), 
        playerData.size, 
        playerData.size
        );
    */
    ctx.restore();
    ctx.save();
    bullets.forEach ((bullet) =>{
        ctx.save();
        ctx.translate(bullet.coords[0], bullet.coords[1]);
        ctx.rotate(bullet.vect[1]);
        ctx.drawImage(bulletNorm, 0 - (4 * bullet.size), 0 - (2 * bullet.size), 6 * bullet.size, 4 * bullet.size);
        let squareSize = 2 * bullet.size;
        ctx.strokeStyle = "rgb(0, 0, 255)";
        ctx.strokeRect(0 - (squareSize / 2), 0 - (squareSize / 2), squareSize, squareSize);
        ctx.strokeStyle = "rgb(255, 0, 0)";
        ctx.beginPath();
        ctx.arc(0, 
            0, 
            squareSize, 
            0, 
            2 * pi,
            1,
        );
        ctx.stroke();
        ctx.restore();
    });

    enemies.forEach ((enemy) =>{
        ctx.save();
        ctx.translate(enemy.coords[0], enemy.coords[1]);
        ctx.rotate(enemy.aim);
        ctx.drawImage(badTankHead, 0 - (4 * (enemy.size / 14)), 0 - (4.5 * (enemy.size / 14)), 17 * (enemy.size / 14), 9 * (enemy.size / 14));
        ctx.restore();
    });

    ctx.translate(playerData.coords[0], playerData.coords[1]);
    ctx.rotate(playerData.aim);
    ctx.drawImage(tankHead, 0 - (4 * (playerData.size / 14)), 0 - (4.5 * (playerData.size / 14)), 17 * (playerData.size / 14), 9 * (playerData.size / 14));

    ctx.restore();
    ctx.save();
    let x = Math.abs(playerData.dir % 90);
    //let squareSize = -1 * (playerData.size - (playerData.size / (2 ** 0.5))) * Math.sin((pi * x) / 90) + playerData.size;
    let squareSize = playerData.size / (2 ** 0.5);
    ctx.strokeStyle = "rgb(0, 0, 255)";
    // environment collider
    ctx.strokeRect(
        playerData.coords[0] - ((squareSize) / 2), 
        playerData.coords[1] - ((squareSize) / 2), 
        squareSize, 
        squareSize
        );
    /*
    squareSize = -1 * (playerData.size - (playerData.size / (2 ** 0.5))) * Math.sin((pi * x) / 90) + playerData.size;
    ctx.strokeRect(
        playerData.coords[0] - ((squareSize) / 2), 
        playerData.coords[1] - ((squareSize) / 2), 
        squareSize, 
        squareSize
        );
    */
    ctx.strokeStyle = "rgb(255, 0, 0)";
    // hitbox
    //ctx.moveTo(playerData.coords[0], playerData.coords[1] - (playerData.size / 2));
    ctx.beginPath();
    ctx.arc(playerData.coords[0], 
        playerData.coords[1], 
        playerData.size / 2, 
        0, 
        2 * pi,
        1,
    );
    ctx.stroke();

    ctx.strokeStyle = "rgb(0, 0, 0)";
    ctx.lineWidth = 4;
    walls.forEach((wall) => {
        ctx.strokeRect(
            wall[0],
            wall[1],
            wall[2],
            wall[3]
        );
    });

    ctx.lineWidth = 2;
    ctx.fillStyle = "rgb(0, 0, 0)";
    ctx.beginPath();
    ctx.arc(mouseData.coords[0], mouseData.coords[1], 5, 0, 2 * pi, 1);
    ctx.fill();

    ctx.lineWidth = 3;
    ctx.fillStyle = "rgb(255, 255, 0)";
    testRects.forEach((rect) =>{
        ctx.strokeRect(
            rect[0],
            rect[1],
            rect[2],
            rect[3]
        );
    });
    testRects.length = 0;

    ctx.fillStyle = "rgb(0, 0, 0)";
    ctx.font = '20px Arial';
    ctx.fillText(fps, 5, 20);
    ctx.fillText(testText, 5, 40);
}   

function ejectWalls() {
    let x = Math.abs(playerData.dir % 90);
    let temp1 = playerData.size / (2 ** 0.5);
    let temp2 = (playerData.vect[1] * pi) / 180;
    let flag = [];
    //eject player
    let tempwalls = [];
    tempwalls = tempwalls.concat(walls);
    enemies.forEach ((enemy) =>{
        let squareSize = enemy.size / (2 ** 0.5);
        tempwalls.push([enemy.coords[0] - ((squareSize) / 2),
        enemy.coords[1] - ((squareSize) / 2), 
        squareSize, 
        squareSize]);
    });
    for (const wall of tempwalls) {
        if (colRect([playerData.coords[0] - ((temp1) / 2), (playerData.coords[1] - (Math.sin(temp2) * playerData.vect[0])) - ((temp1) / 2), temp1, temp1], wall)) {
            //playerData.coords[0] -= Math.cos(temp2) * playerData.vect[0];
            flag.push(1);
        };
        if (colRect([(playerData.coords[0] - (Math.cos(temp2) * playerData.vect[0])) - ((temp1) / 2), playerData.coords[1] - ((temp1) / 2), temp1, temp1], wall)) {
            //playerData.coords[1] -= Math.sin(temp2) * playerData.vect[0];
            flag.push(2);
        };
    };
    if (flag.includes(1)) {
        playerData.coords[0] -= Math.cos(temp2) * playerData.vect[0];
    };
    if (flag.includes(2)) {
        playerData.coords[1] -= Math.sin(temp2) * playerData.vect[0];
    };
    flag = 1;
    loops = 0;
    while (flag && loops < 100) {
        flag = 0;
        loops++
        tempwalls.every((wall) =>{
            if (colRect([(playerData.coords[0] - (Math.cos(temp2) * playerData.vect[0])) - ((temp1) / 2), (playerData.coords[1] - (Math.sin(temp2) * playerData.vect[0])) - ((temp1) / 2), temp1, temp1], wall)) {
                flag = 1;
                if (playerData.coords[0] >= wall[0] + (wall[2] / 2)) {
                    playerData.coords[0]++;
                } else {
                    playerData.coords[0]--;
                }
                if (playerData.coords[1] >=  wall[1] + (wall[3] / 2)) {
                    playerData.coords[1]++;
                } else {
                    playerData.coords[1]--;
                }
                return false;
            };
        return true;
        });
    }
    bullets.forEach((bullet) =>{
        x = Math.abs(bullet.vect[1] % 90);
        temp1 = 2 * bullet.size;
        temp2 = bullet.vect[1];
        for (const wall of walls) {
            flag = 0;
            if (colRect([bullet.coords[0] - ((temp1) / 2), (bullet.coords[1] - (Math.sin(bullet.vect[1]) * bullet.vect[0])) - ((temp1) / 2), temp1, temp1], wall)) {
                bullet.coords[0] -= Math.cos(bullet.vect[1]) * bullet.vect[0];
                bullet.vect[1] = Math.atan2(Math.sin(bullet.vect[1]) * bullet.vect[0], Math.cos(bullet.vect[1]) * bullet.vect[0] * -1);
                flag = 1;
            };
            if (colRect([(bullet.coords[0]) - ((temp1) / 2), bullet.coords[1] - ((temp1) / 2), temp1, temp1], wall)) {
                bullet.coords[1] -= Math.sin(bullet.vect[1]) * bullet.vect[0];
                bullet.vect[1] = Math.atan2(Math.sin(bullet.vect[1]) * bullet.vect[0] * -1, Math.cos(bullet.vect[1]) * bullet.vect[0]);
                flag = 1;
            };
            if (flag) {
                if (bullet.bounce >= 1) {
                    playerData.bulletCount--;
                    bullets = bullets.filter(i => i.self !== bullet.self);
                };
                bullet.bounce += 1;
                break;
            };
        };
    });
    enemies.forEach((enemy) => {
        enemy.wallTouch = false;
        x = Math.abs(enemy.dir % 90);
        temp1 = enemy.size / (2 ** 0.5);
        temp2 = (enemy.vect[1] * pi) / 180;
        flag = [];
        tempwalls = [];
        tempwalls = tempwalls.concat(walls);
        enemies.forEach ((enemy2) =>{
            if (enemy2 != enemy) {
                squareSize = enemy2.size / (2 ** 0.5);
                tempwalls.push([enemy2.coords[0] - ((squareSize) / 2),
                enemy2.coords[1] - ((squareSize) / 2), 
                squareSize, 
                squareSize]);
            }
        });
        squareSize = playerData.size / (2 ** 0.5);
        tempwalls.push([playerData.coords[0] - ((squareSize) / 2),
            playerData.coords[1] - ((squareSize) / 2), 
            squareSize, 
            squareSize]);
        for (const wall of tempwalls) {
            if (colRect([enemy.coords[0] - ((temp1) / 2), (enemy.coords[1] - (Math.sin(temp2) * enemy.vect[0])) - ((temp1) / 2), temp1, temp1], wall)) {
                flag.push(1);
                if (walls.includes(wall)) {enemy.wallTouch = true;}
            };
            if (colRect([(enemy.coords[0] - (Math.cos(temp2) * enemy.vect[0])) - ((temp1) / 2), enemy.coords[1] - ((temp1) / 2), temp1, temp1], wall)) {
                flag.push(2);
                if (walls.includes(wall)) {enemy.wallTouch = true;}
            };
        };
        if (flag.includes(1)) {
            enemy.coords[0] -= Math.cos(temp2) * enemy.vect[0];
        };
        if (flag.includes(2)) {
            enemy.coords[1] -= Math.sin(temp2) * enemy.vect[0];
        };
        flag = 1;
        loops = 0;
        while (flag && loops < 100) {
            flag = 0;
            loops++
            tempwalls.every((wall) =>{
                if (colRect([(enemy.coords[0] - (Math.cos(temp2) * enemy.vect[0])) - ((temp1) / 2), (enemy.coords[1] - (Math.sin(temp2) * enemy.vect[0])) - ((temp1) / 2), temp1, temp1], wall)) {
                    flag = 1;
                    if (enemy.coords[0] >= wall[0] + (wall[2] / 2)) {
                        enemy.coords[0]++;
                    } else {
                        enemy.coords[0]--;
                    }
                    if (enemy.coords[1] >=  wall[1] + (wall[3] / 2)) {
                        enemy.coords[1]++;
                    } else {
                        enemy.coords[1]--;
                    }
                    return false;
                };
            return true;
            });
        }
    });
}

function hitStuff() {
    bullets.forEach ((bullet) =>{
            //check if bullet touch player
            if ((((playerData.coords[0] - bullet.coords[0]) ** 2) + ((playerData.coords[1] - bullet.coords[1]) ** 2)) ** 0.5 < (bullet.size * 2) + (playerData.size / 2)) {
                playerData.bulletCount--;
                bullets = bullets.filter(i => i.self !== bullet.self);
            };

            enemies.every((enemy) =>{
                //check if bullet touch enemy
                if ((((enemy.coords[0] - bullet.coords[0]) ** 2) + ((enemy.coords[1] - bullet.coords[1]) ** 2)) ** 0.5 < (bullet.size * 2) + (enemy.size / 2)) {
                    playerData.bulletCount--;
                    bullets = bullets.filter(i => i.self !== bullet.self);
                    enemies = enemies.filter(i => i.self !== enemy.self);
                    return false;
                }
                return true;
            });
    });
}
/*
e1 = new Enemy([300, 300], 0)
e2 = new Enemy([250, 300], 0)
e3 = new Enemy([200, 300], 0)
e3.speed = 0
e3.ai = 2
*/

function processAI() {
    /*
    0 - dummy
    1 - no pathfind go to target
    2 - pathfinding to target
    3 - astar pathfinding to target
    4 - astar pathfinding to player rebuilt
    */
    enemies.forEach((enemy) =>{
        /*
        let modtargetdir;
        if (!(enemy.target === NaN)) {
            let temp2 = enemy.targetdir[0]
            enemy.targetdir[0] = Math.atan2(enemy.target[1] - enemy.coords[1], enemy.target[0] - enemy.coords[0]) * (180 / pi);
            if ((-90 > temp2 && temp2 > -180) && (90 < enemy.targetdir[0] && enemy.targetdir[0] < 180)) {
                enemy.targetdir[1]--;
            } else if (-90 > enemy.targetdir[0] && enemy.targetdir[0] > -180 && 90 < temp2 && temp2 < 180) {
                enemy.targetdir[1]++;
            }
            modtargetdir = enemy.targetdir[0] + (360 * enemy.targetdir[1]);
        }
        */
        if (enemy.ai === 0) {
            ///*
            let look = mouseData.coords;
            let temp = true;
            walls.forEach((wall) =>{
                if (colRectLine([look, enemy.coords], wall)) {temp = false;}
            });
            if (temp) {
                enemy.aim = Math.atan2(look[1] - enemy.coords[1], look[0] - enemy.coords[0]);
            } else {enemy.aim = Math.atan2(look[1] - enemy.coords[1], look[0] - enemy.coords[0]) + pi;}
            //enemy.coords = mouseData.coords
            //*/
            //enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);
        } else if (enemy.ai === 1) {
            let temp = true;
            walls.forEach((wall) =>{
                if (colRectLine([playerData.coords, enemy.coords], wall)) {temp = false;}
            });
            if (temp) {
                enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);
            } else {enemy.aim = 0}

            if (Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed < Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed) {enemy.dir -= enemy.turnSpeed;} 
            else if (!(Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed == Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed)) {enemy.dir += enemy.turnSpeed;}
            enemy.forces.push([enemy.speed, enemy.dir]);
        } else if (enemy.ai === 2) {
            let orbit = [Math.atan2(enemy.coords[1] - playerData.coords[1], enemy.coords[0] - playerData.coords[0]) + (randfloat(-45, 45) * (pi / 180)), 200]
            //[direction from player to object radians, radius]
            let tget = [
                playerData.coords[0] + (orbit[1] * Math.cos(orbit[0])), 
                playerData.coords[1] + (orbit[1] * Math.sin(orbit[0]))
            ]
            let squareSize = enemy.size / (2 ** 0.5);
            if (enemy.ff) {
                enemy.ff--;
                enemy.aiData.subtargets = pathFind(enemy.coords, tget, enemy.size);
                enemy.changeTarget(enemy.aiData.subtargets[0]);
                enemy.aiData.wait = 0;
                enemy.aiData.backup = 0;
                enemy.aiData.lfPlayer = [enemy.coords, 0, 0]
                // look for player [last seen position, if the target has changed to look for the player, if it is looking for the player]
            }
            enemy.aiData.wait--;
            enemy.bulletCD[0]--;
            /*
            let squareSize = enemy.size / (2 ** 0.5);
            ctx.strokeRect(
                enemy.coords[0] - ((squareSize) / 2), 
                enemy.coords[1] - ((squareSize) / 2), 
                squareSize, 
                squareSize
                );
            */
            let enemySquare = [
                enemy.coords[0] - ((squareSize) / 2), 
                enemy.coords[1] - ((squareSize) / 2), 
                squareSize,
                squareSize
            ];
            let temp = true;
            walls.every((wall) =>{
                if (colRectLine([playerData.coords, enemy.coords], wall)) {
                    temp = false;
                    return false;
                }
                return true;
            });

            if (colRectPoint(enemy.target, enemySquare)) {
                enemy.aiData.subtargets.shift();
                if (enemy.aiData.subtargets.length === 0) {
                    //enemy.forces.push([enemy.speed * 10, enemy.dir + 180]);
                    enemy.aiData.wait = 10;
                }
                enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
            }
            //if (temp) {enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);}
            //(temp && enemy.aiData.subtargets.length === 0)
            if (temp) {
                enemy.aiData.lfPlayer[0] = [playerData.coords[0], playerData.coords[1]];
                if ((enemy.aiData.subtargets.length === 0) || (enemy.aiData.lfPlayer[2])) {
                    enemy.aiData.subtargets = pathFind(enemy.coords, 
                        tget, 
                        enemy.size);
                    enemy.changeTarget(enemy.aiData.subtargets[0]);
                }
                enemy.aiData.lfPlayer[2] = 0;
                enemy.aiData.lfPlayer[1] = 0;
                enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);
                if (enemy.bulletCD[0] <= 0) {
                    let con = true;
                    enemies.every((enemy2) =>{
                        if (enemy2 !== enemy) {
                            //console.log(`dist: ${distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords)}`)
                            con = true;
                            if (enemy === enemies[1]) {
                                console.log(distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords))
                            }
                            if (
                                distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords) <= 
                                (enemy2.size / 2) + (enemy.bulletSize / 2)) {
                                con = false;
                                return false;
                            }
                        }
                        return true;
                    });
                    if (con) {enemy.shoot();}
                }
            } else {
                if (!enemy.aiData.lfPlayer[1]) {
                    enemy.aiData.lfPlayer[2] = 1;
                    enemy.aiData.lfPlayer[1] = 1;
                    enemy.aiData.subtargets = pathFind(enemy.coords, 
                        enemy.aiData.lfPlayer[0], 
                        enemy.size);
                    enemy.aim = Math.atan2(enemy.aiData.lfPlayer[0][1] - enemy.coords[1], enemy.aiData.lfPlayer[0][0] - enemy.coords[0]);
                    enemy.changeTarget(enemy.aiData.subtargets[0]);
                }
            }
            if (!(enemy.aiData.backup > 0)) {
                walcol = 0;
                temp = [
                    (enemy.coords[0] + (enemy.speed * 2 * Math.cos(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    (enemy.coords[1] + (enemy.speed * 2 * Math.sin(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    squareSize,
                    squareSize
                ];
                testRects.push(temp)
                walls.every((wall) =>{
                    if (colRect(wall, temp)) {
                        walcol++;
                        return false;
                    }
                    return true;
                });

                if (walcol) {
                    enemy.aiData.backup = Math.floor((squareSize) / enemy.speed);
                }
            } else {
                walcol = 0;
                temp = [
                    (enemy.coords[0] + (enemy.speed * -2 * Math.cos(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    (enemy.coords[1] + (enemy.speed * -2 * Math.sin(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    squareSize,
                    squareSize
                ];
                testRects.push(temp)
                walls.every((wall) =>{
                    if (colRect(wall, temp)) {
                        walcol++;
                        return false;
                    }
                    return true;
                });

                if (walcol) {
                    enemy.aiData.backup = 0;
                    enemy.aiData.subtargets = pathFind(enemy.coords, tget, enemy.size);
                    enemy.changeTarget(enemy.aiData.subtargets[0]);
                }
            }
            if ((enemy.aiData.wait <= 0) && !(enemy.aiData.subtargets.length === 0)) {
                if (!(enemy.aiData.backup > 0)) {
                    if (Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed < Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed) {
                        enemy.dir -= enemy.turnSpeed;
                    } else if (!(Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed === Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed)) {
                        enemy.dir += enemy.turnSpeed;
                    } else {
                        enemy.forces.push([enemy.speed, enemy.dir]);
                    }
                    /*
                    enemy.dir = (isNaN(enemy.targetdir[0])) ? (enemy.dir) : (enemy.targetdir[0]);
                    enemy.forces.push([enemy.speed, enemy.dir]);
                    */
                }
                if (enemy.aiData.backup > 0) {
                    enemy.aiData.backup--;
                    enemy.forces.push([enemy.speed, enemy.dir + 180]);
                    if (enemy.aiData.backup <= 1) {
                        if (enemy.aiData.lfPlayer[2]) {
                            enemy.aiData.subtargets = pathFind(enemy.coords, 
                                enemy.aiData.lfPlayer[0], 
                                enemy.size);
                            enemy.changeTarget(enemy.aiData.subtargets[0]);
                        } else {
                        enemy.aiData.subtargets = pathFind(enemy.coords, tget, enemy.size);
                        enemy.changeTarget(enemy.aiData.subtargets[0]);
                        }
                    }
                }
            }


        } else if (enemy.ai === 3) {
            let orbit = [Math.atan2(enemy.coords[1] - playerData.coords[1], enemy.coords[0] - playerData.coords[0]) + (randfloat(-45, 45) * (pi / 180)), 200]
            //[direction from player to object radians, radius]
            let tget = [
                playerData.coords[0] + (orbit[1] * Math.cos(orbit[0])), 
                playerData.coords[1] + (orbit[1] * Math.sin(orbit[0]))
            ]
            let squareSize = enemy.size / (2 ** 0.5);
            if (enemy.ff) {
                enemy.ff--;
                enemy.aiData.subtargets = aStarPathFind(enemy.coords, tget, enemy.size);
                enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                enemy.aiData.wait = 0;
                enemy.aiData.backup = 0;
                enemy.aiData.lfPlayer = [enemy.coords]
                // look for player [last seen position, if the target has changed to look for the player, if it is looking for the player]
            }
            enemy.aiData.wait--;
            enemy.bulletCD[0]--;
            /*
            let squareSize = enemy.size / (2 ** 0.5);
            ctx.strokeRect(
                enemy.coords[0] - ((squareSize) / 2), 
                enemy.coords[1] - ((squareSize) / 2), 
                squareSize, 
                squareSize
                );
            */
            let enemySquare = [
                enemy.coords[0] - ((squareSize) / 2), 
                enemy.coords[1] - ((squareSize) / 2), 
                squareSize,
                squareSize
            ];
            let temp = true;
            walls.every((wall) =>{
                if (colRectLine([playerData.coords, enemy.coords], wall)) {
                    temp = false;
                    return false;
                }
                return true;
            });

            if (colRectPoint(enemy.target, enemySquare)) {
                enemy.aiData.subtargets.shift();
                if (enemy.aiData.subtargets.length === 0) {
                    //enemy.forces.push([enemy.speed * 10, enemy.dir + 180]);
                    enemy.aiData.wait = 10;
                }
                enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
            }
            //if (temp) {enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);}
            //(temp && enemy.aiData.subtargets.length === 0)
            if (temp) {
                enemy.aiData.lfPlayer[0] = [playerData.coords[0], playerData.coords[1]];
                if ((enemy.aiData.subtargets.length === 0) || (enemy.aiData.lfPlayer[2])) {
                    enemy.aiData.subtargets = aStarPathFind(enemy.coords, 
                        tget, 
                        enemy.size);
                    enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                }
                enemy.aiData.lfPlayer[2] = 0;
                enemy.aiData.lfPlayer[1] = 0;
                enemy.aim = Math.atan2(playerData.coords[1] - enemy.coords[1], playerData.coords[0] - enemy.coords[0]);
                if (enemy.bulletCD[0] <= 0) {
                    let con = true;
                    enemies.every((enemy2) =>{
                        if (enemy2 !== enemy) {
                            //console.log(`dist: ${distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords)}`)
                            con = true;
                            if (enemy === enemies[1]) {
                                console.log(distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords))
                            }
                            if (
                                distLinePoint([[enemy.coords[0] + (50 * Math.cos(enemy.aim)), enemy.coords[1] + (50 * Math.sin(enemy.aim))], enemy.coords], enemy2.coords) <= 
                                (enemy2.size / 2) + (enemy.bulletSize / 2)) {
                                con = false;
                                return false;
                            }
                        }
                        return true;
                    });
                    if (con) {enemy.shoot();}
                }
            } else {
                if (!enemy.aiData.lfPlayer[1]) {
                    enemy.aiData.lfPlayer[2] = 1;
                    enemy.aiData.lfPlayer[1] = 1;
                    enemy.aiData.subtargets = aStarPathFind(enemy.coords, 
                        enemy.aiData.lfPlayer[0], 
                        enemy.size);
                    enemy.aim = Math.atan2(enemy.aiData.lfPlayer[0][1] - enemy.coords[1], enemy.aiData.lfPlayer[0][0] - enemy.coords[0]);
                    enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                }
            }
            if (!(enemy.aiData.backup > 0)) {
                walcol = 0;
                temp = [
                    (enemy.coords[0] + (enemy.speed * 2 * Math.cos(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    (enemy.coords[1] + (enemy.speed * 2 * Math.sin(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    squareSize,
                    squareSize
                ];
                testRects.push(temp)
                walls.every((wall) =>{
                    if (colRect(wall, temp)) {
                        walcol++;
                        return false;
                    }
                    return true;
                });

                if (walcol) {
                    enemy.aiData.backup = Math.floor((squareSize) / enemy.speed);
                }
            } else {
                walcol = 0;
                temp = [
                    (enemy.coords[0] + (enemy.speed * -2 * Math.cos(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    (enemy.coords[1] + (enemy.speed * -2 * Math.sin(enemy.dir * (pi / 180)))) - ((squareSize) / 2), 
                    squareSize,
                    squareSize
                ];
                testRects.push(temp)
                walls.every((wall) =>{
                    if (colRect(wall, temp)) {
                        walcol++;
                        return false;
                    }
                    return true;
                });

                if (walcol) {
                    enemy.aiData.backup = 0;
                    enemy.aiData.subtargets = aStarPathFind(enemy.coords, tget, enemy.size);
                    enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                }
            }
            if ((enemy.aiData.wait <= 0) && !(enemy.aiData.subtargets.length === 0)) {
                if (!(enemy.aiData.backup > 0)) {
                    if (Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed < Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed) {
                        enemy.dir -= enemy.turnSpeed;
                    } else if (!(Math.floor((modtargetdir) / enemy.turnSpeed) * enemy.turnSpeed === Math.floor((enemy.dir) / enemy.turnSpeed) * enemy.turnSpeed)) {
                        enemy.dir += enemy.turnSpeed;
                    } else {
                        enemy.forces.push([enemy.speed, enemy.dir]);
                    }
                    /*
                    enemy.dir = (isNaN(enemy.targetdir[0])) ? (enemy.dir) : (enemy.targetdir[0]);
                    enemy.forces.push([enemy.speed, enemy.dir]);
                    */
                }
                if (enemy.aiData.backup > 0) {
                    enemy.aiData.backup--;
                    enemy.forces.push([enemy.speed, enemy.dir + 180]);
                    if (enemy.aiData.backup <= 1) {
                        if (enemy.aiData.lfPlayer[2]) {
                            enemy.aiData.subtargets = aStarPathFind(enemy.coords, 
                                enemy.aiData.lfPlayer[0], 
                                enemy.size);
                            enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                        } else {
                        enemy.aiData.subtargets = aStarPathFind(enemy.coords, tget, enemy.size);
                        enemy.changeTarget(enemy.aiData.subtargets[0] ?? NaN);
                        }
                    }
                }
            }


        } else if (enemy.ai === 4) {
            async function path() {
                let orbit = [Math.atan2(enemy.coords[1] - playerData.coords[1], enemy.coords[0] - playerData.coords[0]) + (randfloat(-45, 45) * (pi / 180)), 200 + randfloat(0, 100)]
                //[direction from player to object radians, radius]
                let tget = [
                    playerData.coords[0] + (orbit[1] * Math.cos(orbit[0])), 
                    playerData.coords[1] + (orbit[1] * Math.sin(orbit[0]))
                ];
                let canSeeTarget = true;
                let enemyTargetLine = [enemy.coords, tget];
                walls.every((wall) =>{
                    if (colRectLine(enemyTargetLine, wall)) {
                        canSeeTarget = false;
                        return false;
                    }
                    return true;
                });
                let result;
                if (canSeeTarget) {result = [tget];}
                else {result = aStarPathFind(enemy.coords, tget, enemy.size);}
                if (result.length == 0) {enemy.aiData.wait = 30;}
                return result;
            }
            async function pathLook() {
                // when the enemy is looking for player
                let canSeeTarget = true;
                let enemyTargetLine = [enemy.coords, enemy.aiData.lfPlayer[0]];
                walls.every((wall) =>{
                    if (colRectLine(enemyTargetLine, wall)) {
                        canSeeTarget = false;
                        return false;
                    }
                    return true;
                });
                let result;
                if (canSeeTarget) {result = [enemy.aiData.lfPlayer[0]];}
                else {result = aStarPathFind(enemy.coords, enemy.aiData.lfPlayer[0], enemy.size);}
                if (result.length == 0) {enemy.aiData.wait = 30;}
                return result;
            }
            if (enemy.ff) {
                enemy.ff--;
                enemy.aiData.lfPlayer = [enemy.coords, false, false];
                // look for player [last seen position, targeting player?, did the target change to look for the player?]
                enemy.aiData.subtargets = "none";
                enemy.aiData.wait = Math.floor(randfloat(0, 60));
            }
            enemy.aiData.wait--;
            if (enemy.aiData.wait <= 0) {
                canSeePlayer = true;
                playerEnemyLine = [playerData.coords, enemy.coords];
                // check if a wall blocks the enemy from seeing the player
                walls.every((wall) =>{
                    if (colRectLine(playerEnemyLine, wall)) {
                        canSeePlayer = false;
                        return false;
                    }
                    return true;
                });
                if (canSeePlayer) {
                    enemy.aiData.lfPlayer[0] = [playerData.coords[0],playerData.coords[1]];
                    if ((!enemy.aiData.lfPlayer[1] || enemy.target === "none")) {
                        enemy.aiData.lfPlayer[1] = true;
                        enemy.aiData.lfPlayer[2] = false;
                        enemy.aiData.subtargets = "none";
                        pathPromise = new Promise((resolve) =>{
                            resolve(path());
                        });
                        pathPromise.then((result) => {
                            enemy.aiData.subtargets = result;
                            enemy.changeTarget(enemy.aiData.subtargets[0] ?? "none");
                        });
                        //enemy.changeTarget(enemy.aiData.subtargets[0] ?? "none");
                    }
                } else {
                    enemy.aiData.lfPlayer[1] = false;
                    if (!enemy.aiData.lfPlayer[2] && enemy.aiData.subtargets) {
                        enemy.aiData.lfPlayer[2] = true;
                        enemy.aiData.subtargets = "none";
                        pathPromise = new Promise((resolve) =>{
                            resolve(pathLook());
                        });
                        pathPromise.then((result) => {
                            enemy.aiData.subtargets = result;
                            enemy.changeTarget(enemy.aiData.subtargets[0] ?? "none");
                        });
                        //enemy.changeTarget(enemy.aiData.subtargets[0] ?? "none");
                    }
                }
                if (dist(enemy.coords, enemy.target) < enemy.size / 2) {
                    if (enemy.aiData.subtargets !== "none") {enemy.aiData.subtargets.shift();}
                    enemy.changeTarget(enemy.aiData.subtargets[0] ?? "none");
                }
                if (enemy.target[0] !== "n") {
                    enemy.targetdir[0] = Math.atan2(enemy.target[1] - enemy.coords[1], enemy.target[0] - enemy.coords[0]) * (180 / pi);
                    /*console.log([
                        Math.floor((enemy.targetdir[0] % 360) / enemy.turnSpeed) * enemy.turnSpeed,
                        Math.floor((enemy.dir % 360) / enemy.turnSpeed) * enemy.turnSpeed,
                        enemy.target
                    ]);*/
                    if (Math.floor((enemy.targetdir[0] % 360) / enemy.turnSpeed) * enemy.turnSpeed < Math.floor((enemy.dir % 360) / enemy.turnSpeed) * enemy.turnSpeed) {
                        enemy.dir -= enemy.turnSpeed;
                    } else if (Math.floor((enemy.targetdir[0] % 360) / enemy.turnSpeed) * enemy.turnSpeed !== Math.floor((enemy.dir % 360) / enemy.turnSpeed) * enemy.turnSpeed) {
                        enemy.dir += enemy.turnSpeed;
                    } else {
                        enemy.forces.push([enemy.speed, enemy.dir]);
                    }
                }
                enemy.aim = Math.atan2(enemy.aiData.lfPlayer[0][1] - enemy.coords[1], enemy.aiData.lfPlayer[0][0] - enemy.coords[0]);
                testText = `[${enemy.aiData.subtargets}] type: ${typeof enemy.aiData.subtargets}`;
            }
        }
    });
}

function checkKey(key) {
    return key in keyInputs ? keyInputs[key] : 0;
}

function addVect(vect1, vect2) {
    a1 = (vect1[1] * pi) / 180;
    a2 = (vect2[1] * pi) / 180;
    const x1 = Math.cos(a1) * vect1[0];
    const y1 = Math.sin(a1) * vect1[0];
    const x2 = Math.cos(a2) * vect2[0];
    const y2 = Math.sin(a2) * vect2[0];
    const x3 = x1 + x2;
    const y3 = y1 + y2;
    return [Math.sqrt(x3 ** 2 + y3 ** 2), (Math.atan2(y3, x3) * 180) / pi];
}

function keyHandler(key, state) {
    //console.log(`${key}`.toLowerCase());
    keyInputs[`${key}`.toLowerCase()] = state;
}

function colRect(rect1, rect2) {
    // Checks if 2 rectangles collide
    // Check if the two rectangles intersect on the x-axis
    if (rect1[0] < rect2[0] + rect2[2] && rect1[0] + rect1[2] > rect2[0]) {
      // Check if the two rectangles intersect on the y-axis
      if (rect1[1] < rect2[1] + rect2[3] && rect1[1] + rect1[3] > rect2[1]) {
        // The two rectangles overlap
        return true;
      }
    }
    // The two rectangles do not overlap
    return false;
}

function colLine(line1, line2) {
    const x1 = line1[0][0];
    const y1 = line1[0][1];
    const x2 = line1[1][0];
    const y2 = line1[1][1];
    const x3 = line2[0][0];
    const y3 = line2[0][1];
    const x4 = line2[1][0];
    const y4 = line2[1][1];

    const dx1 = x2 - x1;
    const dy1 = y2 - y1;
    const dx2 = x4 - x3;
    const dy2 = y4 - y3;

    const det = dx1 * dy2 - dx2 * dy1;
    const t1 = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / det;
    const t2 = ((x3 - x1) * dy1 - (y3 - y1) * dx1) / det;

    return t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1;
}

function colRectLine(line, rect) {
    //line - [[x1, y1], [x2, y2]]
    //rect - [x, y, w, h]
    // Checks if a line and a rectangle overlap
    const linex1 = line[0][0];
    const liney1 = line[0][1];
    const linex2 = line[1][0];
    const liney2 = line[1][1];
    const rectx1 = rect[0];
    const recty1 = rect[1];
    const rectx2 = rect[0] + rect[2];
    const recty2 = rect[1] + rect[3];
    if (colRect([Math.min(linex1, linex2), Math.min(liney1, liney2), Math.abs(linex1 - linex2), Math.abs(liney1 - liney2)], rect)) {
        return (
            colLine(line, [[rectx1, recty1], [rectx2, recty1]]) ||
            colLine(line, [[rectx2, recty1], [rectx2, recty2]]) ||
            colLine(line, [[rectx2, recty2], [rectx1, recty2]]) ||
            colLine(line, [[rectx1, recty2], [rectx1, recty1]])
        );
        /*
        doLineSegmentsIntersect(line.x1, line.y1, line.x2, line.y2, rectangle.x, rectangle.y, rectX2, rectangle.y) ||
        doLineSegmentsIntersect(line.x1, line.y1, line.x2, line.y2, rectX2, rectangle.y, rectX2, rectY2) ||
        doLineSegmentsIntersect(line.x1, line.y1, line.x2, line.y2, rectX2, rectY2, rectangle.x, rectY2) ||
        doLineSegmentsIntersect(line.x1, line.y1, line.x2, line.y2, rectangle.x, rectY2, rectangle.x, rectangle.y);
        */
      ;
    }
    return false;
}

function pathFind(from, to, size) {

    /*
    Variables:
    final target
    subtarget
    Checklist:
    check if the line between enemy and final target intersects a wall
        If there isnt an intersection then youre done
    record the walls the line intersects
    record the coordinates of the corners and midpoints of the walls
    record the wall closest coordinates to the enemy
    find the closest points of intersection to the enemy
    check what side of the wall the point is on and how far it is from the center both ways (left, right, up, down)
    attempt to move a point along the wall the shortest distance off the edge of the wall + 1.5 enemy size
        If the point is inside of a wall try the other side
    check if the line between enemy and point intersects a wall
        If the point intersects a wall repeat above
    set a subtarget at the point
    repeat above but replace enemy position with last subtarget
    */
    //return format: [fTarget, subtargets]
    const subtargets = []
    let loops = 0;
    let hsize = size / 2;
    while (true) {
        loops += 1;
        if (loops >= 100) {break;}
        let cWalls = [];
        let lines = [
            [from, to],
            [[from[0] - hsize, from[1] - hsize], [to[0] - hsize, to[1] - hsize]], // top left
            [[from[0] + hsize, from[1] - hsize], [to[0] + hsize, to[1] - hsize]], // top right
            [[from[0] - hsize, from[1] + hsize], [to[0] - hsize, to[1] + hsize]], // bottom left
            [[from[0] + hsize, from[1] + hsize], [to[0] + hsize, to[1] + hsize]], // bottom right
        ];
        let cWallPoints = [];
        let temp;
        let temp2 = [];
        let closeWall;
        let closeWallSides;
        let intPoint;
        let wallSide;
        let wallDir;
        let closeDist;
        // check if the line between enemy and final target intersects a wall
        walls.forEach((wall) =>{
            if (
                colRectLine(lines[0], wall) ||
                colRectLine(lines[1], wall) ||
                colRectLine(lines[2], wall) ||
                colRectLine(lines[3], wall) ||
                colRectLine(lines[4], wall)
            ) {
                // record the walls the line intersects
                cWalls.push(wall);
            }
        });
        if (cWalls.length == 0) {
            //If there isnt an intersection then youre done
            break;
        }
        //record the coordinates of the corners and midpoints of the walls
        cWalls.forEach((wall) =>{
            cWallPoints.push([
                [wall[0], wall[1]], 
                [wall[0] + wall[2], wall[1]], 
                [wall[0] + wall[2], wall[1] + wall[3]], 
                [wall[0], wall[1] + wall[3]],
                [(wall[0] + wall[0] + wall[2]) / 2, wall[1]],
                [wall[0] + wall[2], (wall[1] + wall[1] + wall[3]) / 2],
                [(wall[0] + wall[0] + wall[2]) / 2, wall[1] + wall[3]],
                [wall[0], (wall[1] + wall[1] + wall[3]) / 2]
            ]);
        });
        //record the wall closest coordinates to the enemy
        temp = [];
        cWallPoints.forEach((points) =>{
            points.forEach((point) =>{
                temp.push(dist(point, from));
            });
        });
        temp = Math.min(...temp);
        cWalls.every((wall) =>{
            cWallPoints[cWalls.indexOf(wall)].every((point) =>{
                if (dist(point, from) === temp) {
                    closeWall = wall;
                    return false;
                }
                return true;
            });
            if (isNaN(closeWall)) {return true;} else {return false;}
        });
        //find the closest points of intersection to the enemy
        closeWallSides = [
            [[closeWall[0], closeWall[1]], [closeWall[0] + closeWall[2], closeWall[1]]],
            [[closeWall[0] + closeWall[2], closeWall[1]], [closeWall[0] + closeWall[2], closeWall[1] + closeWall[3]]],
            [[closeWall[0] + closeWall[2], closeWall[1] + closeWall[3]], [closeWall[0], closeWall[1] + closeWall[3]]],
            [[closeWall[0], closeWall[1] + closeWall[3]], [closeWall[0], closeWall[1]]]
        ];
        temp = [
            lineIntersect(closeWallSides[0], lines[0]),
            lineIntersect(closeWallSides[1], lines[0]),
            lineIntersect(closeWallSides[2], lines[0]),
            lineIntersect(closeWallSides[3], lines[0]),
            lineIntersect(closeWallSides[0], lines[1]),
            lineIntersect(closeWallSides[1], lines[1]),
            lineIntersect(closeWallSides[2], lines[1]),
            lineIntersect(closeWallSides[3], lines[1]),
            lineIntersect(closeWallSides[0], lines[2]),
            lineIntersect(closeWallSides[1], lines[2]),
            lineIntersect(closeWallSides[2], lines[2]),
            lineIntersect(closeWallSides[3], lines[2]),
            lineIntersect(closeWallSides[0], lines[3]),
            lineIntersect(closeWallSides[1], lines[3]),
            lineIntersect(closeWallSides[2], lines[3]),
            lineIntersect(closeWallSides[3], lines[3]),
            lineIntersect(closeWallSides[0], lines[4]),
            lineIntersect(closeWallSides[1], lines[4]),
            lineIntersect(closeWallSides[2], lines[4]),
            lineIntersect(closeWallSides[3], lines[4]),
        ].filter(i => !(i === false));
        temp.forEach((point) => {temp2.push(dist(point, from));});
        closeDist = Math.min(...temp2);
        temp.every((point) =>{
            if (dist(point, from) === closeDist) {
                intPoint = point;
                return false;
            }
            return true;
        });
        /*
        intPoint = Math.min(...[
            dist(temp, from),
            dist(temp, from),
            dist(temp, from),
            dist(temp, from),
        ].filter(i => !(i === false)));
        */
        //check what side of the wall the point is on and how far it is from the center both ways (left, right, up, down)
        closeWallSides.every((i) =>{
            let dists = [
                dist((f => f !== false ? f : Infinity)(lineIntersect(i, lines[0])), from),
                dist((f => f !== false ? f : Infinity)(lineIntersect(i, lines[1])), from),
                dist((f => f !== false ? f : Infinity)(lineIntersect(i, lines[2])), from),
                dist((f => f !== false ? f : Infinity)(lineIntersect(i, lines[3])), from),
                dist((f => f !== false ? f : Infinity)(lineIntersect(i, lines[4])), from),
            ].filter(i => !(isNaN(i)));
            if (Math.min(...dists) === closeDist) {
                wallSide = i;
                return false;
            }
            return true;
        });
        if (wallSide[0] === closeWallSides[0][0]) {wallDir = "u";}
        else if (wallSide[0] === closeWallSides[1][0]) {wallDir = "r";}
        else if (wallSide[0] === closeWallSides[2][0]) {wallDir = "d";}
        else if (wallSide[0] === closeWallSides[3][0]) {wallDir = "l";}
        //attempt to move a point along the wall the shortest distance off the edge of the wall + 1.5 enemy size
        temp = 0;
        if (wallDir === "u") {
            //intPoint[1] = wallSide[0][1]
            intPoint[1] -= size / 2 
            if (dist(wallSide[0], to) < dist(wallSide[1], to)) {
                intPoint[0] = wallSide[0][0] - (size * 1);
            } else {
                intPoint[0] = wallSide[1][0] + (size * 1);
            }
        } else if (wallDir === "r") {
            //intPoint[1] = wallSide[0][0]
            intPoint[0] += size / 2 
            if (dist(wallSide[0], to) < dist(wallSide[1], to)) {
                intPoint[1] = wallSide[0][1] - (size * 1);
            } else {
                intPoint[1] = wallSide[1][1] + (size * 1);
            }
        } else if (wallDir === "d") {
            //intPoint[1] = wallSide[0][1]
            intPoint[1] += size / 2 
            if (dist(wallSide[0], to) < dist(wallSide[1], to)) {
                intPoint[0] = wallSide[0][0] + (size * 1);
            } else {
                intPoint[0] = wallSide[1][0] - (size * 1);
            }
        } else if (wallDir === "l") {
            //intPoint[1] = wallSide[0][0]
            intPoint[0] -= size / 2 
            if (dist(wallSide[0], to) < dist(wallSide[1], to)) {
                intPoint[1] = wallSide[0][1] + (size * 1);
            } else {
                intPoint[1] = wallSide[1][1] - (size * 1);
            }
        }
        walls.every((wall) =>{
            if (colRectLine([intPoint, intPoint], wall)) {
                if (wallDir === "u") {
                    //intPoint[1] = wallSide[0][1]
                    intPoint[1] -= size / 2 
                    if (dist(wallSide[0], intPoint) > dist(wallSide[1], intPoint)) {
                        intPoint[0] = wallSide[0][0] - (size * 1);
                    } else {
                        intPoint[0] = wallSide[1][0] + (size * 1);
                    }
                } else if (wallDir === "r") {
                    //intPoint[1] = wallSide[0][0]
                    intPoint[0] += size / 2 
                    if (dist(wallSide[0], intPoint) > dist(wallSide[1], intPoint)) {
                        intPoint[1] = wallSide[0][1] - (size * 1);
                    } else {
                        intPoint[1] = wallSide[1][1] + (size * 1);
                    }
                } else if (wallDir === "d") {
                    //intPoint[1] = wallSide[0][1]
                    intPoint[1] += size / 2 
                    if (dist(wallSide[0], intPoint) > dist(wallSide[1], intPoint)) {
                        intPoint[0] = wallSide[0][0] + (size * 1);
                    } else {
                        intPoint[0] = wallSide[1][0] - (size * 1);
                    }
                } else if (wallDir === "l") {
                    //intPoint[1] = wallSide[0][0]
                    intPoint[0] -= size / 2 
                    if (dist(wallSide[0], intPoint) > dist(wallSide[1], intPoint)) {
                        intPoint[1] = wallSide[0][1] + (size * 1);
                    } else {
                        intPoint[1] = wallSide[1][1] - (size * 1);
                    }
                }
                walls.every((wall) =>{
                    if (colRectLine([intPoint, intPoint], wall)) {
                        temp = 1;
                        return false;
                    }
                    return true
                });
                return false
            }
            return true
        });
        if (temp) {return false;}
        //set a subtarget at the point
        temp = false;
        subtargets.every((target) =>{
            if ((target[0] === intPoint[0]) && (target[1] === intPoint[1])) {
                temp = true;
                return false;
            }
            return true;
        });
        if (temp) {
            to = subtargets.pop();
            break;
        }

        //subtargets.concat(pathFind(from, intPoint, size));
        subtargets.push(intPoint);
        //repeat above but replace enemy position with last subtarget
        from = intPoint;
    }
    /*
    console.log(frameCount)
    temp = subtargets.concat([to]);
    temp.every((target) =>{
        console.log(`[${target[0]}, ${target[1]}]`);
        return true
    });
    */
    return subtargets.concat([to]);
}

function randfloat(min, max) { // min and max included 
    return Math.random() * (max - min + 1) + min;
}

function dist(p1, p2) {
    return (((p2[0] - p1[0]) ** 2) + ((p2[1] - p1[1]) ** 2)) ** 0.5;
}

function distLinePoint(line, point) {
    /*
    line [[x1, y1], [x2, y2]]
    point [x3, y3]
    line slope = (y2 - y1) / (x2 - x1) = m
    normal slope = -1 / slope

    find line equation as y = mx + b
    y - y1 = m * (x - x1)
    y - y1 = (m * x) + (-1 * m * x1)
    y = (m * x) + (-1 * m * x1) + y1
    m = slope
    line y intercept = b = (-1 * slope * x1) + y1

    find normal line equation as y = mx + b
    y = (m * x) + (-1 * m * x3) + y3
    m = slope
    normal line y intercept = b = (-1 * normal slope * x3) + y3
    
    
    find intersect point
    intersect point x = (normal slope - slope) / (normal y intercept  -  y intercept) 
    intersect point y = slope * intersect point x + line y intercept

    do dist(point, intersect point)
    */
    if ((line[1][0] - line[0][0]) === 0 || (line[1][1] - line[0][1]) === 0) {
        // rotate around line[0]
        line[1] = [
            line[0][0] + ((line[1][0] - line[0][0]) * Math.cos(pi / 4)) - ((line[1][1] - line[0][1]) * Math.sin(pi / 4)),
            line[0][1] + ((line[1][0] - line[0][0]) * Math.sin(pi / 4)) + ((line[1][1] - line[0][1]) * Math.cos(pi / 4))
        ];
        point = [
            line[0][0] + ((point[0] - line[0][0]) * Math.cos(pi / 4)) - ((point[1] - line[0][1]) * Math.sin(pi / 4)),
            line[0][1] + ((point[0] - line[0][0]) * Math.sin(pi / 4)) + ((point[1] - line[0][1]) * Math.cos(pi / 4))
        ];
    }
    let slope = (line[1][1] - line[0][1]) / (line[1][0] - line[0][0]);
    let normalSlope = -1 / slope;
    let intercept = (-1 * slope * line[0][0]) + line[0][1];
    let normalIntercept = (-1 * normalSlope * point[0]) + point[1];
    let intersect = [(normalIntercept - intercept) / (slope - normalSlope), 0];
    intersect[1] = slope * intersect[0] + intercept;
    return dist(point, intersect);

}

function colRectPoint(point, rect) {
    return ((rect[0] < point[0]) &&
    (point[0] < rect[0] + rect[2]) &&
    (rect[1] < point[1]) &&
    (point[1] < rect[1] + rect[3])
    );
}

function lineIntersect(line1, line2) {
    let x1 = line1[0][0];
    let y1 = line1[0][1];
    let x2 = line1[1][0];
    let y2 = line1[1][1];
    let x3 = line2[0][0];
    let y3 = line2[0][1];
    let x4 = line2[1][0];
    let y4 = line2[1][1];
    if ((x1 === x2 && y1 === y2) || (x3 === x4 && y3 === y4)) {
        return false
    }

    denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))

  // Lines are parallel
    if (denominator === 0) {
        return false
    }

    let ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
    let ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

  // is the intersection along the segments
    if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
        return false
    }

  // Return a object with the x and y coordinates of the intersection
    let x = x1 + ua * (x2 - x1)
    let y = y1 + ua * (y2 - y1)
    return [x, y]
}

function aStarPathFind(from, to, size) {
    console.log(frameCount);
    let grid = new  PF.Grid(screenDim[0], screenDim[1])
    let compSize = Math.ceil((size / (2 ** 0.5)) / 4);
    from = [Math.round(from[0]), Math.round(from[1])]
    to = [Math.round(to[0]), Math.round(to[1])]
    walls.forEach((wall) =>{
        for (let y = Math.max(wall[1] - compSize, 0); y < Math.min(wall[1] + wall[3] + compSize, 600); y++) {
            if (y >= 0 && y < screenDim[1]) {
                for (let x = Math.max(wall[0] - compSize, 0); x < Math.min(wall[0] + wall[2] + compSize, 800); x++) {
                    if (x >= 0 && x < screenDim[0]) {
                        grid.setWalkableAt(x, y, false);
                    }
                }
            }
        }
    }); 
    let finder = new PF.BiAStarFinder({
        allowDiagonal: true,
        dontCrossCorners: true
    });
    if (!(grid.isWalkableAt(from[0], from[1])) || !(grid.isWalkableAt(to[0], to[1]))) {return [];}
    const path = finder.findPath(from[0], from[1], to[0], to[1], grid);
    const smoothPath = PF.Util.smoothenPath(grid, path);
    return smoothPath;
    /*    
    path.forEach((point) =>{
        ctx.fillStyle = "#777700";
        ctx.fillRect(point[0], point[1], 1, 1);
    });
    let cPath = PF.Util.smoothenPath(grid, path);
    cPath.forEach((point) =>{
        ctx.fillStyle = "#770077";
        ctx.beginPath();
        ctx.arc(point[0], point[1], 5, 0, 2 * pi, true);
        ctx.fill();
    });
    */
}

function loadRoom(room) {
    curRoom = room;
    enemies.length = 0;
    walls = rooms[room[0]][room[1]].walls;
    rooms[room[0]][room[1]].spawn.forEach((entity) => {
        if (entity[0] == 0) {
            new Enemy(...entity[1])
        }
    });
}

function handleRooms() {
    if (playerData.coords[0] - (playerData.size / 2) > screenDim[0]) {
        loadRoom([curRoom[0], curRoom[1] + 1]);
        playerData.coords[0] = screenDim[0] - playerData.coords[0] + 1;
    }
    else if (playerData.coords[0] + (playerData.size / 2) < 0) {
        loadRoom([curRoom[0], curRoom[1] - 1]);
        playerData.coords[0] = screenDim[0] - playerData.coords[0] - 1;
    }
    else if (playerData.coords[1] - (playerData.size / 2) > screenDim[1]) {
        loadRoom([curRoom[0] + 1, curRoom[1]]);
        playerData.coords[1] = screenDim[1] - playerData.coords[1] + 1;
    }
    else if (playerData.coords[1] + (playerData.size / 2) < 0) {
        loadRoom([curRoom[0] - 1, curRoom[1]]);
        playerData.coords[1] = screenDim[1] - playerData.coords[1] - 1;
    }
}

function addBorder(doors) {
    let output = [];
    // [top, bottom, left right]
    if (doors[0]) {
        output = output.concat([
            [(screenDim[0] / 2) - (doorDim[0] / 2) - doorDim[1], 0, doorDim[1], (doorDim[0] / 2)],
            [(screenDim[0] / 2) + (doorDim[0] / 2), 0, doorDim[1], (doorDim[0] / 2)],
            [(screenDim[0] / 2) - (doorDim[0] / 2) - borderWidth, -doorDim[0], borderWidth, doorDim[0]],
            [(screenDim[0] / 2) - (doorDim[0] / 2), -1 * (doorDim[0] + borderWidth), doorDim[0], borderWidth],
            [(screenDim[0] / 2) + (doorDim[0] / 2), -doorDim[0], borderWidth, doorDim[0]],
            [0, -borderWidth, (screenDim[0] / 2) - (doorDim[0] / 2), borderWidth],
            [(screenDim[0] / 2) + (doorDim[0] / 2), -borderWidth, (screenDim[0] / 2) - (doorDim[0] / 2), borderWidth]
        ]);
    } else {
        output.push([0, -borderWidth, screenDim[0], borderWidth]);
    }
    if (doors[1]) {
        output = output.concat([
            [(screenDim[0] / 2) - (doorDim[0] / 2) - doorDim[1], screenDim[1] -(doorDim[0] / 2), doorDim[1], (doorDim[0] / 2)],
            [(screenDim[0] / 2) + (doorDim[0] / 2), screenDim[1] -(doorDim[0] / 2), doorDim[1], (doorDim[0] / 2)],
            [(screenDim[0] / 2) - (doorDim[0] / 2) - borderWidth, screenDim[1], borderWidth, doorDim[0]],
            [(screenDim[0] / 2) - (doorDim[0] / 2), doorDim[0] + screenDim[1], doorDim[0], borderWidth],
            [(screenDim[0] / 2) + (doorDim[0] / 2), screenDim[1], borderWidth, doorDim[0]],
            [0, screenDim[1], (screenDim[0] / 2) - (doorDim[0] / 2), borderWidth],
            [(screenDim[0] / 2) + (doorDim[0] / 2), screenDim[1], (screenDim[0] / 2) - (doorDim[0] / 2), borderWidth]
        ]);
    } else {
        output.push([0, screenDim[1], screenDim[0], borderWidth]);
    }
    if (doors[2]) {
        output = output.concat([
            [0, (screenDim[1] / 2) - (doorDim[0] / 2) - doorDim[1], doorDim[0] / 2, doorDim[1]],
            [0, (screenDim[1] / 2) + (doorDim[0] / 2) - doorDim[1], doorDim[0] / 2, doorDim[1]],
            [-doorDim[0], (screenDim[1] / 2) - (doorDim[0] / 2) - borderWidth, doorDim[0], borderWidth],
            [-1 * (doorDim[0] + borderWidth), (screenDim[1] / 2) - (doorDim[0] / 2), borderWidth, doorDim[0]],
            [-doorDim[0], (screenDim[1] / 2) + (doorDim[0] / 2), doorDim[0], borderWidth],
            [-borderWidth, 0, borderWidth, (screenDim[1] / 2) - (doorDim[0] / 2)],
            [-borderWidth, (screenDim[1] / 2) + (doorDim[0] / 2), borderWidth, (screenDim[1] / 2) - (doorDim[0] / 2)]
        ]);
    } else {
        output.push([-borderWidth, 0, borderWidth, screenDim[1]]);
    }
    if (doors[3]) {
        output = output.concat([
            [screenDim[0] - (doorDim[0] / 2), (screenDim[1] / 2) - (doorDim[0] / 2) - doorDim[1], doorDim[0] / 2, doorDim[1]],
            [screenDim[0] - (doorDim[0] / 2), (screenDim[1] / 2) + (doorDim[0] / 2) - doorDim[1], doorDim[0] / 2, doorDim[1]],
            [screenDim[0], (screenDim[1] / 2) - (doorDim[0] / 2) - borderWidth, doorDim[0], borderWidth],
            [screenDim[0] + doorDim[0], (screenDim[1] / 2) - (doorDim[0] / 2), borderWidth, doorDim[0]],
            [screenDim[0], (screenDim[1] / 2) + (doorDim[0] / 2), doorDim[0], borderWidth],
            [-borderWidth, 0, borderWidth, (screenDim[1] / 2) - (doorDim[0] / 2)],
            [screenDim[0], 0, borderWidth, (screenDim[1] / 2) - (doorDim[0] / 2)],
            [screenDim[0], (screenDim[1] / 2) + (doorDim[0] / 2), borderWidth, (screenDim[1] / 2) - (doorDim[0] / 2)]
        ]);
    } else {
        output.push([screenDim[0], 0, borderWidth, screenDim[1]]);
    }
    return output;
}

function generateFloor() {
    const pathLen = 1000;
    let dir
    let curIndex = [0, 0];
    let dim = [1, 1];
    let grid = [[1]];
    rooms = [[{
        walls : [],
        borders : [false, false, false, false],
        spawn : [],
        layout : 0
    }]];
    let dirs = [];
    // up down left right
    //lenth of path start to end
    for (let c = 0; c < pathLen; c++) {
        let dir = Math.floor(randfloat(0, 3));
        dirs.push(dir);
        if (dir == 0) {
            rooms[curIndex[0]][curIndex[1]].borders[0] = true;
            curIndex[0]--;
            if (curIndex[0] == -1) {
                grid.unshift([]);
                rooms.unshift([]);
                curIndex[0]++;
                for (let i = 0; i < dim[0]; i++) {
                    grid[0].push(0);
                    rooms[0].push({
                        borders : [false, false, false, false],
                        spawn : []
                    });
                }
                dim[1]++;
                curRoom[0]++;
            }
            grid[curIndex[0]][curIndex[1]] = 1;
            rooms[curIndex[0]][curIndex[1]].borders[1] = true;
        }
        else if (dir == 1) {
            rooms[curIndex[0]][curIndex[1]].borders[1] = true;
            curIndex[0]++;
            if (curIndex[0] == dim[1]) {
                grid.push([]);
                rooms.push([]);
                for (let i = 0; i < dim[0]; i++) {
                    grid[grid.length - 1].push(0);
                    rooms[rooms.length - 1].push({
                        borders : [false, false, false, false],
                        spawn : []
                    });
                }
                dim[1]++;
            }
            grid[curIndex[0]][curIndex[1]] = 1;
            rooms[curIndex[0]][curIndex[1]].borders[0] = true;
        }
        else if (dir == 2) {
            rooms[curIndex[0]][curIndex[1]].borders[2] = true;
            curIndex[1]--;
            if (curIndex[1] == -1) {
                curIndex[1]++;
                for (let i = 0; i < dim[1]; i++) {
                    grid[i].unshift(0);
                    rooms[i].unshift({
                        borders : [false, false, false, false],
                        spawn : []
                    });
                }
                dim[0]++;
                curRoom[1]++;
            }
            grid[curIndex[0]][curIndex[1]] = 1;
            rooms[curIndex[0]][curIndex[1]].borders[3] = true;
        }
        else if (dir == 3) {
            rooms[curIndex[0]][curIndex[1]].borders[3] = true;
            curIndex[1]++;
            if (curIndex[1] == dim[0]) {
                for (let i = 0; i < dim[1]; i++) {
                    grid[i].push(0);
                    rooms[i].push({
                        borders : [false, false, false, false],
                        spawn : []
                    });
                }
                dim[0]++;
            }
            grid[curIndex[0]][curIndex[1]] = 1;
            rooms[curIndex[0]][curIndex[1]].borders[2] = true;
        }
    }
    grid[curRoom[0]][curRoom[1]] = 8;
    /*
    console.log(dirs)
    console.log(grid)
    console.log(rooms)
    */
    rooms.forEach((row) =>{
        row.forEach((room) =>{
            room.walls = addBorder(room.borders);
            let enemyCount = Math.floor(randfloat(0, 5));
            for (let e = 0; e < enemyCount; e++) {room.spawn.push([0, [[randfloat(0, screenDim[0]), randfloat(0, screenDim[1])], 4]]);}
            if ('layout' in room) {
                if (room.layout == 0) {
                    room.walls = room.walls.concat([
                        [325, 250, 30, 180],
                        [325, 400, 150, 30]
                    ]);
                }
            }
        });
    });
}
init();