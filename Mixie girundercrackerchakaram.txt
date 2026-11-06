// 3D Mixie with Kambi Mathapu / Sangu Chakram Firework for APDE
float motorAngle = 0;

// State control
boolean isRunning = false;

// Camera control variables
float camRotX = PI / 3.5; // Angled down to see the mixie base and jars
float camRotZ = PI / 4;   // Slight diagonal view

// Particle System for Kambi Mathapu / Sangu Chakram Sparks
ArrayList<Spark> sparks;

// Separate Button bounds
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
  // Dark night background to make the firework sparks glow brilliantly
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
  translate(width / 2, height / 2 + 100, -200);
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  // Scale dynamically for screen size
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  // 3D Lighting setup for Mixie Base Models
  lights();
  directionalLight(255, 250, 240, 0.5, 0.5, -1);
  ambientLight(120, 120, 120);
  
  // Update Physics & Spark Emission
  if (isRunning) {
    motorAngle += 0.6; // Very fast spin for the mixie motor
    
    // Ignite Sangu Chakram: Emit high-velocity sparks UPWARDS (Kambi Mathapu style)
    for (int i = 0; i < 25; i++) { // Dense fountain of sparks
      float randAngle = motorAngle + random(TWO_PI);
      float spread = random(-0.3, 0.3); // Narrow cone upward spread
      
      // Spawn at the Chakram base on the mixie motor (Z = 110)
      sparks.add(new Spark(cos(randAngle) * 15, sin(randAngle) * 15, 110, randAngle, spread));
    }
  }
  
  // Draw Mixie Base, Side Jars, and Chakram
  drawMixieScene3D();
  
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
  text("3D Mixie Kambi Mathapu (Side Jars)\nDrag screen to rotate view", 40, 40);
  
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
    camRotX = constrain(camRotX, 0, PI/2.0); // Don't let camera go below the floor
  }
}

// ---------------------------------------------------------
// 3D Mixie Scene (Base + Side Jars + Chakram)
// ---------------------------------------------------------
void drawMixieScene3D() {
  noStroke();
  
  // 1. MAIN MOTOR BASE (Center)
  fill(40, 42, 45); 
  pushMatrix();
  translate(0, 0, 0);
  // Wide steady base
  drawCylinder(120, 40, 48, true, true);
  
  // Tapering motor housing body
  translate(0, 0, 40);
  drawTaperedCylinder(120, 80, 60, 48);
  
  // Front control knob
  pushMatrix();
  rotateZ(-PI/2);
  translate(0, -95, 10);
  rotateX(PI/2);
  fill(180); // Silver knob ring
  drawCylinder(25, 8, 24, true, true);
  fill(20);  // Black dial
  translate(0, 0, 8);
  drawCylinder(20, 10, 24, true, true);
  // Dial indicator line
  fill(220, 40, 40);
  translate(0, 8, 10);
  box(4, 15, 2);
  popMatrix();
  
  // Top motor coupler (White nylon gear)
  translate(0, 0, 60);
  fill(230, 235, 240);
  drawCylinder(30, 15, 24, true, true);
  
  // 2. SANGU CHAKRAM (Placed directly on the motor base, NOT inside a jar)
  pushMatrix();
  translate(0, 0, 15); 
  rotateZ(motorAngle); // Spin with motor
  drawSanguChakram3D();
  popMatrix();
  
  popMatrix(); // End Main Base
  
  // 3. JARS PLACED SIDE-BY-SIDE
  // Left Side Small Chutney Jar
  pushMatrix();
  translate(-200, 0, 0);
  drawSteelJar(0.65, true); 
  popMatrix();
  
  // Right Side Big Jar
  pushMatrix();
  translate(220, 0, 0);
  drawSteelJar(1.0, false); 
  popMatrix();
}

// ---------------------------------------------------------
// Helper: Draw a Stainless Steel Jar
// ---------------------------------------------------------
void drawSteelJar(float s, boolean hasLid) {
  // Jar Base Holder (Black Plastic)
  fill(30, 32, 35);
  drawCylinder(75 * s, 25 * s, 36, true, true);
  
  // Handle (Black Plastic)
  pushMatrix();
  translate(85 * s, 0, 70 * s);
  box(20 * s, 15 * s, 120 * s); // Main vertical handle
  translate(-20 * s, 0, -50 * s);
  box(40 * s, 15 * s, 20 * s); // Bottom connection
  translate(0, 0, 100 * s);
  box(40 * s, 15 * s, 20 * s); // Top connection
  popMatrix();
  
  // Jar Body (Metallic Stainless Steel)
  fill(210, 215, 220); 
  pushMatrix();
  translate(0, 0, 25 * s);
  drawTaperedCylinderEmpty(75 * s, 95 * s, 120 * s, 48);
  popMatrix();
  
  // Optional Lid (White/Transparent Plastic)
  if (hasLid) {
    pushMatrix();
    translate(0, 0, (25 + 120) * s);
    fill(240, 245, 250, 220); // Slightly transparent lid
    drawCylinder(98 * s, 15 * s, 36, true, true);
    // Lid Dome/Cap
    translate(0, 0, 15 * s);
    drawTaperedCylinder(70 * s, 30 * s, 40 * s, 24);
    popMatrix();
  }
}

// ---------------------------------------------------------
// Sangu Chakram Firework Drawing (Horizontal Mount)
// ---------------------------------------------------------
void drawSanguChakram3D() {
  // Outer Green wrapper
  fill(30, 160, 60); 
  drawCylinder(45, 8, 36, true, true);
  
  // Middle Yellow ring
  pushMatrix();
  translate(0, 0, 8);
  fill(240, 210, 20); 
  drawCylinder(30, 6, 36, true, true);
  
  // Inner Red center
  translate(0, 0, 6);
  fill(200, 30, 30); 
  drawCylinder(16, 6, 24, true, true);
  
  // Steel center drive nut
  translate(0, 0, 6);
  fill(180, 190, 200);
  drawCylinder(10, 8, 6, true, true); // Hex nut
  popMatrix();
}

// ---------------------------------------------------------
// Particle System: Sparks shooting UP (Kambi Mathapu effect)
// ---------------------------------------------------------
class Spark {
  float x, y, z;
  float vx, vy, vz;
  float life;
  int c;

  Spark(float sx, float sy, float sz, float angle, float spread) {
    x = sx; y = sy; z = sz;
    
    // Kambi Mathapu creates a strong upward fountain
    float upwardSpeed = random(30, 50); 
    float outwardSpeed = random(5, 20);
    
    vx = cos(angle + spread) * outwardSpeed;
    vy = sin(angle + spread) * outwardSpeed;
    vz = upwardSpeed; // Strong upward Z velocity
    
    life = random(180, 255);
    
    // Colors: White-hot core, Golden yellow, Bright orange tails
    float r = random(1);
    if (r < 0.25) c = color(255, 255, 255);
    else if (r < 0.65) c = color(255, 230, 120);
    else c = color(255, 140, 40);
  }

  void update() {
    x += vx;
    y += vy;
    z += vz;
    
    vz -= 0.6; // Gravity pulls them down eventually
    
    // Since Chakram is in the open air, there are no jar walls to bounce off.
    // The sparks just fly up and fall freely.
    
    life -= random(3, 8);
  }

  void display() {
    stroke(c, life);
    strokeWeight(random(2, 5));
    // Draw streaks for motion blur
    line(x, y, z, x - vx * 0.8, y - vy * 0.8, z - vz * 0.8);
  }
}

// ---------------------------------------------------------
// Helpers: 3D Geometry Generators
// ---------------------------------------------------------
void drawCylinder(float r, float h, int sides, boolean capBottom, boolean capTop) {
  float angle = TWO_PI / sides;
  
  if (capBottom) {
    beginShape();
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

void drawTaperedCylinder(float rBottom, float rTop, float h, int sides) {
  float angle = TWO_PI / sides;
  
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float xb = rBottom * cos(i * angle);
    float yb = rBottom * sin(i * angle);
    float xt = rTop * cos(i * angle);
    float yt = rTop * sin(i * angle);
    
    vertex(xb, yb, 0);
    vertex(xt, yt, h);
  }
  endShape();
  
  // Top Cap
  beginShape(); 
  for (int i = 0; i <= sides; i++) vertex(rTop * cos(i * angle), rTop * sin(i * angle), h);
  endShape(CLOSE);
}

void drawTaperedCylinderEmpty(float rBottom, float rTop, float h, int sides) {
  float angle = TWO_PI / sides;
  
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float xb = rBottom * cos(i * angle);
    float yb = rBottom * sin(i * angle);
    float xt = rTop * cos(i * angle);
    float yt = rTop * sin(i * angle);
    
    vertex(xb, yb, 0);
    vertex(xt, yt, h);
  }
  endShape();
}
