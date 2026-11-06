// 3D Direct-Drive Firework Wet Grinder for APDE
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
float mathappuOffset = 100; 

// Camera control variables
float camRotX = PI / 3.5; 
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
  // Dark background for intense night-mode glow
  background(10, 12, 15);
  
  // 3D Lighting setup
  lights();
  directionalLight(180, 180, 200, 0.5, 0.5, -1);
  ambientLight(50, 50, 60);
  
  // Update UI Button Positions
  btnW = max(width / 5, 160);
  btnStartX = 40;
  btnStartY = height - btnH - 40;
  btnStopX = btnStartX + btnW + 20;
  btnStopY = height - btnH - 40;
  
  // Auto-pan camera slowly if not interacting
  if (!mousePressed) {
    camRotZ -= 0.003; 
  }
  
  // ---------------------------------------------------------
  // Mechanics & State Machine Updates
  // ---------------------------------------------------------
  float driveSpeed = 0.65; // Extremely fast spin
  
  if (currentState == STATE_IGNITING) {
    igniteTimer++;
    mathappuOffset = lerp(mathappuOffset, 0, 0.1); 
    spawnSparklerSparks();
    
    if (igniteTimer > 100) {
      currentState = STATE_RUNNING;
    }
  } 
  else if (currentState == STATE_RUNNING) {
    mathappuOffset = lerp(mathappuOffset, 150, 0.1); 
    
    // Direct Drive Mechanics (1:1 Ratio)
    chakkaramAngle += driveSpeed;
    drumAngle = chakkaramAngle; 
    stoneSpinAngle += driveSpeed * 2.6; 
    
    spawnChakkaramSparks(); // Erupt sparks!
  }
  else if (currentState == STATE_IDLE) {
    mathappuOffset = lerp(mathappuOffset, 150, 0.1); 
  }
  
  // ---------------------------------------------------------
  // 3D Rendering Context
  // ---------------------------------------------------------
  pushMatrix();
  translate(width / 2, height / 2 + 50, -200);
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  drawFloorBase3D();
  drawSanguChakkaram3D();
  drawDrumAndStones3D();
  
  if (currentState == STATE_IGNITING || mathappuOffset < 140) {
    drawKambiMathappu3D();
  }
  
  // Render Sparks as bright, glowing streaks
  hint(DISABLE_DEPTH_TEST);
  noLights(); // Turn off 3D lights so sparks are purely emissive/bright
  blendMode(ADD); // Additive blending makes overlapping sparks glow intense white
  
  for (int i = sparks.size() - 1; i >= 0; i--) {
    Spark s = sparks.get(i);
    s.update();
    s.display();
    if (s.isDead()) {
      sparks.remove(i);
    }
  }
  
  blendMode(BLEND); // Reset blend mode for UI
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
  text("Intense Firework Grinder\nDrag screen to rotate view", 40, 40);
  
  // Status Text
  textAlign(LEFT, CENTER);
  textSize(24);
  if (currentState == STATE_RUNNING) {
    fill(255, 150, 0); 
    text("STATUS: FULL THROTTLE", btnStartX, btnStartY - 25);
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
// Particle System (Streak Sparks)
// ---------------------------------------------------------
class Spark {
  PVector pos, vel;
  float life, lifeSpan;
  color c;
  float weight;
  
  Spark(float x, float y, float z, float vx, float vy, float vz, color c_) {
    pos = new PVector(x, y, z);
    vel = new PVector(vx, vy, vz);
    this.c = c_;
    life = 255;
    lifeSpan = random(10, 35);
    weight = random(1, 4);
  }
  
  void update() {
    pos.add(vel);
    vel.z -= 0.3; // Gravity pulling sparks down slightly
    vel.x *= 0.98; // Very slight air resistance
    vel.y *= 0.98;
    life -= (255.0 / lifeSpan);
  }
  
  void display() {
    stroke(c, life);
    strokeWeight(weight);
    // Draw a streak line based on velocity backwards
    // Multiplier dictates how long the streak looks
    float streakLength = 2.5; 
    line(pos.x, pos.y, pos.z, pos.x - vel.x * streakLength, pos.y - vel.y * streakLength, pos.z - vel.z * streakLength);
  }
  
  boolean isDead() {
    return life <= 0 || pos.z < -20;
  }
}

void spawnSparklerSparks() {
  for(int i = 0; i < 4; i++) {
    float px = random(-5, 5);
    float py = random(-5, 5);
    float pz = 18 + mathappuOffset; 
    float vx = random(-2, 2);
    float vy = random(-2, 2);
    float vz = random(-4, -1);
    color sparkColor = color(255, random(220, 255), random(150, 255));
    sparks.add(new Spark(px, py, pz, vx, vy, vz, sparkColor));
  }
}

void spawnChakkaramSparks() {
  // Erupt massive sparks radially outward from the CENTER, not the edge
  for(int i = 0; i < 25; i++) { // Lots of sparks per frame
    float r = random(20, 45); // Originating from the bright center ring
    float angle = chakkaramAngle + random(-PI, PI); 
    
    float px = r * cos(angle);
    float py = r * sin(angle);
    float pz = 18 + random(-2, 2); // Erupt from top surface of firework
    
    // Very high velocity to create long streaks flying far away
    float speed = random(15, 45);
    float vx = cos(angle) * speed + random(-2, 2);
    float vy = sin(angle) * speed + random(-2, 2);
    float vz = random(-2, 8); // Shooting slightly upwards and outwards
    
    // Color mixing: White hot, bright yellow, and intense orange
    color sparkColor;
    float randCol = random(1);
    if (randCol < 0.3) sparkColor = color(255, 255, 255); // White
    else if (randCol < 0.7) sparkColor = color(255, 220, 100); // Yellow
    else sparkColor = color(255, 130, 30); // Orange
    
    sparks.add(new Spark(px, py, pz, vx, vy, vz, sparkColor));
  }
}

// ---------------------------------------------------------
// Mechanics Draw Methods
// ---------------------------------------------------------
void drawFloorBase3D() {
  fill(40, 45, 50); 
  pushMatrix(); 
  translate(0, 0, -5); 
  drawCylinder(200, 5, 48, true, true); // Larger floor to catch sparks
  popMatrix();
}

void drawSanguChakkaram3D() {
  pushMatrix();
  translate(0, 0, 0);  
  rotateZ(chakkaramAngle);
  
  // Outer Red Ring (Like the Kaniskarp image)
  fill(180, 30, 30); 
  drawCylinder(135, 18, 48, true, false);
  
  // Middle Green Ring
  pushMatrix();
  translate(0, 0, 0.1); // Prevent Z-fighting
  fill(40, 160, 60);
  drawCylinder(110, 18, 48, false, true);
  popMatrix();
  
  // Inner Yellow Ring
  pushMatrix();
  translate(0, 0, 0.2); 
  fill(220, 190, 30);
  drawCylinder(70, 18, 36, false, true);
  popMatrix();
  
  // Core Fuse Area
  pushMatrix();
  translate(0, 0, 18.3);
  fill(80, 80, 80);
  drawCylinder(30, 1, 24, true, true); // Ashy center
  fill(200, 180, 100); 
  translate(0, 0, 1);
  drawCylinder(8, 2, 12, true, true); // Wick
  popMatrix();
  
  // If running, draw the intense glowing center ring
  if (currentState == STATE_RUNNING) {
    pushMatrix();
    translate(0, 0, 19);
    noLights();
    hint(DISABLE_DEPTH_TEST);
    blendMode(ADD);
    
    // Core white hot center
    fill(255, 255, 220, 200);
    drawCylinder(25, 4, 36, true, true);
    
    // Outer yellow-orange glow ring
    fill(255, 150, 20, 120);
    drawCylinder(45, 6, 36, true, true);
    
    blendMode(BLEND);
    hint(ENABLE_DEPTH_TEST);
    lights(); // Re-enable for the drum
    popMatrix();
  }
  
  popMatrix();
}

void drawKambiMathappu3D() {
  pushMatrix();
  translate(80, -80, 60 + mathappuOffset);
  rotateX(-PI/4);
  rotateY(-PI/4);
  
  fill(100);
  drawCylinder(2, 60, 8, true, true);
  
  translate(0, 0, 60);
  fill(50, 50, 55);
  drawCylinder(5, 50, 12, true, true);
  
  popMatrix();
}

// ---------------------------------------------------------
// Stainless Steel Drum & Granite Rolling Stones
// ---------------------------------------------------------
void drawDrumAndStones3D() {
  float drumBaseZ = 22; 

  // A. Rotating Outer Steel Drum 
  pushMatrix();
  translate(0, 0, drumBaseZ); 
  rotateZ(drumAngle); 
  
  fill(160, 170, 180);
  drawCylinder(120, 95, 48, true, false);
  
  pushMatrix();
  translate(0, 0, 2); 
  fill(50, 55, 60); 
  drawCylinder(115, 6, 48, true, true);
  
  translate(0, 0, 6);
  fill(230, 235, 220); 
  drawCylinder(115, 35, 48, true, true);
  popMatrix();
  popMatrix();

  // B. Stationary Center Pillar & Spider 
  pushMatrix();
  translate(0, 0, drumBaseZ); 
  
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
  
  fill(120);
  pushMatrix(); translate(-44, 0, 32); box(62, 10, 10); popMatrix();
  pushMatrix(); translate(44, 0, 32); box(62, 10, 10); popMatrix();

  // C. Rolling Stones 
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
