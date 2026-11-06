// 3D Table Fan & Exhaust Fan + Sangu Chakram Fireworks for APDE
float tableFanAngle = 0;
float exhaustFanAngle = 0;

// State control
boolean isRunning = false;

// Camera control variables
float camRotX = PI / 12; // Looking slightly down
float camRotZ = 0;       // Straight on

// Particle System for Sangu Chakram Sparks
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
  // Dark night background for fireworks
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
  translate(width / 2, height / 2, -300); // Pull back to see both fans
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  // Scale dynamically for screen size
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  // 3D Lighting setup
  lights();
  directionalLight(255, 250, 240, 0.5, 0.5, -1);
  ambientLight(120, 120, 120);
  
  // Update Physics & Spark Emission
  if (isRunning) {
    tableFanAngle += 0.5;   // Thrust from firework spins the fan
    exhaustFanAngle -= 0.4; // Thrust spins the exhaust fan (opposite direction)
    
    // Ignite Table Fan Chakram (Left, X: -200, Z: 55)
    for (int i = 0; i < 15; i++) { 
      float randAngle = tableFanAngle + random(TWO_PI);
      sparks.add(new Spark(-200 + cos(randAngle)*20, sin(randAngle)*20, 55, randAngle));
    }
    
    // Ignite Exhaust Fan Chakram (Right, X: 200, Z: 30)
    for (int i = 0; i < 15; i++) { 
      float randAngle = exhaustFanAngle + random(TWO_PI);
      sparks.add(new Spark(200 + cos(randAngle)*20, sin(randAngle)*20, 30, randAngle));
    }
  }
  
  // Draw Both Fans
  drawFanScene3D();
  
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
  text("Table & Exhaust Fans fired by Sangu Chakram", 40, 40);
  
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
    camRotX = constrain(camRotX, -PI/4, PI/2.5); 
  }
}

// ---------------------------------------------------------
// 3D Scene: Table Fan (Left) & Exhaust Fan (Right)
// ---------------------------------------------------------
void drawFanScene3D() {
  noStroke();
  
  // ------------------------------------------------
  // 1. Table Fan (Left Side) based on Geepas
  // ------------------------------------------------
  pushMatrix();
  translate(-200, 0, 0); // Move left
  rotateX(PI/2); // Stand upright
  
  // Base
  fill(240, 245, 250); // White plastic
  drawTaperedCylinder(60, 45, 20, 36);
  // Buttons on base
  fill(150);
  pushMatrix(); translate(0, -35, 22); box(30, 10, 5); popMatrix();
  
  // Stand Neck
  fill(240, 245, 250);
  pushMatrix(); translate(0, 0, 20); drawCylinder(15, 80, 24, false, false); popMatrix();
  
  // Motor Housing (Back)
  pushMatrix();
  translate(0, -20, 100);
  rotateX(PI/2);
  fill(230, 235, 240);
  drawTaperedCylinder(30, 20, 60, 24);
  popMatrix();
  
  // Wire Grill Guard (Back half)
  pushMatrix();
  translate(0, 5, 100);
  rotateX(PI/2);
  fill(200);
  drawWireGrill(110);
  
  // Rotating Blades & Chakram
  pushMatrix();
  translate(0, 0, 15); // Move blades forward slightly
  rotateZ(tableFanAngle);
  
  // Central Hub
  fill(240, 245, 250);
  drawCylinder(25, 15, 36, true, true);
  
  // 3 Table Fan Blades
  fill(220, 225, 230, 200); // Slightly translucent white
  for(int i=0; i<3; i++) {
    pushMatrix();
    rotateZ(i * TWO_PI / 3);
    translate(60, 0, 8);
    rotateX(0.2); // Pitch
    box(80, 40, 2);
    popMatrix();
  }
  
  // Attach Sangu Chakram to the front of the Table Fan hub
  pushMatrix();
  translate(0, 0, 15);
  drawSanguChakram3D();
  popMatrix();
  
  popMatrix(); // End rotating parts
  popMatrix(); // End grill
  popMatrix(); // End Table Fan

  // ------------------------------------------------
  // 2. Exhaust Fan (Right Side) based on Panasonic
  // ------------------------------------------------
  pushMatrix();
  translate(200, 0, 0); // Move right
  rotateX(PI/2); // Stand upright
  
  // Square Wall Mount Frame
  fill(245, 250, 255); // White plastic frame
  pushMatrix();
  translate(0, 0, 100);
  box(240, 240, 15); // Outer square
  fill(40); // Dark hole behind blades
  translate(0, 0, -8);
  drawCylinder(110, 16, 48, true, true); // Cutout hole (visual trick)
  popMatrix();
  
  // Motor Housing & Grill Supports
  pushMatrix();
  translate(0, -10, 100);
  rotateX(PI/2);
  fill(220);
  drawCylinder(40, 20, 36, true, true);
  popMatrix();

  // Rotating Exhaust Blades & Chakram
  pushMatrix();
  translate(0, 5, 100);
  rotateX(PI/2);
  rotateZ(exhaustFanAngle);
  
  // Exhaust Hub
  fill(245, 250, 255);
  drawTaperedCylinder(35, 25, 20, 36);
  
  // 5 Exhaust Fan Blades
  fill(230, 235, 240);
  for(int i=0; i<5; i++) {
    pushMatrix();
    rotateZ(i * TWO_PI / 5);
    translate(65, 0, 10);
    rotateX(-0.3); // Pitch
    box(70, 35, 3);
    popMatrix();
  }
  
  // Attach Sangu Chakram to the front of the Exhaust Fan hub
  pushMatrix();
  translate(0, 0, 20);
  drawSanguChakram3D();
  popMatrix();
  
  popMatrix(); // End rotating parts
  popMatrix(); // End Exhaust Fan
}

// ---------------------------------------------------------
// Helper: Draw Wire Grill for Table Fan
// ---------------------------------------------------------
void drawWireGrill(float r) {
  stroke(150);
  strokeWeight(1);
  noFill();
  // Rings
  for(float i=20; i<=r; i+=15) {
    beginShape();
    for(int a=0; a<=360; a+=10) {
      vertex(i * cos(radians(a)), i * sin(radians(a)), 0);
    }
    endShape();
  }
  // Spokes
  for(int a=0; a<360; a+=15) {
    line(20 * cos(radians(a)), 20 * sin(radians(a)), 0, r * cos(radians(a)), r * sin(radians(a)), 0);
  }
  noStroke();
}

// ---------------------------------------------------------
// Sangu Chakram Firework Drawing (Horizontal Mount)
// ---------------------------------------------------------
void drawSanguChakram3D() {
  // Outer Green wrapper
  fill(30, 160, 60); 
  drawCylinder(22, 6, 36, true, true);
  
  // Middle Yellow ring
  pushMatrix();
  translate(0, 0, 6);
  fill(240, 210, 20); 
  drawCylinder(15, 4, 36, true, true);
  
  // Inner Red center
  translate(0, 0, 4);
  fill(200, 30, 30); 
  drawCylinder(8, 4, 24, true, true);
  
  // Steel center drive nut / mounting pin
  translate(0, 0, 4);
  fill(180, 190, 200);
  drawCylinder(4, 5, 12, true, true); 
  popMatrix();
}

// ---------------------------------------------------------
// Particle System: Sparks shooting outward radially
// ---------------------------------------------------------
class Spark {
  float x, y, z;
  float vx, vy, vz;
  float life;
  int c;

  Spark(float sx, float sy, float sz, float angle) {
    x = sx; y = sy; z = sz;
    
    // Sparks shoot outward aggressively, causing the fan to spin
    float speed = random(15, 35); 
    float spread = random(-0.1, 0.1); 
    
    // Determine which fan the spark belongs to based on starting X
    // Left Fan (-200) faces +Y, Right fan (200) faces +Y
    // We adjust spark velocity to shoot radially outward along the fan face (XZ plane locally)
    
    vx = cos(angle + spread) * speed;
    vy = sin(angle + spread) * speed; 
    vz = random(-2, 2); // Slight wobble off the flat plane
    
    life = random(150, 255);
    
    // Colors: White-hot core, Golden yellow, Bright orange tails
    float r = random(1);
    if (r < 0.2) c = color(255, 255, 255);
    else if (r < 0.6) c = color(255, 220, 100);
    else c = color(255, 120, 30);
  }

  void update() {
    // Note: Because the fans are rotated by PI/2 on X axis in the world,
    // the local X/Y of the chakram translates to world X/Z.
    // The sparks update in world space.
    x += vx;
    z -= vy; // Map local Y to world Z
    y += vz; // Map local Z to world Y (gravity falls towards +Y)
    
    y += 0.5; // Gravity pulling sparks down towards the floor
    
    life -= random(4, 10);
  }

  void display() {
    stroke(c, life);
    strokeWeight(random(2, 4));
    // Draw streaks for motion blur
    line(x, y, z, x - vx * 0.8, y - vz * 0.8, z + vy * 0.8);
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
