// 3D Wet Grinder Simulation for APDE (Android Processing)
float motorAngle = 0;
float drumAngle = 0;
float stoneSpinAngle = 0;

// State control
boolean isRunning = false;
boolean showCover = true; // New state for the motor casing

// Camera control variables
float camRotX = PI / 4; 
float camRotZ = 0;

// Separate Button bounds (Global variables, updated dynamically in draw)
int btnW = 140;
int btnH = 65;
int btnStartX = 0;
int btnStartY = 0;
int btnStopX = 0;
int btnStopY = 0;
int btnCoverX = 0;
int btnCoverY = 0;

void setup() {
  fullScreen(P3D); 
  orientation(LANDSCAPE);
  noStroke();
}

void draw() {
  background(220, 230, 240);
  
  // 3D Lighting setup
  lights();
  directionalLight(255, 255, 255, 0.5, 0.5, -1);
  ambientLight(120, 120, 120);
  
  // Update UI Button Positions (Bottom Left, fitting 3 buttons now)
  btnW = width / 7; // Scale button width to fit 3 buttons nicely
  if (btnW < 130) btnW = 130;
  
  btnStartX = 40;
  btnStartY = height - btnH - 40;
  
  btnStopX = btnStartX + btnW + 20;
  btnStopY = height - btnH - 40;
  
  btnCoverX = btnStopX + btnW + 20;
  btnCoverY = height - btnH - 40;
  
  // Auto-pan if not interacting
  if (!mousePressed) {
    camRotZ -= 0.005; 
  }
  
  // ---------------------------------------------------------
  // 3D Rendering Context
  // ---------------------------------------------------------
  pushMatrix();
  translate(width / 2, height / 2, -200);
  rotateX(camRotX);
  rotateZ(camRotZ);
  
  // Scale dynamically for screen size
  float scaleFactor = min(width / 800.0, height / 480.0);
  scale(scaleFactor);
  
  // Update Physics only if the motor is running
  if (isRunning) {
    float motorSpeed = 0.45; // Motor spins fast
    // Pulley Ratio: Small motor pulley drives large drum pulley
    float pulleyRatio = 40.0 / 140.0; 
    float drumSpeed = motorSpeed * pulleyRatio;
    
    motorAngle += motorSpeed;
    drumAngle += drumSpeed;
    // Granite stones roll against the inner drum floor surface
    stoneSpinAngle += drumSpeed * 2.6; 
  }
  
  // Draw all mechanical components in 3D space
  drawChassis3D();
  drawPulleysAndBelt3D();
  
  // Toggle between solid maroon casing and exposed motor mechanics
  if (showCover) {
    drawMotorCover3D();
  } else {
    drawMotor3D(); 
  }
  
  drawDrumAndStones3D();
  
  popMatrix();
  
  // ---------------------------------------------------------
  // 2D UI Overlay (Separated Buttons)
  // ---------------------------------------------------------
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights(); // Prevent 3D lights from washing out 2D UI
  
  // Top Left Title
  fill(50);
  textSize(35);
  textAlign(LEFT, TOP);
  text("3D Wet Grinder Mechanics\nDrag screen to rotate view", 40, 40);
  
  // Motor Status Text Indicator above buttons
  textAlign(LEFT, CENTER);
  textSize(24);
  if (isRunning) {
    fill(40, 180, 80); 
    text("STATUS: MOTOR RUNNING", btnStartX, btnStartY - 25);
  } else {
    fill(200, 60, 60); 
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
  
  // Draw COVER Button (Third Button)
  fill(100, 120, 180); // Nice blue color for the casing toggle
  rect(btnCoverX, btnCoverY, btnW, btnH, 10);
  
  // Button Labels
  textAlign(CENTER, CENTER);
  textSize(26);
  fill(255);
  text("START", btnStartX + btnW/2, btnStartY + btnH/2 - 3);
  text("STOP", btnStopX + btnW/2, btnStopY + btnH/2 - 3);
  
  // Dynamic text for cover button
  if (showCover) {
    text("OPEN\nCOVER", btnCoverX + btnW/2, btnCoverY + btnH/2 - 3);
  } else {
    text("CLOSE\nCOVER", btnCoverX + btnW/2, btnCoverY + btnH/2 - 3);
  }
  
  hint(ENABLE_DEPTH_TEST);
}

// ---------------------------------------------------------
// Input Handling
// ---------------------------------------------------------
void mousePressed() {
  // Check if click is inside the START button
  if (mouseX > btnStartX && mouseX < btnStartX + btnW && mouseY > btnStartY && mouseY < btnStartY + btnH) {
    isRunning = true;
  }
  // Check if click is inside the STOP button
  else if (mouseX > btnStopX && mouseX < btnStopX + btnW && mouseY > btnStopY && mouseY < btnStopY + btnH) {
    isRunning = false;
  }
  // Check if click is inside the COVER button
  else if (mouseX > btnCoverX && mouseX < btnCoverX + btnW && mouseY > btnCoverY && mouseY < btnCoverY + btnH) {
    showCover = !showCover;
  }
}

void mouseDragged() {
  // Only rotate camera if dragging OUTSIDE the entire bottom-left 3-button panel area
  if (!(mouseX > btnStartX - 20 && mouseX < btnCoverX + btnW + 20 && mouseY > btnStartY - 60 && mouseY < btnCoverY + btnH + 20)) {
    camRotZ += (mouseX - pmouseX) * 0.01;
    camRotX += (pmouseY - mouseY) * 0.01;
    camRotX = constrain(camRotX, 0, PI/2.2); // Prevent flipping upside down
  }
}

// ---------------------------------------------------------
// 1. Chassis (Base Body)
// ---------------------------------------------------------
void drawChassis3D() {
  fill(140, 20, 40); // Maroon base color
  
  // Left Drum Base Cylinder (x: -150)
  pushMatrix(); 
  translate(-150, 0, 0); 
  drawCylinder(160, 30, 48, true, true); 
  popMatrix();
  
  // Right Motor Base Cylinder (x: +150)
  pushMatrix(); 
  translate(150, 0, 0); 
  drawCylinder(100, 30, 36, true, true); 
  popMatrix();
  
  // Connecting Center Bridge
  pushMatrix();
  translate(0, 0, 15);
  box(300, 180, 30);
  popMatrix();
}

// ---------------------------------------------------------
// 2. Internal Mechanics (Pulleys & V-Belt)
// ---------------------------------------------------------
void drawPulleysAndBelt3D() {
  float rd = 140; // Drum pulley radius
  float rm = 40;  // Motor pulley radius
  float d = 300;  // Distance between axes
  float theta = asin((rd - rm) / d);
  float baseZ = 35; // Height above base floor
  float pHeight = 12; // Pulley thickness
  
  // A. V-Belt wrapping the two pulleys
  drawBelt3D(rd, rm, theta, baseZ, pHeight);
  
  // B. Large Drum Pulley (Left side at x: -150)
  pushMatrix();
  translate(-150, 0, baseZ);
  rotateZ(drumAngle);
  fill(60); 
  drawCylinder(rd, pHeight, 48, true, true);
  // Pulley Spokes
  pushMatrix(); 
  translate(0, 0, pHeight/2 + 1); 
  fill(40); 
  box(rd*1.9, 15, 6); 
  box(15, rd*1.9, 6); 
  popMatrix();
  popMatrix();
  
  // C. Small Motor Pulley (Right side at x: +150)
  // Only drawn if casing is open so it doesn't clip through the solid cover
  if (!showCover) {
    pushMatrix();
    translate(150, 0, baseZ);
    rotateZ(motorAngle);
    fill(180);
    drawCylinder(rm, pHeight, 24, true, true);
    popMatrix();
  }
}

void drawBelt3D(float rd, float rm, float theta, float z, float h) {
  fill(20); // Dark black rubber belt
  beginShape(QUAD_STRIP);
  int steps = 18;
  
  // Left Wrap (Drum Pulley)
  float startA = HALF_PI - theta;
  float endA = TWO_PI - HALF_PI + theta;
  for(int i = 0; i <= steps; i++) {
    float a = map(i, 0, steps, startA, endA);
    float px = -150 + rd * cos(a);
    float py = rd * sin(a);
    vertex(px, py, z); vertex(px, py, z + h);
  }
  
  // Right Wrap (Motor Pulley)
  float startB = -HALF_PI + theta;
  float endB = HALF_PI - theta;
  for(int i = 0; i <= steps; i++) {
    float a = map(i, 0, steps, startB, endB);
    float px = 150 + rm * cos(a);
    float py = rm * sin(a);
    vertex(px, py, z); vertex(px, py, z + h);
  }
  
  // Close loop connection
  float px0 = -150 + rd * cos(startA);
  float py0 = rd * sin(startA);
  vertex(px0, py0, z); vertex(px0, py0, z + h);
  endShape();
}

// ---------------------------------------------------------
// 3A. Solid Maroon Motor Casing (Closed State)
// ---------------------------------------------------------
void drawMotorCover3D() {
  pushMatrix();
  translate(150, 0, 30); // Positioned directly over the right motor base
  
  // Main Solid Maroon Casing
  fill(140, 20, 40); 
  drawCylinder(98, 120, 36, false, true);
  
  // Top Rounded Cap / Bevel Detail
  translate(0, 0, 120);
  fill(120, 15, 30); // Slightly darker for top edge distinction
  drawCylinder(94, 6, 36, true, true);
  popMatrix();
}

// ---------------------------------------------------------
// 3B. Exposed Motor Assembly (Opened State)
// ---------------------------------------------------------
void drawMotor3D() {
  pushMatrix();
  translate(150, 0, 30); 
  
  // Small cut-away maroon base to match chassis
  fill(140, 20, 40); 
  drawCylinder(95, 10, 36, false, true); 
  
  translate(0, 0, 15); // Move up to align with motor pulley 
  
  // --- STATIONARY MOTOR STATOR (Black Body) ---
  fill(40, 40, 45); 
  pushMatrix();
  translate(0, 0, 10);
  drawCylinder(45, 45, 36, true, true);
  
  // Inner Copper Coil Hint
  fill(180, 100, 40);
  translate(0, 0, -2);
  drawCylinder(38, 49, 36, false, false);
  popMatrix();
  
  // --- SPINNING ROTOR & FAN ---
  pushMatrix();
  rotateZ(motorAngle); // This entire block spins when running!
  
  // Metal Drive Shaft
  fill(190, 195, 200);
  drawCylinder(6, 85, 12, true, true);
  
  // White Cooling Fan at the top
  translate(0, 0, 65);
  fill(240, 245, 250);
  drawCylinder(42, 8, 24, true, true);
  
  // Fan Blades (Make the rotation highly visible)
  fill(220, 225, 230);
  for (int i = 0; i < 8; i++) {
    pushMatrix();
    rotateZ(i * TWO_PI / 8.0);
    translate(20, 0, 4);
    box(40, 3, 10);
    popMatrix();
  }
  
  popMatrix(); // End spinning parts
  popMatrix(); // End motor context
}

// ---------------------------------------------------------
// 4. Stainless Steel Drum & Granite Rolling Stones
// ---------------------------------------------------------
void drawDrumAndStones3D() {
  // A. Rotating Stainless Steel Drum (Left side at x: -150)
  pushMatrix();
  translate(-150, 0, 50); 
  rotateZ(drumAngle); // The entire drum rotates around its vertical axis
  
  // Outer Steel Wall
  fill(210, 215, 220);
  drawCylinder(120, 95, 48, true, false);
  
  // Inner Drum Floor & Batter Volume
  pushMatrix();
  translate(0, 0, 2); 
  fill(70, 75, 80); // Inner granite grinding floor
  drawCylinder(115, 6, 48, true, true);
  
  translate(0, 0, 6);
  fill(250, 250, 245); // Batter paste inside the drum
  drawCylinder(115, 35, 48, true, true);
  popMatrix();
  popMatrix();

  // B. Stationary Center Pillar & Stone Holder Spider
  pushMatrix();
  translate(-150, 0, 50); 
  
  // Central White Plastic Hub
  fill(245, 245, 250);
  stroke(200);
  strokeWeight(1);
  pushMatrix();
  translate(0, 0, 8);
  drawCylinder(35, 55, 36, true, true);
  popMatrix();
  noStroke();
  
  // Center Lock Cap / Pin
  fill(180);
  pushMatrix();
  translate(0, 0, 63);
  drawCylinder(15, 12, 24, true, true);
  popMatrix();
  
  // C. Horizontal Steel Axle Arms 
  fill(120);
  pushMatrix();
  translate(-44, 0, 32);
  box(62, 10, 10);
  popMatrix();
  pushMatrix();
  translate(44, 0, 32);
  box(62, 10, 10);
  popMatrix();

  // D. Horizontally Placed Granite Grooved Roller Stones 
  // Stone 1 (Left Side)
  pushMatrix();
  translate(-44, 0, 32);       
  rotateX(stoneSpinAngle); 
  drawHorizontalGroovedRollerStone();
  popMatrix();
  
  // Stone 2 (Right Side)
  pushMatrix();
  translate(44, 0, 32);        
  rotateX(-stoneSpinAngle); 
  drawHorizontalGroovedRollerStone();
  popMatrix();
  
  popMatrix(); 
}

// Horizontally oriented Grooved Granite Roller Stone 
void drawHorizontalGroovedRollerStone() {
  float r = 32; 
  float h = 50; 
  
  pushMatrix();
  rotateY(HALF_PI);
  translate(0, 0, -h/2);
  
  // Main Granite Body
  fill(95, 100, 105);
  drawCylinder(r, h, 36, true, true);
  
  // Grinder Stone Grooves
  fill(60, 65, 70);
  for(float zOffset = -h*0.3; zOffset <= h*0.3; zOffset += h*0.3) {
    pushMatrix();
    translate(0, 0, zOffset + h/2);
    drawCylinder(r * 1.01, 6, 36, false, false);
    popMatrix();
  }
  
  // Central plastic axis bush hole
  fill(240);
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
    beginShape(); // Processing defaults to POLYGON behavior
    for (int i = sides; i >= 0; i--) vertex(r * cos(i * angle), r * sin(i * angle), 0);
    endShape(CLOSE);
  }
  if (capTop) {
    beginShape(); // Processing defaults to POLYGON behavior
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
