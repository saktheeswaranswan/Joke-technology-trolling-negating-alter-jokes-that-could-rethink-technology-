// 3D Wet Grinder Driven by Sangu Chakkaram for APDE
float chakkaramAngle = 0;
float drumAngle = 0;
float stoneSpinAngle = 0;

// State control
int STATE_IDLE = 0;
int STATE_IGNITING = 1;
int STATE_RUNNING = 2;
int currentState = STATE_IDLE;

// Timing & Animation
int igniteTimer = 0;
float mathappuOffset = 100; // Used to animate the sparkler moving in/out

// Camera control variables
float camRotX = PI / 4; 
float camRotZ = 0;

// UI Button bounds
int btnW = 160;
int btnH = 65;
int btnStartX = 0;
int btnStartY = 0;
int btnStopX = 0;
int btnStopY = 0;

// Particle System for Sparks
ArrayList<Spark> sparks = new ArrayList<Spark>();

void setup() {
  fullScreen(P3D); 
  orientation(LANDSCAPE);
  noStroke();
}

void draw() {
  // Dark background to make sparks visible (Night mode)
  background(15, 20, 25);
  
  // 3D Lighting setup for night time
  lights();
  directionalLight(180, 180, 200, 0.5, 0.5, -1);
  ambientLight(50, 50, 60);
  
  // Update UI Button Positions (Bottom Left)
  btnW = max(width / 5, 160);
  btnStartX = 40;
  btnStartY = height - btnH - 40;
  btnStopX = btnStartX + btnW + 20;
  btnStopY = height - btnH - 40;
  
  // Auto-pan if not interacting
  if (!mousePressed) {
    camRotZ -= 0.005; 
  }
  
  // ---------------------------------------------------------
  // Mechanics & State Machine Updates
  // ---------------------------------------------------------
  float driveSpeed = 0.55; // Speed of the spinning firework
  float pulleyRatio = 40.0 / 140.0; // Small chakkaram pulley to large drum pulley
  float drumSpeed = driveSpeed * pulleyRatio;
  
  if (currentState == STATE_IGNITING) {
    igniteTimer++;
    // Bring Kambi Mathappu down
    mathappuOffset = lerp(mathappuOffset, 0, 0.1); 
    spawnSparklerSparks();
    
    if (igniteTimer > 100) {
      currentState = STATE_RUNNING;
    }
  } 
  else if (currentState == STATE_RUNNING) {
    // Move Kambi Mathappu away
    mathappuOffset = lerp(mathappuOffset, 150, 0.1); 
    
    // Drive mechanics
    chakkaramAngle += driveSpeed;
    drumAngle += drumSpeed;
    stoneSpinAngle += drumSpeed * 2.6; 
    
    spawnChakkaramSparks();
  }
  else if (currentState == STATE_IDLE) {
    // Reset sparkler position
    mathappuOffset = lerp(mathappuOffset, 150, 0.1); 
  }
  
  // ---------------------------------------------------------
  // 3D Rendering Context
  // ---------------------------------------------------------
  pushMatrix();
  translate(width / 2, height / 2, -200);
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  drawChassis3D();
  drawPulleysAndBelt3D();
  drawSanguChakkaram3D();
  drawDrumAndStones3D();
  
  if (currentState == STATE_IGNITING || mathappuOffset < 140) {
    drawKambiMathappu3D();
  }
  
  // Render Sparks (Lights disabled so they glow bright)
  hint(DISABLE_DEPTH_TEST);
  noLights();
  for (int i = sparks.size() - 1; i >= 0; i--) {
    Spark s = sparks.get(i);
    s.update();
    s.display();
    if (s.isDead()) {
      sparks.remove(i);
    }
  }
  hint(ENABLE_DEPTH_TEST);
  
  popMatrix();
  
  // ---------------------------------------------------------
  // 2D UI Overlay 
  // ---------------------------------------------------------
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights(); 
  
  fill(200);
  textSize(35);
  textAlign(LEFT, TOP);
  text("Firework-Powered Grinder\nDrag screen to rotate view", 40, 40);
  
  // Status Text
  textAlign(LEFT, CENTER);
  textSize(24);
  if (currentState == STATE_RUNNING) {
    fill(255, 150, 0); 
    text("STATUS: FIREWORK BURNING", btnStartX, btnStartY - 25);
  } else if (currentState == STATE_IGNITING) {
    fill(200, 200, 100); 
    text("STATUS: IGNITING...", btnStartX, btnStartY - 25);
  } else {
    fill(150, 150, 150); 
    text("STATUS: WAITING", btnStartX, btnStartY - 25);
  }
  
  // LIGHT IT Button
  rectMode(CORNER);
  if (currentState != STATE_IDLE) fill(100, 100, 100); 
  else fill(200, 100, 40); 
  rect(btnStartX, btnStartY, btnW, btnH, 10);
  
  // STOP Button
  if (currentState == STATE_IDLE) fill(100, 100, 100); 
  else fill(180, 50, 50); 
  rect(btnStopX, btnStopY, btnW, btnH, 10);
  
  // Labels
  textAlign(CENTER, CENTER);
  textSize(26);
  fill(255);
  text("LIGHT IT", btnStartX + btnW/2, btnStartY + btnH/2 - 3);
  text("DOUSE", btnStopX + btnW/2, btnStopY + btnH/2 - 3);
  
  hint(ENABLE_DEPTH_TEST);
}

// ---------------------------------------------------------
// Input Handling
// ---------------------------------------------------------
void mousePressed() {
  if (mouseX > btnStartX && mouseX < btnStartX + btnW && mouseY > btnStartY && mouseY < btnStartY + btnH) {
    if (currentState == STATE_IDLE) {
      currentState = STATE_IGNITING;
      igniteTimer = 0;
    }
  }
  else if (mouseX > btnStopX && mouseX < btnStopX + btnW && mouseY > btnStopY && mouseY < btnStopY + btnH) {
    currentState = STATE_IDLE;
  }
}

void mouseDragged() {
  if (!(mouseX > btnStartX - 20 && mouseX < btnStopX + btnW + 20 && mouseY > btnStartY - 60 && mouseY < btnStopY + btnH + 20)) {
    camRotZ += (mouseX - pmouseX) * 0.01;
    camRotX += (pmouseY - mouseY) * 0.01;
    camRotX = constrain(camRotX, 0, PI/2.2); 
  }
}

// ---------------------------------------------------------
// Particle System (Sparks)
// ---------------------------------------------------------
class Spark {
  PVector pos, vel;
  float life, lifeSpan;
  color c;
  
  Spark(float x, float y, float z, float vx, float vy, float vz, color c_) {
    pos = new PVector(x, y, z);
    vel = new PVector(vx, vy, vz);
    this.c = c_;
    life = 255;
    lifeSpan = random(15, 40);
  }
  
  void update() {
    pos.add(vel);
    vel.z -= 0.15; // Gravity (pulls towards negative Z which is down here)
    vel.x *= 0.96; // Air resistance
    vel.y *= 0.96;
    life -= (255.0 / lifeSpan);
  }
  
  void display() {
    stroke(c, life);
    strokeWeight(random(3, 7)); // Twinkling effect
    point(pos.x, pos.y, pos.z);
  }
  
  boolean isDead() {
    return life <= 0 || pos.z < -20;
  }
}

void spawnSparklerSparks() {
  for(int i = 0; i < 3; i++) {
    // Tip of the Mathappu
    float px = 150 + random(-5, 5);
    float py = -30 + random(-5, 5);
    float pz = 45 + mathappuOffset; 
    
    float vx = random(-1, 1);
    float vy = random(-1, 1);
    float vz = random(-3, -1);
    
    color sparkColor = color(255, random(200, 255), random(100, 200));
    sparks.add(new Spark(px, py, pz, vx, vy, vz, sparkColor));
  }
}

void spawnChakkaramSparks() {
  // Erupt massive sparks radially outward
  for(int i = 0; i < 12; i++) {
    float r = 40;
    // Base emission angle on current rotation for a spiral tail effect
    float angle = chakkaramAngle + random(-0.5, 0.5); 
    float px = 150 + r * cos(angle);
    float py = r * sin(angle);
    float pz = 50 + random(-2, 2); 
    
    // Sparks shoot outward tangentially and upwards
    float speed = random(6, 12);
    float vx = -sin(angle) * speed + cos(angle) * (speed * 0.3);
    float vy = cos(angle) * speed + sin(angle) * (speed * 0.3);
    float vz = random(0, 5);
    
    color sparkColor = color(255, random(100, 220), 0);
    if (random(1) < 0.1) sparkColor = color(255, 255, 255); // occasional white-hot spark
    
    sparks.add(new Spark(px, py, pz, vx, vy, vz, sparkColor));
  }
}

// ---------------------------------------------------------
// Mechanics Draw Methods
// ---------------------------------------------------------
void drawChassis3D() {
  fill(120, 20, 30); 
  
  // Left Drum Base 
  pushMatrix(); 
  translate(-150, 0, 0); 
  drawCylinder(160, 30, 48, true, true); 
  popMatrix();
  
  // Right Firework Base
  pushMatrix(); 
  translate(150, 0, 0); 
  drawCylinder(100, 30, 36, true, true); 
  popMatrix();
  
  pushMatrix();
  translate(0, 0, 15);
  box(300, 180, 30);
  popMatrix();
}

void drawPulleysAndBelt3D() {
  float rd = 140; 
  float rc = 40;  // Chakkaram drive pulley
  float d = 300;  
  float theta = asin((rd - rc) / d);
  float baseZ = 35; 
  float pHeight = 12; 
  
  drawBelt3D(rd, rc, theta, baseZ, pHeight);
  
  // Drum Pulley
  pushMatrix();
  translate(-150, 0, baseZ);
  rotateZ(drumAngle);
  fill(50); 
  drawCylinder(rd, pHeight, 48, true, true);
  // Spokes
  pushMatrix(); 
  translate(0, 0, pHeight/2 + 1); 
  fill(30); 
  box(rd*1.9, 15, 6); 
  box(15, rd*1.9, 6); 
  popMatrix();
  popMatrix();
  
  // Drive Pulley (Directly under the Chakkaram)
  pushMatrix();
  translate(150, 0, baseZ);
  rotateZ(chakkaramAngle);
  fill(150);
  drawCylinder(rc, pHeight, 24, true, true);
  popMatrix();
}

void drawBelt3D(float rd, float rm, float theta, float z, float h) {
  fill(15); 
  beginShape(QUAD_STRIP);
  int steps = 18;
  
  float startA = HALF_PI - theta;
  float endA = TWO_PI - HALF_PI + theta;
  for(int i = 0; i <= steps; i++) {
    float a = map(i, 0, steps, startA, endA);
    float px = -150 + rd * cos(a);
    float py = rd * sin(a);
    vertex(px, py, z); vertex(px, py, z + h);
  }
  
  float startB = -HALF_PI + theta;
  float endB = HALF_PI - theta;
  for(int i = 0; i <= steps; i++) {
    float a = map(i, 0, steps, startB, endB);
    float px = 150 + rm * cos(a);
    float py = rm * sin(a);
    vertex(px, py, z); vertex(px, py, z + h);
  }
  
  float px0 = -150 + rd * cos(startA);
  float py0 = rd * sin(startA);
  vertex(px0, py0, z); vertex(px0, py0, z + h);
  endShape();
}

// ---------------------------------------------------------
// Fireworks Objects
// ---------------------------------------------------------
void drawSanguChakkaram3D() {
  pushMatrix();
  // Sits directly on top of the right pulley
  translate(150, 0, 48); 
  rotateZ(chakkaramAngle);
  
  // Chakkaram Base Disc
  fill(180, 80, 30); // Clay brownish-red
  drawCylinder(45, 10, 36, true, true);
  
  // Inner fuel spiral detail
  fill(80, 80, 80);
  pushMatrix();
  translate(0, 0, 10);
  drawCylinder(35, 2, 24, true, true);
  fill(200, 180, 100); // Fuse dot center
  translate(0, 0, 2);
  drawCylinder(5, 2, 12, true, true);
  popMatrix();
  
  popMatrix();
}

void drawKambiMathappu3D() {
  pushMatrix();
  // Positioned diagonally pointing at the Chakkaram center
  translate(150, -30, 45 + mathappuOffset);
  rotateX(-PI/4);
  
  // Bare wire handle
  fill(100);
  drawCylinder(2, 60, 8, true, true);
  
  // Coated sparkler chemical tip
  translate(0, 0, 60);
  fill(50, 50, 55);
  drawCylinder(5, 50, 12, true, true);
  
  popMatrix();
}

// ---------------------------------------------------------
// Stainless Steel Drum & Granite Rolling Stones
// ---------------------------------------------------------
void drawDrumAndStones3D() {
  pushMatrix();
  translate(-150, 0, 50); 
  rotateZ(drumAngle); 
  
  // Outer Steel Wall
  fill(160, 170, 180);
  drawCylinder(120, 95, 48, true, false);
  
  // Inner Floor & Batter 
  pushMatrix();
  translate(0, 0, 2); 
  fill(50, 55, 60); 
  drawCylinder(115, 6, 48, true, true);
  
  translate(0, 0, 6);
  fill(230, 235, 220); // Batter paste
  drawCylinder(115, 35, 48, true, true);
  popMatrix();
  popMatrix();

  // Stationary Center Pillar & Spider
  pushMatrix();
  translate(-150, 0, 50); 
  
  fill(245, 245, 250);
  pushMatrix();
  translate(0, 0, 8);
  drawCylinder(35, 55, 36, true, true);
  popMatrix();
  
  fill(150);
  pushMatrix();
  translate(0, 0, 63);
  drawCylinder(15, 12, 24, true, true);
  popMatrix();
  
  // Horizontal Axle Arms 
  fill(120);
  pushMatrix(); translate(-44, 0, 32); box(62, 10, 10); popMatrix();
  pushMatrix(); translate(44, 0, 32); box(62, 10, 10); popMatrix();

  // Rolling Stones
  pushMatrix(); translate(-44, 0, 32); rotateX(stoneSpinAngle); drawStone(); popMatrix();
  pushMatrix(); translate(44, 0, 32); rotateX(-stoneSpinAngle); drawStone(); popMatrix();
  popMatrix(); 
}

void drawStone() {
  float r = 32; 
  float h = 50; 
  pushMatrix();
  rotateY(HALF_PI);
  translate(0, 0, -h/2);
  
  fill(80, 85, 90);
  drawCylinder(r, h, 36, true, true);
  
  fill(40, 45, 50);
  for(float zOffset = -h*0.3; zOffset <= h*0.3; zOffset += h*0.3) {
    pushMatrix();
    translate(0, 0, zOffset + h/2);
    drawCylinder(r * 1.01, 6, 36, false, false);
    popMatrix();
  }
  
  fill(200);
  translate(0, 0, 0);
  drawCylinder(9, h + 2, 24, true, true);
  popMatrix();
}

// ---------------------------------------------------------
// Helper: 3D Cylinder Generator
// ---------------------------------------------------------
void drawCylinder(float r, float h, int sides, boolean capBottom, boolean capTop) {
  float angle = TWO_PI / sides;
  
  if (capBottom) {
    beginShape(POLYGON); 
    for (int i = sides; i >= 0; i--) vertex(r * cos(i * angle), r * sin(i * angle), 0);
    endShape(CLOSE);
  }
  if (capTop) {
    beginShape(POLYGON); 
    for (int i = 0; i <= sides; i++) vertex(r * cos(i * angle), r * sin(i * angle), h);
    endShape(CLOSE);
  }
  
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float x = r * cos(i * angle);
    float y = r * sin(i * angle);
    vertex(x, y, 0);
    vertex(x, y, h);
  }
  endShape();
}
