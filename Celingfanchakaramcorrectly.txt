// 3D Ceiling Fan with Sangu Chakram Simulation for APDE
float fanAngle = 0;

// State control
boolean isRunning = false;

// Camera control variables
float camRotX = PI / 2.5; // Angled slightly down
float camRotZ = 0;

// Particle System for Sangu Chakram Sparks
ArrayList<Spark> sparks;

// Separate Button bounds (Global variables, updated dynamically in draw)
int btnW = 140;
int btnH = 65;
int btnStartX = 0;
int btnStartY = 0;
int btnStopX = 0;
int btnStopY = 0;

void setup() {
  fullScreen(P3D); 
  orientation(LANDSCAPE);
  noStroke();
  
  sparks = new ArrayList<Spark>();
}

void draw() {
  // Dark night background to make the firework sparks glow
  background(15, 20, 25);
  
  // Update UI Button Positions (Bottom Left)
  btnW = width / 6; 
  if (btnW < 130) btnW = 130;
  
  btnStartX = 40;
  btnStartY = height - btnH - 40;
  
  btnStopX = btnStartX + btnW + 20;
  btnStopY = height - btnH - 40;
  
  // Auto-pan if not interacting
  if (!mousePressed) {
    camRotZ -= 0.003; 
  }
  
  // ---------------------------------------------------------
  // 3D Rendering Context
  // ---------------------------------------------------------
  pushMatrix();
  translate(width / 2, height / 2 - 50, -200);
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  // Scale dynamically for screen size
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  // 3D Lighting setup for Fan Models
  lights();
  directionalLight(255, 250, 240, 0.5, 0.5, -1);
  ambientLight(100, 100, 100);
  
  // Update Physics & Spark Emission
  if (isRunning) {
    fanAngle += 0.45; // Fast spin
    
    // Ignite Sangu Chakram: Emit high-velocity sparks radially
    for (int i = 0; i < 20; i++) { // Density of sparks
      float randAngle = fanAngle + random(TWO_PI);
      // Spawn at the rim of the Chakram (Z = 35)
      sparks.add(new Spark(cos(randAngle) * 20, sin(randAngle) * 20, 35, randAngle));
    }
  }
  
  // Draw Fan and Chakram bodies
  drawCeilingFan3D();
  
  // Disable lights to render bright, self-illuminated glowing sparks
  noLights(); 
  
  // Render Particle System
  for (int i = sparks.size() - 1; i >= 0; i--) {
    Spark s = sparks.get(i);
    s.update();
    s.display();
    if (s.life <= 0) {
      sparks.remove(i);
    }
  }
  
  popMatrix();
  
  // ---------------------------------------------------------
  // 2D UI Overlay (Separated Buttons)
  // ---------------------------------------------------------
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights(); 
  
  // Top Left Title
  fill(220);
  textSize(35);
  textAlign(LEFT, TOP);
  text("3D Fan + Sangu Chakram Firework\nDrag screen to rotate view", 40, 40);
  
  // Status Text Indicator
  textAlign(LEFT, CENTER);
  textSize(24);
  if (isRunning) {
    fill(40, 220, 80); 
    text("STATUS: IGNITED & SPINNING", btnStartX, btnStartY - 25);
  } else {
    fill(220, 60, 60); 
    text("STATUS: STOPPED", btnStartX, btnStartY - 25);
  }
  
  // Draw START Button
  rectMode(CORNER);
  if (isRunning) {
    fill(100, 220, 120); 
  } else {
    fill(40, 140, 60);   
  }
  rect(btnStartX, btnStartY, btnW, btnH, 10);
  
  // Draw STOP Button
  if (!isRunning) {
    fill(220, 80, 80);   
  } else {
    fill(140, 40, 40);   
  }
  rect(btnStopX, btnStopY, btnW, btnH, 10);
  
  // Button Labels
  textAlign(CENTER, CENTER);
  textSize(28);
  fill(255);
  text("START", btnStartX + btnW/2, btnStartY + btnH/2 - 3);
  text("STOP", btnStopX + btnW/2, btnStopY + btnH/2 - 3);
  
  hint(ENABLE_DEPTH_TEST);
}

// ---------------------------------------------------------
// Input Handling
// ---------------------------------------------------------
void mousePressed() {
  if (mouseX > btnStartX && mouseX < btnStartX + btnW && mouseY > btnStartY && mouseY < btnStartY + btnH) {
    isRunning = true;
  }
  else if (mouseX > btnStopX && mouseX < btnStopX + btnW && mouseY > btnStopY && mouseY < btnStopY + btnH) {
    isRunning = false;
  }
}

void mouseDragged() {
  // Only rotate camera if dragging OUTSIDE the buttons
  if (!(mouseX > btnStartX - 20 && mouseX < btnStopX + btnW + 20 && mouseY > btnStartY - 60 && mouseY < btnStopY + btnH + 20)) {
    camRotZ += (mouseX - pmouseX) * 0.01;
    camRotX += (pmouseY - mouseY) * 0.01;
    camRotX = constrain(camRotX, 0, PI/1.5); 
  }
}

// ---------------------------------------------------------
// 3D Ceiling Fan Drawing (Bajaj Brown reference)
// ---------------------------------------------------------
void drawCeilingFan3D() {
  noStroke();
  
  // Stationary Ceiling Mount & Downrod
  pushMatrix();
  translate(0, 0, -120);
  
  // Ceiling Bell / Canopy
  fill(210, 180, 130);
  drawCylinder(25, 20, 24, true, true);
  
  // Steel Rod connecting to Fan
  translate(0, 0, 20);
  fill(150);
  drawCylinder(6, 100, 12, true, true);
  popMatrix();
  
  // Rotating Fan Assembly
  pushMatrix();
  rotateZ(fanAngle);
  
  // Main Central Motor Hub (Gold/Bronze)
  fill(200, 170, 110); 
  drawCylinder(45, 25, 36, true, true);
  
  pushMatrix();
  translate(0, 0, 25);
  drawCylinder(40, 5, 36, true, true); // Lower decorative rim
  popMatrix();
  
  // 3 Fan Blades (Dark Brown)
  fill(90, 55, 35); 
  for (int i = 0; i < 3; i++) {
    pushMatrix();
    rotateZ(i * TWO_PI / 3);
    translate(140, 0, 12); // Distance from center
    rotateX(-0.15); // Slight pitch angle for airflow
    box(220, 45, 3); // Blade length, width, thickness
    popMatrix();
  }
  
  // Sangu Chakram attached directly underneath the center hub
  pushMatrix();
  translate(0, 0, 30); 
  drawSanguChakram3D();
  popMatrix();
  
  popMatrix();
}

// ---------------------------------------------------------
// Sangu Chakram Firework Drawing (Kaniskarp reference)
// ---------------------------------------------------------
void drawSanguChakram3D() {
  // Outer Green wrapper
  fill(30, 160, 60); 
  drawCylinder(22, 5, 36, true, true);
  
  // Middle Yellow ring
  pushMatrix();
  translate(0, 0, 1);
  fill(240, 210, 20); 
  drawCylinder(16, 5, 36, true, true);
  
  // Inner Red center
  translate(0, 0, 1);
  fill(200, 30, 30); 
  drawCylinder(9, 5, 24, true, true);
  
  // Steel rotation pin head
  translate(0, 0, 5);
  fill(180, 190, 200);
  drawCylinder(4, 3, 12, true, true);
  popMatrix();
}

// ---------------------------------------------------------
// Particle System logic for Sangu Chakram Sparks
// ---------------------------------------------------------
class Spark {
  float x, y, z;
  float vx, vy, vz;
  float life;
  int c;

  Spark(float sx, float sy, float sz, float angle) {
    x = sx; y = sy; z = sz;
    
    // Shoot outwards incredibly fast to mimic a heavy ground spinner
    float speed = random(20, 50); 
    float spread = random(-0.1, 0.1); 
    
    vx = cos(angle + spread) * speed;
    vy = sin(angle + spread) * speed;
    vz = random(1, 6); // Gravity pulls sparks slightly downwards
    
    life = random(150, 255);
    
    // Colors of Sparks: White-hot, Golden Yellow, and bright Orange
    float r = random(1);
    if (r < 0.2) c = color(255, 255, 255);
    else if (r < 0.6) c = color(255, 220, 100);
    else c = color(255, 120, 30);
  }

  void update() {
    x += vx;
    y += vy;
    z += vz;
    
    vz += 0.2; // Gravity effect
    vx *= 0.93; // Air friction slows horizontal burst
    vy *= 0.93;
    
    life -= random(4, 12);
  }

  void display() {
    stroke(c, life);
    strokeWeight(random(2, 4)); // Spark thickness
    // Draw streaks (lines) rather than dots for realistic motion blur
    line(x, y, z, x - vx * 1.2, y - vy * 1.2, z - vz * 1.2);
  }
}

// ---------------------------------------------------------
// Helper: 3D Cylinder Generator
// ---------------------------------------------------------
void drawCylinder(float r, float h, int sides, boolean capBottom, boolean capTop) {
  float angle = TWO_PI / sides;
  
  if (capBottom) {
    beginShape(); // Defaults to POLYGON
    for (int i = sides; i >= 0; i--) vertex(r * cos(i * angle), r * sin(i * angle), 0);
    endShape(CLOSE);
  }
  if (capTop) {
    beginShape(); 
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
